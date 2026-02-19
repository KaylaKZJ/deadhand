extends Node2D
## Main game scene that orchestrates all systems

@onready var deck_manager: DeckManager = $DeckManager
@onready var combat_manager: CombatManager = $CombatManager
@onready var enemy_ai: EnemyAI = $EnemyAI

# Lanes
@onready var lane_1: Lane = $Board/Lane1
@onready var lane_2: Lane = $Board/Lane2
@onready var lane_3: Lane = $Board/Lane3
@onready var lane_4: Lane = $Board/Lane4
@onready var lane_5: Lane = $Board/Lane5

# UI
@onready var hand_container: HBoxContainer = $UI/HandContainer
@onready var body_pile_button: Button = $UI/DrawButtons/BodyPileButton
@onready var equipment_pile_button: Button = $UI/DrawButtons/EquipmentPileButton
@onready var end_turn_button: Button = $UI/EndTurnButton
@onready var turn_label: Label = $UI/TurnLabel
@onready var phase_label: Label = $UI/PhaseLabel
@onready var player_hp_label: Label = $UI/PlayerHPLabel
@onready var enemy_deck_label: Label = $UI/EnemyDeckLabel
@onready var enemy_hp_label: Label = $UI/EnemyHPLabel
@onready var game_over_panel: Panel = $UI/GameOverPanel
@onready var game_over_label: Label = $UI/GameOverPanel/VBoxContainer/GameOverLabel
@onready var restart_button: Button = $UI/GameOverPanel/VBoxContainer/RestartButton
@onready var stat_button: Button = $UI/StatButton
@onready var level_label: Label = $UI/LevelLabel
@onready var xp_label: Label = $UI/XPLabel
@onready var stat_panel: StatPanel = $UI/StatPanel

var lanes: Array[Lane] = []
var card_displays: Array[CardDisplay] = []
var selected_card_display: CardDisplay = null
var highlighted_unit: Unit = null  # Track which unit is highlighted
var highlighted_lane: Lane = null  # Track which lane is highlighted

func _ready():
	# Set up lanes
	lanes = [lane_1, lane_2, lane_3, lane_4, lane_5]
	for i in range(lanes.size()):
		lanes[i].set_lane_index(i)
		lanes[i].set_deck_manager(deck_manager)
		lanes[i].set_combat_manager(combat_manager)
	
	# Add combat_manager to group so CardDisplay and StatPanel can find it
	combat_manager.add_to_group("combat_manager")
	
	# Initialize managers
	enemy_ai.initialize(deck_manager, combat_manager)
	combat_manager.initialize(deck_manager, lanes, enemy_ai)
	
	# Link deck manager to combat manager for difficulty scaling
	deck_manager.combat_manager = combat_manager
	
	# Hide draw buttons since we auto-draw now
	body_pile_button.visible = false
	equipment_pile_button.visible = false
	
	# Connect signals
	body_pile_button.pressed.connect(_on_body_pile_pressed)
	equipment_pile_button.pressed.connect(_on_equipment_pile_pressed)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	stat_button.pressed.connect(_on_stat_button_pressed)
	
	deck_manager.hand_updated.connect(_on_hand_updated)
	combat_manager.turn_started.connect(_on_turn_started)
	combat_manager.phase_changed.connect(_on_phase_changed)
	combat_manager.game_won.connect(_on_game_won)
	combat_manager.game_lost.connect(_on_game_lost)
	combat_manager.level_up.connect(_on_level_up)
	combat_manager.xp_gained.connect(_on_xp_gained)
	combat_manager.stat_allocated.connect(_on_stat_allocated)
	stat_panel.stat_preview_changed.connect(_on_stat_preview_changed)
	
	# Hide game over panel initially
	game_over_panel.visible = false
	
	# Start the game
	combat_manager.start_game()
	
	# Update displays
	_update_hp_display()
	_update_enemy_hp_display()
	_update_enemy_deck_display()
	_update_xp_display()
	_update_stat_button()

