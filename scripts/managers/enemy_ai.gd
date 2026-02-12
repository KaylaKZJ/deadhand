extends Node
class_name EnemyAI
## Simple AI that spawns enemies from deck

var deck_manager: DeckManager
const MAX_ENEMIES_ON_BOARD: int = 5  # Maximum enemies allowed on board at once
const MAX_SPAWNS_PER_TURN: int = 2 # Maximum new enemies spawned per turn

func initialize(deck_mgr: DeckManager):
	"""Set up enemy AI with deck manager reference"""
	deck_manager = deck_mgr

func spawn_enemies(lanes: Array[Lane]):
	"""Spawn enemies to column 2 (spawn position) in empty lanes"""
	if not deck_manager:
		print("ERROR: EnemyAI not initialized with DeckManager!")
		return
	
	# Count current enemies (check both column 1 and column 2)
	var enemy_count = 0
	for lane in lanes:
		if lane.has_enemy_unit():
			enemy_count += 1
	
	print("\n=== ENEMY SPAWN DEBUG ===")
	print("Total lanes: %d" % lanes.size())
	print("Current enemies on board: %d" % enemy_count)
	
	# Calculate how many we can spawn (limited by both board space AND per-turn limit)
	var board_space_available = MAX_ENEMIES_ON_BOARD - enemy_count
	var spawn_slots_available = min(board_space_available, MAX_SPAWNS_PER_TURN)
	var spawned_this_turn = 0
	
	print("Board space available: %d" % board_space_available)
	print("Can spawn up to: %d enemies (per-turn limit)" % spawn_slots_available)
	
	# Get all lanes where column 2 is empty (can spawn)
	var available_lanes: Array[Lane] = []
	for lane in lanes:
		if lane.get_enemy_in_column(2) == null:  # Column 2 must be empty
			available_lanes.append(lane)
	
	# Shuffle the available lanes for random placement
	available_lanes.shuffle()
	
	print("Found %d lanes with empty column 2 (shuffled)" % available_lanes.size())
	
	# Spawn enemies to random available lanes at column 2
	for lane in available_lanes:
		if spawned_this_turn >= spawn_slots_available:
			print("  -> Reached spawn limit (%d/%d)" % [spawned_this_turn, spawn_slots_available])
			break
		
		# Try to draw an enemy card
		var enemy_card = deck_manager.draw_enemy_card()
		if enemy_card:
			lane.summon_enemy_unit(enemy_card, 2)  # Spawn at column 2!
			spawned_this_turn += 1
			print("  -> Spawned %s to Lane %d (column 2)" % [enemy_card.card_name, lane.lane_index])
		else:
			print("  -> Enemy deck is empty!")
			break
	
	print("Total spawned this turn: %d" % spawned_this_turn)
	print("=========================\n")
