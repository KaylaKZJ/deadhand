extends Node2D
class_name Unit
## Represents a unit on the combat board with HP, ATK, and equipment

signal died(unit: Unit)
signal stats_changed(unit: Unit)

# Base stats from card
var card_data: BodyCardResource
var base_hp: int
var base_attack: int

# Current stats (base + equipment bonuses)
var current_hp: int
var max_hp: int
var current_attack: int
var attack_range: String = "melee"  # "melee" or "ranged" - inherited from equipped weapons

# Equipment
var equipped_items: Array[EquipmentCardResource] = []
var equipped_attack_bonuses: Array[int] = []  # Effective ATK bonus per item (base + player ATK stat)
var equipped_def_bonuses: Array[int] = []     # Effective DEF bonus per item (base + player DEF stat)
var max_equipment_slots: int
var allowed_slot_types: Array[String] = []
var occupied_slots: Array[String] = []  # Track which slot types are currently used

# Owner info
var is_player_unit: bool = true
var lane_index: int = -1
var column_position: int = -1  # 0=player, 1=enemy battle, 2=enemy spawn
var enemy_level: int = 1  # For enemy units, shows wave difficulty

# Reference to combat manager for player stat bonuses
var combat_manager: CombatManager = null

# UI references
@onready var hp_label: Label = $HPLabel
@onready var attack_label: Label = $ATKLabel
@onready var unit_name_label: Label = $UnitName
@onready var equip_label: Label = $EquipLabel
@onready var background: ColorRect = $Background
@onready var sprite: Sprite2D = $Sprite

var original_bg_color: Color

func initialize(data: BodyCardResource, is_player: bool, lane: int, column: int = 0, level: int = 1, combat_mgr: CombatManager = null):
	"""Set up unit with card data"""
	card_data = data
	is_player_unit = is_player
	lane_index = lane
	column_position = column
	enemy_level = level
	combat_manager = combat_mgr
	
	# Set base stats
	base_hp = data.hp
	base_attack = data.attack
	max_equipment_slots = data.equipment_slots
	allowed_slot_types = data.slot_types.duplicate()
	
	# Scale enemy stats by wave difficulty
	if not is_player_unit and combat_mgr:
		var mult = combat_mgr.difficulty_multiplier
		base_hp = roundi(base_hp * mult)
		base_attack = roundi(base_attack * mult)
		# Flat DEF bonus: adds directly to HP pool, making pure ATK stacking less dominant
		base_hp += combat_mgr.wave_def_bonus
	
	# Initialize current stats
	current_hp = base_hp
	max_hp = base_hp
	current_attack = base_attack
	
	# Seed attack range from body card (equipment may upgrade this later in update_stats)
	attack_range = data.attack_range
	
	# Set unit name with level for enemies
	if unit_name_label:
		if is_player_unit:
			unit_name_label.text = card_data.card_name
		else:
			unit_name_label.text = "Lvl %d %s" % [enemy_level, card_data.card_name]
	
	# Set background color based on owner
	if background:
		if is_player_unit:
			background.color = Color(0.2, 0.3, 0.2, 1)  # Green for player
		else:
			background.color = Color(0.3, 0.2, 0.2, 1)  # Red for enemy
		original_bg_color = background.color
	
	update_display()

func set_column(new_column: int):
	"""Update the unit's column position (used when enemies advance)"""
	column_position = new_column

func equip(item: EquipmentCardResource) -> bool:
	"""Equip an item to this unit. Returns true if successful."""
	# Check if we have room
	if equipped_items.size() >= max_equipment_slots:
		print("%s: Equipment slots full! (%d/%d)" % [card_data.card_name, equipped_items.size(), max_equipment_slots])
		return false
	
	# Get slots this item requires
	var required_slots = item.get_required_slots()
	
	# Check if this unit has the allowed slot types for this item
	if not allowed_slot_types.is_empty():
		for slot_type in required_slots:
			if slot_type not in allowed_slot_types:
				print("%s: Cannot equip %s (needs %s slot, but only has: %s)" % [card_data.card_name, item.card_name, slot_type, ", ".join(allowed_slot_types)])
				return false
	
	# Check if the required slots are already occupied
	for slot_type in required_slots:
		if slot_type in occupied_slots:
			print("%s: Cannot equip %s (%s slot already occupied)" % [card_data.card_name, item.card_name, slot_type])
			return false
	
	# Equip the item and mark slots as occupied
	equipped_items.append(item)
	for slot_type in required_slots:
		occupied_slots.append(slot_type)
	
	# Calculate effective bonuses: apply player stat modifier to the equipment's bonus
	var effective_atk = item.attack_bonus
	var effective_def = item.def_bonus
	if is_player_unit and combat_manager:
		if item.equipment_category == "weapon":
			effective_atk += combat_manager.player_atk
		elif item.equipment_category == "armor":
			effective_def += combat_manager.player_def
	equipped_attack_bonuses.append(effective_atk)
	equipped_def_bonuses.append(effective_def)
	
	update_stats()
	print("%s equipped %s! (occupies: %s)" % [card_data.card_name, item.card_name, ", ".join(required_slots)])
	return true