func _process(_delta):
	"""Update highlighting for equipment targeting"""
	if selected_card_display and selected_card_display.is_being_dragged:
		var card = selected_card_display.get_card_data()
		var mouse_pos = get_global_mouse_position()
		
		# Only highlight for equipment cards
		if card is EquipmentCardResource:
			var closest_unit = _find_closest_player_unit(mouse_pos)
			
			# Update unit highlighting
			if closest_unit != highlighted_unit:
				# Clear old highlight
				if highlighted_unit:
					highlighted_unit.highlight(false)
				
				# Set new highlight
				highlighted_unit = closest_unit
				if highlighted_unit:
					highlighted_unit.highlight(true)
		
		# Highlight lanes for body cards
		elif card is BodyCardResource:
			var target_lane = _get_lane_at_position(mouse_pos)
			
			# Update lane highlighting
			if target_lane != highlighted_lane:
				# Clear old highlight
				if highlighted_lane and highlighted_lane.player_drop_zone:
					highlighted_lane._on_drop_zone_exit()
				
				# Set new highlight
				highlighted_lane = target_lane
				if highlighted_lane and highlighted_lane.player_drop_zone and not highlighted_lane.column_0_unit:
					highlighted_lane._on_drop_zone_hover()
	else:
		# Clear all highlights when not dragging
		if highlighted_unit:
			highlighted_unit.highlight(false)
			highlighted_unit = null
		
		if highlighted_lane and highlighted_lane.player_drop_zone:
			highlighted_lane._on_drop_zone_exit()
			highlighted_lane = null

func _on_body_pile_pressed():
	"""Player chose to draw from body pile"""
	combat_manager.on_pile_selected("body")

func _on_equipment_pile_pressed():
	"""Player chose to draw from equipment pile"""
	combat_manager.on_pile_selected("equipment")

func _on_end_turn_pressed():
	"""Player ends their turn"""
	combat_manager.end_turn()

func _on_restart_pressed():
	"""Restart the game"""
	get_tree().reload_current_scene()

func _on_hand_updated(hand: Array[CardBase]):
	"""Update hand display when cards change"""
	# Clear existing displays
	for card_display in card_displays:
		card_display.queue_free()
	card_displays.clear()
	
	# Create new displays
	var card_display_scene = load("res://scenes/cards/card_display.tscn")
	for card in hand:
		var card_display: CardDisplay = card_display_scene.instantiate()
		card_display.set_combat_manager(combat_manager)
		hand_container.add_child(card_display)
		card_display.set_card_data(card)
		card_display.card_selected.connect(_on_card_selected)
		card_display.card_played.connect(_on_card_played)
		card_displays.append(card_display)

func _on_card_selected(card_display: CardDisplay):
	"""A card was picked up"""
	selected_card_display = card_display
	var card_name = card_display.get_card_data().card_name
	var card = card_display.get_card_data()
	
	if card is EquipmentCardResource:
		print("Selected %s - Drop on any player unit to equip!" % card_name)
	else:
		print("Selected %s - Drop on empty lane to summon!" % card_name)

func _on_card_played(card_display: CardDisplay):
	"""A card was dropped"""
	if not selected_card_display:
		return
	
	var card = card_display.get_card_data()
	
	# Determine where the card was dropped
	var mouse_pos = get_global_mouse_position()
	var target_lane = _get_lane_at_position(mouse_pos)
	
	if target_lane == null:
		print("Dropped outside valid area!")
		card_display.return_to_hand()
		selected_card_display = null
		return
	
	# Check card type and handle appropriately
	if card is BodyCardResource:
		# Summon to lane
		var success = combat_manager.on_card_played(card, target_lane.lane_index)
		if not success:
			card_display.return_to_hand()
	elif card is EquipmentCardResource:
		# For equipment, try to find any player unit in the target lane
		# If lane has a player unit, automatically target it
		var target_unit = target_lane.column_0_unit if target_lane else null
		
		# If no unit in the exact lane, check nearby lanes for easier targeting
		if not target_unit:
			target_unit = _find_closest_player_unit(mouse_pos)
		
		if target_unit:
			var success = combat_manager.on_card_played(card, target_unit.lane_index, target_unit)
			if not success:
				card_display.return_to_hand()
		else:
			print("Equipment must be dropped near a player unit! No units on board.")
			card_display.return_to_hand()
	
	selected_card_display = null

func _get_lane_at_position(pos: Vector2) -> Lane:
	"""Find which lane a position is over using rectangular hit detection"""
	for lane in lanes:
		if lane.is_point_in_player_zone(pos):
			return lane
	return null

