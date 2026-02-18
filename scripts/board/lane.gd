extends Node2D
class_name Lane
## Manages one lane of combat with 3 columns: player (column 0), enemy battle (column 1), enemy spawn (column 2)

signal unit_summoned(unit: Unit, is_player: bool, column: int)
signal unit_died(unit: Unit, is_player: bool)

var lane_index: int = 0

# Column-based unit tracking
# Column 0: Player units (stationary defenders)
# Column 1: Enemy battle position (enemies attack from here)
# Column 2: Enemy spawn position (enemies start here, advance to column 1)
var column_0_unit: Unit = null  # Player unit
var column_1_unit: Unit = null  # Enemy in battle position
var column_2_unit: Unit = null  # Enemy in spawn position

var deck_manager: DeckManager = null  # Reference to deck manager for discarding

# References to spawn positions
@onready var column_0_spawn: Marker2D = $Column0Spawn  # Player spawn (bottom)
@onready var column_1_spawn: Marker2D = $Column1Spawn  # Enemy battle spawn (middle)
@onready var column_2_spawn: Marker2D = $Column2Spawn  # Enemy far spawn (top)
@onready var player_drop_zone: ColorRect = $PlayerDropZone

func _ready():
	# Make drop zone highlight on hover
	if player_drop_zone:
		player_drop_zone.mouse_entered.connect(_on_drop_zone_hover)
		player_drop_zone.mouse_exited.connect(_on_drop_zone_exit)

func set_lane_index(index: int):
	"""Set this lane's index (0-4)"""
	lane_index = index

func set_deck_manager(deck_mgr: DeckManager):
	"""Set reference to deck manager for discarding cards"""
	deck_manager = deck_mgr

func summon_player_unit(unit_data: BodyCardResource) -> Unit:
	"""Summon a player unit to column 0 (player position)"""
	if column_0_unit != null:
		print("Lane %d already has a player unit in column 0!" % lane_index)
		return null
	
	var unit = _create_unit(unit_data, true, 0)
	column_0_unit = unit
	
	# Dim the drop zone when occupied
	if player_drop_zone:
		player_drop_zone.color = Color(0.2, 0.3, 0.2, 0.3)
		if player_drop_zone.has_node("PlayerZoneLabel"):
			player_drop_zone.get_node("PlayerZoneLabel").visible = false
	
	unit_summoned.emit(unit, true, 0)
	return unit

func summon_enemy_unit(unit_data: BodyCardResource, column: int = 2, level: int = 1) -> Unit:
	"""Summon an enemy unit to specified column (default: column 2 = spawn position)"""
	if column == 2:
		if column_2_unit != null:
			print("Lane %d already has an enemy unit in column 2!" % lane_index)
			return null
		
		var unit = _create_unit(unit_data, false, 2, level)
		column_2_unit = unit
		
		# Visual spawn effect - flash the unit
		if unit and unit.background:
			var original_color = unit.background.color
			unit.background.color = Color.YELLOW  # Flash yellow
			await get_tree().create_timer(0.3).timeout
			if unit and is_instance_valid(unit) and unit.background:
				unit.background.color = original_color
		
		unit_summoned.emit(unit, false, 2)
		return unit
	elif column == 1:
		if column_1_unit != null:
			print("Lane %d already has an enemy unit in column 1!" % lane_index)
			return null
		
		var unit = _create_unit(unit_data, false, 1, level)
		column_1_unit = unit
		unit_summoned.emit(unit, false, 1)
		return unit
	else:
		print("ERROR: Cannot summon enemy to column %d" % column)
		return null

func _create_unit(unit_data: BodyCardResource, is_player: bool, column: int, level: int = 1) -> Unit:
	"""Create a unit instance in the specified column"""
	# Load unit scene
	var unit_scene = load("res://scenes/cards/unit_on_board.tscn")
	var unit: Unit = unit_scene.instantiate()
	
	# Position the unit based on column
	var spawn_marker: Marker2D = null
	if column == 0 and column_0_spawn:
		spawn_marker = column_0_spawn
	elif column == 1 and column_1_spawn:
		spawn_marker = column_1_spawn
	elif column == 2 and column_2_spawn:
		spawn_marker = column_2_spawn
	
	if spawn_marker:
		unit.position = spawn_marker.position
	else:
		# Fallback positions if markers don't exist yet
		if column == 0:
			unit.position = Vector2(0, 0)  # Player column (bottom)
		elif column == 1:
			unit.position = Vector2(0, -100)  # Enemy battle column (middle)
		else:
			unit.position = Vector2(0, -200)  # Enemy spawn column (top)
	
	add_child(unit)
	unit.initialize(unit_data, is_player, lane_index, column, level)
	unit.died.connect(_on_unit_died)
	
	return unit

func _on_unit_died(unit: Unit):
	"""Handle when a unit in this lane dies"""
	# Check which column the unit was in
	if unit == column_0_unit:
		column_0_unit = null
		# Discard the player's body card
		if deck_manager and unit.card_data:
			deck_manager.discard_card(unit.card_data)
			print("Player card discarded: %s" % unit.card_data.card_name)
		# Restore drop zone when player unit dies
		if player_drop_zone:
			player_drop_zone.color = Color(0.2, 0.3, 0.2, 0.5)
			if player_drop_zone.has_node("PlayerZoneLabel"):
				player_drop_zone.get_node("PlayerZoneLabel").visible = true
		unit_died.emit(unit, true)
	elif unit == column_1_unit:
		column_1_unit = null
		# Discard the enemy card
		if deck_manager and unit.card_data:
			deck_manager.discard_enemy_card(unit.card_data)
			print("Enemy card discarded: %s" % unit.card_data.card_name)
		unit_died.emit(unit, false)
	elif unit == column_2_unit:
		column_2_unit = null
		# Discard the enemy card
		if deck_manager and unit.card_data:
			deck_manager.discard_enemy_card(unit.card_data)
			print("Enemy card discarded: %s" % unit.card_data.card_name)
		unit_died.emit(unit, false)

