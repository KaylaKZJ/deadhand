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

# Equipment
var equipped_items: Array[EquipmentCardResource] = []
var max_equipment_slots: int
var allowed_slot_types: Array[String] = []

# Owner info
var is_player_unit: bool = true
var lane_index: int = -1

# UI references
@onready var hp_label: Label = $HPLabel
@onready var attack_label: Label = $ATKLabel
@onready var unit_name_label: Label = $UnitName
@onready var background: ColorRect = $Background
@onready var sprite: Sprite2D = $Sprite

var original_bg_color: Color

func initialize(data: BodyCardResource, is_player: bool, lane: int):
	"""Set up unit with card data"""
	card_data = data
	is_player_unit = is_player
	lane_index = lane
	
	# Set base stats
	base_hp = data.hp
	base_attack = data.attack
	max_equipment_slots = data.equipment_slots
	allowed_slot_types = data.slot_types.duplicate()
	
	# Initialize current stats
	current_hp = base_hp
	max_hp = base_hp
	current_attack = base_attack
	
	# Set unit name
	if unit_name_label:
		unit_name_label.text = card_data.card_name
	
	# Set background color based on owner
	if background:
		if is_player_unit:
			background.color = Color(0.2, 0.3, 0.2, 1)  # Green for player
		else:
			background.color = Color(0.3, 0.2, 0.2, 1)  # Red for enemy
		original_bg_color = background.color
	
	update_display()

func equip(item: EquipmentCardResource) -> bool:
	"""Equip an item to this unit. Returns true if successful."""
	# Check if we have room
	if equipped_items.size() >= max_equipment_slots:
		print("%s: Equipment slots full!" % card_data.card_name)
		return false
	
	# Check if this unit can equip this type
	if not allowed_slot_types.is_empty():
		if item.equipment_type not in allowed_slot_types:
			print("%s: Cannot equip %s (wrong slot type)" % [card_data.card_name, item.card_name])
			return false
	
	# Equip the item
	equipped_items.append(item)
	update_stats()
	print("%s equipped %s!" % [card_data.card_name, item.card_name])
	return true

func update_stats():
	"""Recalculate current stats from base + equipment"""
	var hp_bonus = 0
	var attack_bonus = 0
	
	for item in equipped_items:
		hp_bonus += item.hp_bonus
		attack_bonus += item.attack_bonus
	
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
	"""Attack another unit"""
	if target:
		print("%s attacks %s for %d damage!" % [card_data.card_name, target.card_data.card_name, current_attack])
		target.take_damage(current_attack)

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
