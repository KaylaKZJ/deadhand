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
var max_equipment_slots: int
var allowed_slot_types: Array[String] = []
var occupied_slots: Array[String] = []  # Track which slot types are currently used

# Owner info
var is_player_unit: bool = true
var lane_index: int = -1
var column_position: int = -1  # 0=player, 1=enemy battle, 2=enemy spawn
var enemy_level: int = 1  # For enemy units, shows wave difficulty

# UI references
@onready var hp_label: Label = $HPLabel
@onready var attack_label: Label = $ATKLabel
@onready var unit_name_label: Label = $UnitName
@onready var background: ColorRect = $Background
@onready var sprite: Sprite2D = $Sprite

var original_bg_color: Color

func initialize(data: BodyCardResource, is_player: bool, lane: int, column: int = 0, level: int = 1):
	"""Set up unit with card data"""
	card_data = data
	is_player_unit = is_player
	lane_index = lane
	column_position = column
	enemy_level = level
	
	# Set base stats
	base_hp = data.hp
	base_attack = data.attack
	max_equipment_slots = data.equipment_slots
	allowed_slot_types = data.slot_types.duplicate()
	
	# Initialize current stats
	current_hp = base_hp
	max_hp = base_hp
	current_attack = base_attack
	
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
	
	update_stats()
	print("%s equipped %s! (occupies: %s)" % [card_data.card_name, item.card_name, ", ".join(required_slots)])
	return true

func update_stats():
	"""Recalculate current stats from base + equipment"""
	var hp_bonus = 0
	var attack_bonus = 0
	
	# Reset to melee by default
	attack_range = "melee"
	
	for item in equipped_items:
		hp_bonus += item.hp_bonus
		attack_bonus += item.attack_bonus
		
		# Check if any equipped weapon is ranged
		if item.attack_range == "ranged":
			attack_range = "ranged"
	
	# Update max HP and current HP
	var old_max_hp = max_hp
	max_hp = base_hp + hp_bonus
	
	# If max HP increased, heal by the difference
	if max_hp > old_max_hp:
		current_hp += (max_hp - old_max_hp)
	
	# Update attack
	current_attack = base_attack + attack_bonus
	
	stats_changed.emit(self)
	update_display()

func take_damage(amount: int):
	"""Apply damage to this unit"""
	current_hp -= amount
	print("%s took %d damage! (%d HP remaining)" % [card_data.card_name, amount, current_hp])
	
	update_display()
	
	if current_hp <= 0:
		die()

func attack_target(target: Unit):
	"""Attack another unit with animation"""
	if target:
		print("%s attacks %s for %d damage!" % [card_data.card_name, target.card_data.card_name, current_attack])
		
		# Play attack animation
		await play_attack_animation(target)
		
		# Deal damage after animation
		target.take_damage(current_attack)

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
		attack_label.text = "ATK: %d" % current_attack
	
	# Update equipment display (simple text for MVP)
	if equipped_items.size() > 0:
		var equipment_names = []
		for item in equipped_items:
			equipment_names.append(item.card_name)
		if hp_label:
			hp_label.text += " [%s]" % ", ".join(equipment_names)

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
