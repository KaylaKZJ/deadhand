extends Resource
class_name CardBase
## Base class for all card types in the game

@export var card_name: String = ""
@export var card_type: String = ""  # "body", "equipment", "enemy"
@export_multiline var description: String = ""
@export var icon: Texture2D  # Card artwork (optional for MVP)
