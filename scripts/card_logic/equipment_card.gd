extends CardBase
class_name EquipmentCardResource
## Resource for equipment that modifies unit stats

@export var equipment_type: String = ""  # "weapon", "armor", "helmet", "shield"
@export var slots_required: Array[String] = []  # For multi-slot items like bow: ["weapon", "shield"]
@export var attack_range: String = "melee"  # "melee" or "ranged"
@export var hp_bonus: int = 0
@export var attack_bonus: int = 0

func _init():
	card_type = "equipment"

func get_required_slots() -> Array[String]:
	"""Get all slot types this equipment requires"""
	if slots_required.is_empty():
		# Single-slot item, return the equipment_type
		return [equipment_type]
	else:
		# Multi-slot item, return the slots_required array
		return slots_required
