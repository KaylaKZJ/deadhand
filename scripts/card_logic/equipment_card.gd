extends CardBase
class_name EquipmentCardResource
## Resource for equipment that modifies unit stats

@export var equipment_type: String = ""  # "weapon" or "armor"
@export var hp_bonus: int = 0
@export var attack_bonus: int = 0

func _init():
	card_type = "equipment"