func _find_closest_player_unit(pos: Vector2) -> Unit:
	"""Find the closest player unit to a position (for easier equipment drops)"""
	var closest_unit: Unit = null
	var closest_distance: float = 200.0  # Max search radius
	
	for lane in lanes:
		if lane.column_0_unit:
			var distance = pos.distance_to(lane.column_0_unit.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_unit = lane.column_0_unit
	
	return closest_unit

func _get_unit_at_position(pos: Vector2, lane: Lane) -> Unit:
	"""Find unit at position in a lane"""
	if lane.column_0_unit:
		var unit_pos = lane.column_0_unit.global_position
		# Increased detection radius from 60 to 150 for easier targeting
		if pos.distance_to(unit_pos) < 150:
			return lane.column_0_unit
	return null

func _on_turn_started(turn: int):
	"""Update UI when turn starts"""
	turn_label.text = "Turn: %d" % turn

func _on_phase_changed(phase: String):
	"""Update UI when phase changes"""
	phase_label.text = "Phase: %s" % phase
	
	# Update displays on any phase change
	_update_hp_display()
	_update_enemy_hp_display()
	_update_enemy_deck_display()
	_update_xp_display()
	_update_stat_button()
	
	# Enable/disable buttons based on phase (draw buttons always disabled now)
	match phase:
		"PLAY":
			end_turn_button.disabled = false
		_:
			end_turn_button.disabled = true

func _on_game_won():
	"""Player won!"""
	print("Game won!")
	_show_game_over("VICTORY!", Color.GREEN)

func _on_game_lost():
	"""Player lost!"""
	print("Game lost!")
	_show_game_over("DEFEAT!", Color.RED)

func _show_game_over(message: String, color: Color):
	"""Show the game over screen with restart button"""
	game_over_label.text = message
	game_over_label.add_theme_color_override("font_color", color)
	game_over_panel.visible = true
	
	# Disable game controls
	body_pile_button.disabled = true
	equipment_pile_button.disabled = true
	end_turn_button.disabled = true

func _update_hp_display():
	"""Update the player HP label"""
	if player_hp_label and combat_manager:
		player_hp_label.text = "HP: %d/%d" % [combat_manager.player_hp, combat_manager.max_player_hp]
		
		# Color code the HP
		if combat_manager.player_hp <= 5:
			player_hp_label.add_theme_color_override("font_color", Color.RED)
		elif combat_manager.player_hp <= 10:
			player_hp_label.add_theme_color_override("font_color", Color.ORANGE)
		else:
			player_hp_label.add_theme_color_override("font_color", Color.WHITE)

func _update_enemy_deck_display():
	"""Update the enemy deck counter"""
	if enemy_deck_label and deck_manager:
		var total_enemies = deck_manager.enemy_draw_pile.size() + deck_manager.enemy_discard_pile.size()
		
		# Count enemies on board
		var enemies_on_board = 0
		for lane in lanes:
			if lane.has_enemy_unit():
				enemies_on_board += 1
		
		enemy_deck_label.text = "Enemy Cards: %d\n(On Board: %d)" % [total_enemies, enemies_on_board]
		
		# Just informational now - no color coding since deck count doesn't affect win
		enemy_deck_label.add_theme_color_override("font_color", Color.WHITE)

func _update_enemy_hp_display():
	"""Update the enemy HP label"""
	if enemy_hp_label and combat_manager:
		enemy_hp_label.text = "Enemy HP: %d/%d" % [combat_manager.enemy_hp, combat_manager.max_enemy_hp]
		
		# Color code the HP
		if combat_manager.enemy_hp <= 5:
			enemy_hp_label.add_theme_color_override("font_color", Color.GREEN)  # Almost defeated!
		elif combat_manager.enemy_hp <= 10:
			enemy_hp_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			enemy_hp_label.add_theme_color_override("font_color", Color.WHITE)

func _update_xp_display():
	"""Update level and XP labels"""
	if not combat_manager:
		return
	if level_label:
		level_label.text = "Lv.%d" % combat_manager.player_level
	if xp_label:
		var xp_to_next = combat_manager._xp_for_next_level()
		xp_label.text = "XP: %d/%d" % [combat_manager.player_xp, combat_manager.player_xp + xp_to_next]

func _update_stat_button():
	"""Glow the stat button when unspent points are available"""
	if not stat_button:
		return
	var pts = combat_manager.unspent_stat_points if combat_manager else 0
	if pts > 0:
		stat_button.text = "Stats (%d)" % pts
		stat_button.add_theme_color_override("font_color", Color.YELLOW)
	else:
		stat_button.text = "Stats"
		stat_button.remove_theme_color_override("font_color")

func _on_stat_button_pressed():
	"""Open the stat allocation panel"""
	if stat_panel:
		stat_panel.open_panel()

func _on_level_up(new_level: int, _stat_points: int):
	"""Handle level-up event"""
	print("UI: Level up to %d!" % new_level)
	_update_xp_display()
	_update_stat_button()
	_update_hp_display()

func _on_xp_gained(_amount: int, _current_xp: int, _xp_to_next: int):
	"""Handle XP gain"""
	_update_xp_display()

func _on_stat_allocated(_stat_name: String, _new_value: int):
	"""Handle stat allocation - refresh buttons and HP display"""
	_update_stat_button()
	_update_hp_display()

func _on_stat_preview_changed(staged_atk: int, staged_def: int, staged_vit: int):
	"""Forward StatPanel preview to all cards currently in hand"""
	for card_display in card_displays:
		card_display._on_stat_preview_changed(staged_atk, staged_def, staged_vit)
