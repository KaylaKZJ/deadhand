extends Node2D
class_name Lane
## Manages one lane of combat (player slot + enemy slot)

signal unit_summoned(unit: Unit, is_player: bool)
signal unit_died(unit: Unit, is_player: bool)

var lane_index: int = 0
var player_unit: Unit = null
var enemy_unit: Unit = null
var deck_manager: DeckManager = null  # Reference to deck manager for discarding

# References to spawn positions
@onready var player_spawn_position: Marker2D = $PlayerSpawn
@onready var enemy_spawn_position: Marker2D = $EnemySpawn
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
	"""Summon a player unit to this lane"""
	if player_unit != null:
		print("Lane %d already has a player unit!" % lane_index)
		return null
	
	var unit = _create_unit(unit_data, true)
	player_unit = unit
	
	# Dim the drop zone when occupied
	if player_drop_zone:
		player_drop_zone.color = Color(0.2, 0.3, 0.2, 0.3)
		if player_drop_zone.has_node("PlayerZoneLabel"):
			player_drop_zone.get_node("PlayerZoneLabel").visible = false
	
	unit_summoned.emit(unit, true)
	return unit

func summon_enemy_unit(unit_data: BodyCardResource) -> Unit:
	"""Summon an enemy unit to this lane"""
	if enemy_unit != null:
		print("Lane %d already has an enemy unit!" % lane_index)
		return null
	
	var unit = _create_unit(unit_data, false)
	enemy_unit = unit
	
	# Visual spawn effect - flash the unit
	if unit and unit.background:
		var original_color = unit.background.color
		unit.background.color = Color.YELLOW  # Flash yellow
		await get_tree().create_timer(0.3).timeout
		if unit and is_instance_valid(unit) and unit.background:
			unit.background.color = original_color
	
	unit_summoned.emit(unit, false)
	return unit

func _create_unit(unit_data: BodyCardResource, is_player: bool) -> Unit:
	"""Create a unit instance"""
	# Load unit scene (we'll create this next)
	var unit_scene = load("res://scenes/cards/unit_on_board.tscn")
	var unit: Unit = unit_scene.instantiate()
	
	# Position the unit
	if is_player:
		if player_spawn_position:
			unit.position = player_spawn_position.position
		else:
			unit.position = Vector2(-100, 0)  # Default player position
	else:
		if enemy_spawn_position:
			unit.position = enemy_spawn_position.position
		else:
			unit.position = Vector2(100, 0)  # Default enemy position
	
	add_child(unit)
	unit.initialize(unit_data, is_player, lane_index)
	unit.died.connect(_on_unit_died)
	
	return unit

func _on_unit_died(unit: Unit):
	"""Handle when a unit in this lane dies"""
	if unit == player_unit:
		player_unit = null
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
	elif unit == enemy_unit:
		enemy_unit = null
		# Discard the enemy card
		if deck_manager and unit.card_data:
			deck_manager.discard_enemy_card(unit.card_data)
			print("Enemy card discarded: %s" % unit.card_data.card_name)
		unit_died.emit(unit, false)

func resolve_combat():
	"""Resolve combat in this lane (player attacks first). Returns [overflow_to_player, overflow_to_enemy]."""
	var overflow_to_player = 0
	var overflow_to_enemy = 0
	
	if player_unit and enemy_unit:
		# Player attacks first!
		print("\n=== Lane %d Combat ===" % lane_index)
		
		player_unit.attack_target(enemy_unit)
		
		# Enemy counter-attacks only if still alive (HP > 0)
		# Note: We check current_hp because unit might be queued for deletion but still valid
		if enemy_unit and is_instance_valid(enemy_unit) and enemy_unit.current_hp > 0:
			var player_hp_before = player_unit.current_hp
			enemy_unit.attack_target(player_unit)
			
			# If player unit died, check for overflow damage
			if not player_unit or not is_instance_valid(player_unit):
				var overkill = enemy_unit.current_attack - player_hp_before
				if overkill > 0:
					overflow_to_player = overkill
					print("⚠️ Overflow damage: %d damage goes to player!" % overflow_to_player)
		
		print("=================\n")
	elif not player_unit and enemy_unit:
		# No player unit to block - enemy attacks player directly
		overflow_to_player = enemy_unit.current_attack
		print("Lane %d: %s attacks player directly for %d damage!" % [lane_index, enemy_unit.card_data.card_name, overflow_to_player])
	elif player_unit and not enemy_unit:
		# Player unit has no blocker - attacks enemy directly
		overflow_to_enemy = player_unit.current_attack
		print("Lane %d: %s attacks enemy directly for %d damage!" % [lane_index, player_unit.card_data.card_name, overflow_to_enemy])
	
	return [overflow_to_player, overflow_to_enemy]

func has_player_unit() -> bool:
	"""Check if there's a player unit in this lane"""
	return player_unit != null

func has_enemy_unit() -> bool:
	"""Check if there's an enemy unit in this lane"""
	return enemy_unit != null

func is_empty() -> bool:
	"""Check if lane is completely empty"""
	return player_unit == null and enemy_unit == null

func get_lane_state() -> String:
	"""Get debug info about this lane"""
	var player_info = "Empty"
	var enemy_info = "Empty"
	
	if player_unit:
		player_info = player_unit.get_unit_info()
	if enemy_unit:
		enemy_info = enemy_unit.get_unit_info()
	
	return "Lane %d | Player: %s | Enemy: %s" % [lane_index, player_info, enemy_info]

func is_point_in_player_zone(point: Vector2) -> bool:
	"""Check if a global position is within this lane's player drop zone"""
	if not player_drop_zone:
		return false
	
	var rect = player_drop_zone.get_global_rect()
	return rect.has_point(point)

func _on_drop_zone_hover():
	"""Visual feedback when hovering over drop zone"""
	if player_drop_zone and not player_unit:
		player_drop_zone.color = Color(0.3, 0.5, 0.3, 0.7)  # Brighter green

func _on_drop_zone_exit():
	"""Reset visual when leaving drop zone"""
	if player_drop_zone:
		if player_unit:
			player_drop_zone.color = Color(0.2, 0.3, 0.2, 0.3)  # Dimmer when occupied
		else:
			player_drop_zone.color = Color(0.2, 0.3, 0.2, 0.5)  # Normal
