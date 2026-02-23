extends Node
class_name EnemyAI
## Advanced AI with distinct personalities and strategic behavior

enum Personality {
	AGGRESSIVE,   # Spread pressure across all lanes
	DEFENSIVE,    # Stack enemies, create chokepoints
	MIRROR,       # Contest player lanes
	PUNISHER,     # Adapt to game state
	WAVE,         # Scripted progression
	CHAOTIC       # Random favorites within a game
}

# ============ PLAYTESTING DEBUG ============
# Set this to force a specific AI personality for testing
# Leave as -1 for random selection (normal gameplay)
# Examples:
#   @export var debug_force_personality: int = Personality.AGGRESSIVE
#   @export var debug_force_personality: int = Personality.MIRROR
#   @export var debug_force_personality: int = -1  # Random (default)
@export var debug_force_personality: int = Personality.AGGRESSIVE
# ===========================================

# Constants
const MAX_ENEMIES_ON_BOARD: int = 5
const MAX_SPAWNS_PER_TURN: int = 2
const REPEAT_PENALTY: float = 0.3

# Core state
var deck_manager: DeckManager
var combat_manager: CombatManager
var current_personality: Personality
var game_turn: int = 0
var spawn_history: Array[String] = []

# Randomization
var combat_seed: int
var rng: RandomNumberGenerator

# Chaotic AI favorites
var favorite_units: Array[String] = []

# Available enemy cards (cached from deck)
var available_enemy_types: Dictionary = {}  # card_name -> BodyCardResource

func initialize(deck_mgr: DeckManager, combat_mgr: CombatManager = null):
	"""Set up enemy AI with deck manager reference"""
	deck_manager = deck_mgr
	combat_manager = combat_mgr
	
	# Initialize seeded RNG for this combat
	combat_seed = Time.get_ticks_msec()
	rng = RandomNumberGenerator.new()
	rng.seed = combat_seed
	
	# Cache available enemy types from deck
	_cache_enemy_types()
	
	# Select personality for this game
	select_personality()

func _cache_enemy_types():
	"""Cache all unique enemy card types from the deck"""
	available_enemy_types.clear()
	
	# Get all enemy cards from deck manager
	if deck_manager and deck_manager.enemy_draw_pile:
		for card in deck_manager.enemy_draw_pile:
			if card is BodyCardResource:
				available_enemy_types[card.card_name] = card
	
	print("[EnemyAI] Cached %d unique enemy types" % available_enemy_types.size())

func select_personality():
	"""Randomly choose AI personality for this combat"""
	# Check for debug override
	if debug_force_personality >= 0 and debug_force_personality < Personality.size():
		current_personality = debug_force_personality
		print("[EnemyAI] 🔧 DEBUG MODE: Forced personality to %s" % _get_personality_name())
	else:
		# Normal random selection
		var personalities = [
			Personality.AGGRESSIVE,
			Personality.DEFENSIVE,
			Personality.MIRROR,
			Personality.PUNISHER,
			Personality.WAVE,
			Personality.CHAOTIC
		]
		
		current_personality = personalities.pick_random()
		print("[EnemyAI] Personality selected: %s" % _get_personality_name())
	
	# Initialize personality-specific data
	if current_personality == Personality.CHAOTIC:
		_select_favorite_units()

func _select_favorite_units():
	"""For CHAOTIC personality, pick 2-3 favorite enemy types"""
	favorite_units.clear()
	var unit_names = available_enemy_types.keys()
	
	if unit_names.size() == 0:
		return
	
	# Pick 2-3 favorites
	var num_favorites = rng.randi_range(2, min(3, unit_names.size()))
	unit_names.shuffle()
	
	for i in num_favorites:
		favorite_units.append(unit_names[i])
	
	print("[EnemyAI] Chaotic favorites: %s" % str(favorite_units))