func update_stats():
	"""Recalculate current stats from base + effective equipment bonuses"""
	var attack_bonus = 0
	var def_bonus = 0
	
	# Reset to card's base range (may be upgraded to ranged by equipped weapon)
	attack_range = card_data.attack_range
	
	for i in equipped_items.size():
		attack_bonus += equipped_attack_bonuses[i]
		def_bonus += equipped_def_bonuses[i]
		if equipped_items[i].attack_range == "ranged":
			attack_range = "ranged"
	
	# HP = body base + effective def bonus (already includes player DEF stat if armor)
	var old_max_hp = max_hp
	max_hp = base_hp + def_bonus
	
	# Heal by the difference if max HP increased
	if max_hp > old_max_hp:
		current_hp += (max_hp - old_max_hp)
	
	# ATK = body base + effective attack bonus (already includes player ATK stat if weapon)
	current_attack = base_attack + attack_bonus
	
	stats_changed.emit(self)
	update_display()

func get_total_attack() -> int:
	"""Get this unit's current attack value"""
	return current_attack

func take_damage(amount: int):
	"""Apply damage to this unit"""
	current_hp -= amount
	print("%s took %d damage! (%d/%d HP remaining)" % [card_data.card_name, amount, current_hp, max_hp])
	update_display()
	if current_hp <= 0:
		die()

func attack_target(target: Unit):
	"""Attack another unit with animation"""
	if target:
		var total_atk = get_total_attack()
		print("%s attacks %s for %d damage!" % [card_data.card_name, target.card_data.card_name, total_atk])
		
		# Play attack animation
		await play_attack_animation(target)
		
		# Deal damage after animation
		target.take_damage(total_atk)

func play_attack_animation(target: Unit = null):
	"""Animate the unit lunging toward the target (or forward if no target) and back"""
	var original_position = position
	var lunge_distance = 40  # How far to move forward
	var lunge_position: Vector2
	
	if target:
		# Calculate direction to target
		var direction = (target.global_position - global_position).normalized()
		lunge_position = position + (direction * lunge_distance)
	else:
		# No target - lunge in attack direction based on owner
		# Players lunge up (toward enemies), enemies lunge down (toward player)
		var direction = Vector2.UP if is_player_unit else Vector2.DOWN
		lunge_position = position + (direction * lunge_distance)
	
	# Create tween for smooth animation
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# Lunge forward
	tween.tween_property(self, "position", lunge_position, 0.15)
	# Return to original position
	tween.tween_property(self, "position", original_position, 0.15)
	
	# Wait for animation to complete
	await tween.finished

func die():
	"""Handle unit death"""
	print("%s has died!" % card_data.card_name)
	
	# Visual feedback - flash and fade out
	if background:
		background.color = Color.RED
	
	# Wait a moment before disappearing (so death is visible)
	await get_tree().create_timer(0.5).timeout
	
	died.emit(self)
	queue_free()

func update_display():
	"""Update UI elements to show current stats"""
	if hp_label:
		hp_label.text = "HP: %d/%d" % [current_hp, max_hp]
	
	if attack_label:
		attack_label.text = "ATK: %d" % get_total_attack()
	
	# Show equipped items on their own label so HP text is never truncated
	if equip_label:
		if equipped_items.size() > 0:
			var equipment_names: Array[String] = []
			for item in equipped_items:
				equipment_names.append(item.card_name)
			equip_label.text = "[%s]" % "\n".join(equipment_names)
		else:
			equip_label.text = ""

func get_unit_info() -> String:
	"""Get debug info about this unit"""
	var info = "%s (HP: %d/%d, ATK: %d)" % [card_data.card_name, current_hp, max_hp, current_attack]
	if equipped_items.size() > 0:
		info += " equipped with: "
		var items = []
		for item in equipped_items:
			items.append(item.card_name)
		info += ", ".join(items)
	return info

func highlight(enable: bool):
	"""Highlight this unit (for equipment targeting)"""
	if background:
		if enable:
			background.color = Color(0.4, 0.6, 0.4, 1)  # Green highlight
		else:
			background.color = original_bg_color
