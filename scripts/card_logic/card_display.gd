extends Control
class_name CardDisplay
## Visual representation of a card in hand

signal card_selected(card_display: CardDisplay)
signal card_played(card_display: CardDisplay)

var card_data: CardBase = null
var is_being_dragged: bool = false
var original_position: Vector2
var combat_manager: CombatManager = null

# Staged preview offsets — set by StatPanel while the panel is open, 0 when closed
var _preview_atk_bonus: int = 0
var _preview_def_bonus: int = 0
var _preview_vit_bonus: int = 0

@onready var background: ColorRect = $Background
@onready var card_name_label: Label = $VBoxContainer/CardName
@onready var stats_label: Label = $VBoxContainer/Stats
@onready var description_label: Label = $VBoxContainer/Description

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	gui_input.connect(_on_gui_input)
	# Only auto-find if not already injected by the parent (avoids timing issues)
	if not combat_manager:
		combat_manager = get_tree().get_first_node_in_group("combat_manager")
	if combat_manager and not combat_manager.stat_allocated.is_connected(_on_stat_allocated):
		combat_manager.stat_allocated.connect(_on_stat_allocated)
	# Refresh display now that combat_manager may be available
	update_display()

func set_combat_manager(mgr: CombatManager) -> void:
	"""Inject the combat manager before _ready so stats are correct immediately."""
	combat_manager = mgr
	if combat_manager and not combat_manager.stat_allocated.is_connected(_on_stat_allocated):
		combat_manager.stat_allocated.connect(_on_stat_allocated)

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
			# Body cards show base stats only — player bonuses apply at combat time via Unit
			var body_card = card_data as BodyCardResource
			stats_label.text = "HP: %d | ATK: %d" % [body_card.hp, body_card.attack]
			stats_label.remove_theme_color_override("font_color")
			if background:
				background.color = Color(0.2, 0.4, 0.2, 1)

		elif card_data is EquipmentCardResource:
			var equip_card = card_data as EquipmentCardResource
			var bonuses: Array[String] = []

			if equip_card.equipment_category == "weapon":
				# Weapons scale with player ATK
				var committed_atk = equip_card.attack_bonus
				if combat_manager:
					committed_atk += combat_manager.player_atk
				var displayed_atk = committed_atk + _preview_atk_bonus
				var s = "+%d ATK" % displayed_atk
				if _preview_atk_bonus != 0:
					s += " ★"
				bonuses.append(s)

			elif equip_card.equipment_category == "armor":
				# Armor adds HP to the unit. player_def adds extra HP on top when equipped.
				var committed_hp = equip_card.def_bonus
				if combat_manager:
					committed_hp += combat_manager.player_def
				var displayed_hp = committed_hp + _preview_def_bonus
				if displayed_hp > 0:
					var s = "+%d HP" % displayed_hp
					if _preview_def_bonus != 0:
						s += " ★"
					bonuses.append(s)

			else:
				# Fallback: show raw bonuses for uncategorised equipment
				if equip_card.attack_bonus > 0:
					bonuses.append("+%d ATK" % equip_card.attack_bonus)
				if equip_card.def_bonus > 0:
					bonuses.append("+%d HP" % equip_card.def_bonus)
				if equip_card.defense_bonus > 0:
					bonuses.append("+%d DEF" % equip_card.defense_bonus)

			stats_label.text = " | ".join(bonuses) if not bonuses.is_empty() else "(no bonuses)"

			# Tint gold while any relevant preview is active
			if _preview_atk_bonus != 0 or _preview_def_bonus != 0:
				stats_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
			else:
				stats_label.remove_theme_color_override("font_color")

			if background:
				background.color = Color(0.2, 0.2, 0.4, 1)
	
	# Set description
	if description_label:
		description_label.text = card_data.description

func _on_stat_allocated(_stat_name: String, _new_value: int):
	"""Refresh display when player stats are committed — clear preview (now baked in)"""
	_preview_atk_bonus = 0
	_preview_def_bonus = 0
	_preview_vit_bonus = 0
	update_display()

func _on_stat_preview_changed(staged_atk: int, staged_def: int, staged_vit: int):
	"""Called by StatPanel while tweaking — show preview without committing"""
	_preview_atk_bonus = staged_atk
	_preview_def_bonus = staged_def
	_preview_vit_bonus = staged_vit
	update_display()

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