func spawn_enemies(lanes: Array[Lane]):
	"""Main entry point - spawn enemies based on personality"""
	if not deck_manager:
		print("ERROR: EnemyAI not initialized with DeckManager!")
		return
	
	game_turn += 1
	
	# Count current enemies
	var enemy_count = _count_enemies_on_board(lanes)
	var board_space = MAX_ENEMIES_ON_BOARD - enemy_count
	var max_spawns = min(board_space, MAX_SPAWNS_PER_TURN)
	
	print("\n=== ENEMY SPAWN (Turn %d | %s) ===" % [game_turn, _get_personality_name()])
	print("Enemies on board: %d/%d" % [enemy_count, MAX_ENEMIES_ON_BOARD])
	print("Can spawn: %d enemies" % max_spawns)
	
	var spawned_count = 0
	
	# Spawn up to max_spawns enemies
	while spawned_count < max_spawns:
		var lane = choose_spawn_lane(lanes)
		if lane == null:
			print("  -> No valid lanes available")
			break
		
		var unit_card = choose_enemy_unit(lane)
		if unit_card == null:
			print("  -> No enemy cards available")
			break
		
		# Spawn the unit with current wave number as level
		var level = combat_manager.wave_number if combat_manager else 1
		# Use lane.get_spawn_column() so single-column mode places enemies into column 1
		var spawn_col = lane.get_spawn_column()
		lane.summon_enemy_unit(unit_card, spawn_col, level)
		spawned_count += 1
		_update_spawn_history(unit_card.card_name)
		
		print("  -> Spawned %s to Lane %d" % [unit_card.card_name, lane.lane_index])
	
	print("Total spawned: %d" % spawned_count)
	print("================================\n")

func choose_spawn_lane(lanes: Array[Lane]) -> Lane:
	"""Choose which lane to spawn in based on personality"""
	var valid_lanes = []
	var weights = []
	
	match current_personality:
		Personality.AGGRESSIVE:
			# Prefer empty lanes (spread wide)
			for lane in lanes:
				if lane.has_space_for_spawn():
					var weight = 1.0
					if lane.is_empty():
						weight = 3.0  # 3x more likely
					valid_lanes.append(lane)
					weights.append(weight)
		
		Personality.DEFENSIVE:
			# Prefer lanes with existing enemies (stack up)
			for lane in lanes:
				if lane.has_space_for_spawn():
					var weight = 1.0
					if lane.has_enemy_unit():
						weight = 5.0  # 5x more likely
					elif lane.has_player_unit():
						weight = 2.0  # Contest player
					valid_lanes.append(lane)
					weights.append(weight)
		
		Personality.MIRROR:
			# Prefer lanes with player units
			for lane in lanes:
				if lane.has_space_for_spawn():
					var weight = 1.0
					if lane.has_player_unit():
						weight = 4.0  # 4x more likely
					valid_lanes.append(lane)
					weights.append(weight)
		
		Personality.PUNISHER:
			# Adapt to HP situation
			var player_hp = _get_player_hp()
			for lane in lanes:
				if lane.has_space_for_spawn():
					var weight = 1.0
					if player_hp > 15:
						# Push damage - prefer empty lanes
						if lane.is_empty():
							weight = 3.0
					else:
						# Protect HP - prefer defensive positions
						if lane.has_enemy_unit():
							weight = 4.0
					valid_lanes.append(lane)
					weights.append(weight)
		
		Personality.WAVE, Personality.CHAOTIC:
			# Random lane selection
			for lane in lanes:
				if lane.has_space_for_spawn():
					valid_lanes.append(lane)
					weights.append(1.0)
	
	if valid_lanes.is_empty():
		return null
	
	return _pick_weighted_random(valid_lanes, weights)

