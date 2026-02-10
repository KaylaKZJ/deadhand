extends Control
class_name CardDisplay
## Visual representation of a card in hand

signal card_selected(card_display: CardDisplay)
signal card_played(card_display: CardDisplay)

var card_data: CardBase = null
var is_being_dragged: bool = false
var original_position: Vector2

@onready var background: ColorRect = $Background
@onready var card_name_label: Label = $VBoxContainer/CardName
@onready var stats_label: Label = $VBoxContainer/Stats
@onready var description_label: Label = $VBoxContainer/Description

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	gui_input.connect(_on_gui_input)

func set_card_data(data: CardBase):
	"""Initialize this card display with card data"""
	card_data = data
	update_display()

func update_display():
	"""Update visual elements based on card data"""
	if not card_data:
		return
	
	# Set card name
	if card_name_label:
		card_name_label.text = card_data.card_name
	
	# Set stats/info based on card type
	if stats_label:
		if card_data is BodyCardResource:
			var body_card = card_data as BodyCardResource
			stats_label.text = "HP: %d | ATK: %d" % [body_card.hp, body_card.attack]
			# Color body cards green
			if background:
				background.color = Color(0.2, 0.4, 0.2, 1)
		elif card_data is EquipmentCardResource:
			var equip_card = card_data as EquipmentCardResource
			var bonuses = []
			if equip_card.hp_bonus > 0:
				bonuses.append("+%d HP" % equip_card.hp_bonus)
			if equip_card.attack_bonus > 0:
				bonuses.append("+%d ATK" % equip_card.attack_bonus)
			stats_label.text = " | ".join(bonuses)
			# Color equipment cards blue
			if background:
				background.color = Color(0.2, 0.2, 0.4, 1)
	
	# Set description
	if description_label:
		description_label.text = card_data.description

func _on_gui_input(event: InputEvent):
	"""Handle mouse input for dragging"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_being_dragged = true
				original_position = global_position
				card_selected.emit(self)
				# Make card larger while dragging for better visibility
				scale = Vector2(1.2, 1.2)
				z_index = 100  # Draw on top
			else:
				if is_being_dragged:
					is_being_dragged = false
					scale = Vector2(1.0, 1.0)
					z_index = 0
					card_played.emit(self)

func _process(_delta):
	"""Update position while dragging"""
	if is_being_dragged:
		global_position = get_global_mouse_position() - size / 2

func return_to_hand():
	"""Return card to original position (if drag failed)"""
	if original_position:
		global_position = original_position
		scale = Vector2(1.0, 1.0)
		z_index = 0

func get_card_data() -> CardBase:
	"""Get the card data this display represents"""
	return card_data
