extends CardBase
class_name BodyCardResource
## Resource for summonable units (player bodies and enemies)

@export var hp: int = 1
@export var attack: int = 1
@export var equipment_slots: int = 0  # Max equipment this unit can hold
@export var slot_types: Array[String] = []  # e.g., ["weapon", "armor"] or ["weapon"]
@export var attack_range: String = "melee"  # "melee" or "ranged" - ranged units stay in spawn and fire from column 2
@export var min_wave: int = 1  # Earliest wave this enemy can be spawned by the AI

func _init():
	card_type = "body"