func choose_enemy_unit(lane: Lane) -> BodyCardResource:
	"""Choose which enemy type to spawn based on personality"""
	var weights = {}
	
	match current_personality:
		Personality.AGGRESSIVE:
			weights = _get_aggressive_weights()
		
		Personality.DEFENSIVE:
			weights = _get_defensive_weights()
		
		Personality.MIRROR:
			weights = _get_mirror_weights(lane)
		
		Personality.PUNISHER:
			weights = _get_punisher_weights()
		
		Personality.WAVE:
			weights = _get_wave_weights()
		
		Personality.CHAOTIC:
			weights = _get_chaotic_weights()
	
	# Apply history penalty
	weights = _apply_history_penalty(weights)
	
	# Wave gate: remove any enemy whose min_wave hasn't been reached yet
	var current_wave = combat_manager.wave_number if combat_manager else 1
	for unit_name in weights.keys():
		var card: BodyCardResource = available_enemy_types[unit_name]
		if card.min_wave > current_wave:
			weights.erase(unit_name)
	
	# Convert to arrays and select
	var units = []
	var weight_values = []
	
	for unit_name in weights.keys():
		if unit_name in available_enemy_types:
			units.append(available_enemy_types[unit_name])
			weight_values.append(weights[unit_name])
	
	if units.is_empty():
		# Fallback: draw any card from deck
		return deck_manager.draw_enemy_card()
	
	return _pick_weighted_random(units, weight_values)

# Personality-specific weight functions
func _get_aggressive_weights() -> Dictionary:
	"""High-attack units preferred - dynamically weights by attack stat"""
	var weights = {}
	
	for unit_name in available_enemy_types.keys():
		var card: BodyCardResource = available_enemy_types[unit_name]
		# Weight by attack value - higher attack = higher weight
		weights[unit_name] = float(card.attack) / 10.0  # Normalize to 0.1-0.5 range
	
	return _normalize_weights(weights)

func _get_defensive_weights() -> Dictionary:
	"""High-HP units preferred - dynamically weights by HP stat"""
	var weights = {}
	
	for unit_name in available_enemy_types.keys():
		var card: BodyCardResource = available_enemy_types[unit_name]
		# Weight by HP value - higher HP = higher weight
		weights[unit_name] = float(card.hp) / 10.0  # Normalize to 0.1-0.5 range
	
	return _normalize_weights(weights)

func _get_mirror_weights(lane: Lane) -> Dictionary:
	"""Match player unit strength - dynamically selects closest stat match"""
	var player_unit = lane.get_player_unit()
	
	if player_unit == null:
		# Default to weakest unit
		return _get_weakest_unit_weights()
	
	var target_total = player_unit.hp + player_unit.attack
	var weights = {}
	
	# Weight based on how close each enemy is to player's total stats
	for unit_name in available_enemy_types.keys():
		var card: BodyCardResource = available_enemy_types[unit_name]
		var enemy_total = card.hp + card.attack
		
		# Inverse distance - closer match = higher weight
		var difference = abs(enemy_total - target_total)
		var similarity = 1.0 / (1.0 + difference)  # Range: 0.0 to 1.0
		weights[unit_name] = similarity
	
	return _normalize_weights(weights)

func _get_punisher_weights() -> Dictionary:
	"""Adapt to HP situation - aggressive when ahead, defensive when behind"""
	var player_hp = _get_player_hp()
	
	if player_hp > 15:
		# Aggressive - prefer high attack
		return _get_aggressive_weights()
	else:
		# Defensive - prefer high HP
		return _get_defensive_weights()

func _get_wave_weights() -> Dictionary:
	"""Scripted progression by turn - weakest to strongest"""
	# Sort enemies by total stats (HP + Attack)
	var sorted_enemies = []
	for unit_name in available_enemy_types.keys():
		var card: BodyCardResource = available_enemy_types[unit_name]
		var total_stats = card.hp + card.attack
		sorted_enemies.append({"name": unit_name, "stats": total_stats})
	
	# Sort by stats (weakest first)
	sorted_enemies.sort_custom(func(a, b): return a["stats"] < b["stats"])
	
	# Select based on turn progression
	var phase_index = 0
	if game_turn <= 3:
		phase_index = 0  # Weakest enemies
	elif game_turn <= 6:
		phase_index = min(1, sorted_enemies.size() - 1)  # Weak-medium
	elif game_turn <= 9:
		phase_index = min(2, sorted_enemies.size() - 1)  # Medium-strong
	else:
		phase_index = sorted_enemies.size() - 1  # Strongest
	
	# Create weights heavily favoring the phase-appropriate strength level
	var weights = {}
	for i in sorted_enemies.size():
		if i == phase_index:
			weights[sorted_enemies[i]["name"]] = 0.70  # 70% for target strength
		elif abs(i - phase_index) == 1:
			weights[sorted_enemies[i]["name"]] = 0.20  # 20% for adjacent
		else:
			weights[sorted_enemies[i]["name"]] = 0.05  # 5% for others
	
	return _normalize_weights(weights)