func resolve_combat():
	"""Resolve combat in this lane. Returns [overflow_to_player, overflow_to_enemy]."""
	var overflow_to_player = 0
	var overflow_to_enemy = 0
	
	var combat_happened = false  # Track if units actually fought
	
	# Player unit attacks (prioritize Column 1, then Column 2)
	if column_0_unit:
		var player_target = null
		
		# Find target: Column 1 first, then Column 2 (only if ranged)
		if column_1_unit:
			player_target = column_1_unit
		elif column_2_unit and column_0_unit.attack_range == "ranged":
			# Only ranged units can attack column 2 (spawn position)
			player_target = column_2_unit
		
		if player_target:
			print("\n=== Lane %d Combat ===" % lane_index)
			combat_happened = true
			
			await column_0_unit.attack_target(player_target)
			
			# Check for overflow damage from player attack
			if player_target and player_target.current_hp < 0:
				overflow_to_enemy = abs(player_target.current_hp)
				print("⚠️ Player overflow: %d damage goes to enemy!" % overflow_to_enemy)
			
			print("=================\n")
	
	# Enemy unit counter-attacks (only from Column 1, and only if still alive)
	if column_1_unit and is_instance_valid(column_1_unit) and column_1_unit.current_hp > 0:
		if column_0_unit:
			print("\n=== Lane %d Enemy Counter ===" % lane_index)
			await column_1_unit.attack_target(column_0_unit)
			
			# Check for overflow damage from enemy attack
			if column_0_unit and column_0_unit.current_hp < 0:
				overflow_to_player = abs(column_0_unit.current_hp)
				print("⚠️ Enemy overflow: %d damage goes to player!" % overflow_to_player)
			
			print("=================\n")
		else:
			# No player unit to block - enemy attacks player directly
			print("Lane %d: %s attacks player directly for %d damage!" % [lane_index, column_1_unit.card_data.card_name, column_1_unit.current_attack])
			await column_1_unit.play_attack_animation()
			overflow_to_player = column_1_unit.current_attack
	
	# If player unit exists but didn't engage in combat - direct damage to enemy HP
	if column_0_unit and not combat_happened:
		print("Lane %d: %s attacks enemy directly for %d damage!" % [lane_index, column_0_unit.card_data.card_name, column_0_unit.current_attack])
		await column_0_unit.play_attack_animation()
		overflow_to_enemy = column_0_unit.current_attack
	
	return [overflow_to_player, overflow_to_enemy]

func advance_enemies():
	"""Move enemies forward one column (column 2 -> column 1)"""
	# Only advance from column 2 to column 1 if column 1 is empty
	if column_2_unit and not column_1_unit:
		print("Lane %d: %s advances from spawn to battle position!" % [lane_index, column_2_unit.card_data.card_name])
		
		# Move the unit reference
		column_1_unit = column_2_unit
		column_2_unit = null
		
		# Update unit's column position
		column_1_unit.set_column(1)
		
		# Animate movement to new position
		if column_1_spawn:
			var tween = create_tween()
			tween.tween_property(column_1_unit, "position", column_1_spawn.position, 0.5)

func has_player_unit() -> bool:
	"""Check if there's a player unit in this lane"""
	return column_0_unit != null

func get_player_unit() -> Unit:
	"""Get player unit in column 0"""
	return column_0_unit

func has_enemy_unit() -> bool:
	"""Check if there's an enemy unit in this lane (any column)"""
	return column_1_unit != null or column_2_unit != null

func get_enemy_in_column(column: int) -> Unit:
	"""Get enemy unit in specified column"""
	if column == 1:
		return column_1_unit
	elif column == 2:
		return column_2_unit
	return null

func is_empty() -> bool:
	"""Check if lane is completely empty"""
	return column_0_unit == null and column_1_unit == null and column_2_unit == null

func get_lane_state() -> String:
	"""Get debug info about this lane"""
	var col0_info = "Empty"
	var col1_info = "Empty"
	var col2_info = "Empty"
	
	if column_0_unit:
		col0_info = column_0_unit.get_unit_info()
	if column_1_unit:
		col1_info = column_1_unit.get_unit_info()
	if column_2_unit:
		col2_info = column_2_unit.get_unit_info()
	
	return "Lane %d | Player(C0): %s | Enemy(C1): %s | Enemy(C2): %s" % [lane_index, col0_info, col1_info, col2_info]

func is_point_in_player_zone(point: Vector2) -> bool:
	"""Check if a global position is within this lane's player drop zone (column 0)"""
	if not player_drop_zone:
		return false
	
	var rect = player_drop_zone.get_global_rect()
	return rect.has_point(point)

func _on_drop_zone_hover():
	"""Visual feedback when hovering over drop zone"""
	if player_drop_zone and not column_0_unit:
		player_drop_zone.color = Color(0.3, 0.5, 0.3, 0.7)  # Brighter green

func _on_drop_zone_exit():
	"""Reset visual when leaving drop zone"""
	if player_drop_zone:
		if column_0_unit:
			player_drop_zone.color = Color(0.2, 0.3, 0.2, 0.3)  # Dimmer when occupied
		else:
			player_drop_zone.color = Color(0.2, 0.3, 0.2, 0.5)  # Normal