func _get_chaotic_weights() -> Dictionary:
	"""Use favorite units 70% of the time"""
	var weights = {}
	
	# 70% chance for favorites
	for unit_name in favorite_units:
		weights[unit_name] = 0.70 / favorite_units.size()
	
	# 30% chance for others
	var others_weight = 0.30 / max(1, available_enemy_types.size() - favorite_units.size())
	for unit_name in available_enemy_types.keys():
		if unit_name not in favorite_units:
			weights[unit_name] = others_weight
	
	return weights

# Utility functions
func _pick_weighted_random(options: Array, weights: Array):
	"""Select random element from options using weights"""
	if options.is_empty():
		return null
	
	var total_weight = 0.0
	for w in weights:
		total_weight += w
	
	if total_weight <= 0:
		return options.pick_random()
	
	var roll = rng.randf() * total_weight
	var cumulative = 0.0
	
	for i in options.size():
		cumulative += weights[i]
		if roll < cumulative:
			return options[i]
	
	return options[-1]  # Fallback

func _apply_history_penalty(weights: Dictionary) -> Dictionary:
	"""Reduce weight of recently spawned units"""
	var modified = weights.duplicate()
	
	for unit_name in spawn_history:
		if unit_name in modified:
			modified[unit_name] *= REPEAT_PENALTY
	
	return modified

func _update_spawn_history(unit_name: String):
	"""Track spawned unit, keep only last 3"""
	spawn_history.append(unit_name)
	if spawn_history.size() > 3:
		spawn_history.pop_front()

func _count_enemies_on_board(lanes: Array[Lane]) -> int:
	"""Count total enemies across all lanes"""
	var count = 0
	for lane in lanes:
		if lane.has_enemy_unit():
			count += 1
	return count

func _get_player_hp() -> int:
	"""Get current player HP"""
	if combat_manager:
		return combat_manager.player_hp
	return 20  # Fallback default

func _get_personality_name() -> String:
	"""Get personality name as string"""
	match current_personality:
		Personality.AGGRESSIVE:
			return "AGGRESSIVE"
		Personality.DEFENSIVE:
			return "DEFENSIVE"
		Personality.MIRROR:
			return "MIRROR"
		Personality.PUNISHER:
			return "PUNISHER"
		Personality.WAVE:
			return "WAVE"
		Personality.CHAOTIC:
			return "CHAOTIC"
		_:
			return "UNKNOWN"

func _normalize_weights(weights: Dictionary) -> Dictionary:
	"""Normalize weights to sum to 1.0"""
	var total = 0.0
	for weight in weights.values():
		total += weight
	
	if total <= 0:
		# Equal weights if all are zero
		var equal_weight = 1.0 / max(1, weights.size())
		for key in weights.keys():
			weights[key] = equal_weight
		return weights
	
	# Normalize
	var normalized = {}
	for key in weights.keys():
		normalized[key] = weights[key] / total
	
	return normalized

func _get_weakest_unit_weights() -> Dictionary:
	"""Return weights heavily favoring the weakest unit"""
	var weakest_name = ""
	var weakest_total = 999
	
	for unit_name in available_enemy_types.keys():
		var card: BodyCardResource = available_enemy_types[unit_name]
		var total_stats = card.hp + card.attack
		
		if total_stats < weakest_total:
			weakest_total = total_stats
			weakest_name = unit_name
	
	if weakest_name == "":
		return {}
	
	return {weakest_name: 1.0}
