extends Node
class_name CombatManager
## Manages combat flow, turn phases, win/loss conditions, and player XP/stat progression

signal turn_started(turn_number: int)
signal phase_changed(phase: String)
signal combat_resolved()
signal game_won()
signal game_lost()
signal level_up(new_level: int, stat_points_gained: int)
signal xp_gained(amount: int, current_xp: int, xp_for_next_level: int)
signal stat_allocated(stat_name: String, new_value: int)

enum Phase {
	DRAW,
	PLAY,
	ADVANCE,   # New phase: enemies advance from column 2 to column 1
	COMBAT,
	CLEANUP
}

var current_phase: Phase = Phase.DRAW
var turn_number: int = 0
var wave_number: int = 1  # Current wave (increases each time enemies are defeated)
var difficulty_multiplier: float = 1.0  # Scales enemy HP/ATK each wave

# Player HP
var player_hp: int = 20
var max_player_hp: int = 20

# Enemy HP
var enemy_hp: int = 40
var max_enemy_hp: int = 40

# Player progression
var player_xp: int = 0
var player_level: int = 1
var player_atk: int = 0
var player_def: int = 0
var player_vit: int = 0
var unspent_stat_points: int = 0
var enemies_killed_this_wave: int = 0  # For future stats/achievements

# References
var deck_manager: DeckManager
var lanes: Array[Lane] = []
var enemy_ai: Node

# State
var can_draw_this_turn: bool = true
var waiting_for_player: bool = false

func _ready():
	# Get references (will be set up by main scene)
	pass

func initialize(deck_mgr: DeckManager, lane_array: Array[Lane], ai: Node):
	"""Set up the combat manager with all required references"""
	deck_manager = deck_mgr
	lanes = lane_array
	enemy_ai = ai
	
	# If enemy_ai is EnemyAI class, pass self reference for HP tracking
	if enemy_ai is EnemyAI:
		enemy_ai.combat_manager = self
	
	# Connect lane unit_died signals to award XP for enemy kills
	for lane in lanes:
		lane.unit_died.connect(_on_unit_died_in_lane)
	
	print("CombatManager initialized with %d lanes" % lanes.size())

func start_game():
	"""Begin the first turn"""
	turn_number = 0
	wave_number = 1
	difficulty_multiplier = 1.0
	player_hp = max_player_hp
	enemy_hp = max_enemy_hp
	
	# Draw initial hand: 3 body cards, 4 equipment cards
	print("\n\n========== GAME START ==========")
	print("🌊 WAVE %d | Difficulty: %.1fx" % [wave_number, difficulty_multiplier])
	print("Drawing initial hand: 3 body + 4 equipment cards")
	_draw_initial_hand()
	
	# Start with enemy turn (cleanup phase to spawn enemies)
	print("Enemies take the first turn!\n")
	enter_cleanup_phase()

func _draw_initial_hand():
	"""Draw starting hand using auto-draw system"""
	_auto_draw_hand()
	print("Initial hand drawn: %d cards total" % deck_manager.hand.size())

func start_turn():
	"""Begin a new turn"""
	turn_number += 1
	
	print("\n\n========== TURN %d ==========" % turn_number)
	turn_started.emit(turn_number)
	
	# Auto-draw 5 new cards
	print("Auto-drawing 5 cards...")
	_auto_draw_hand()
	
	# Go directly to play phase
	enter_play_phase()

func _auto_draw_hand():
	"""Auto-draw cards to fill hand to 7 cards (mix of body and equipment)"""
	var cards_needed = deck_manager.MAX_HAND_SIZE - deck_manager.hand.size()
	
	# Draw cards with 3:4 body:equipment ratio
	# Pattern: B-E-B-E-B-E-E for initial 7 cards
	for i in cards_needed:
		var card
		# First 5 cards alternate (B-E-B-E-B), last 2 are equipment (E-E)
		if i < 5 and i % 2 == 0:
			# Draw body card (positions 0, 2, 4)
			card = deck_manager._draw_single_card(deck_manager.body_draw_pile, deck_manager.body_discard_pile)
		else:
			# Draw equipment card (positions 1, 3, 5, 6)
			card = deck_manager._draw_single_card(deck_manager.equipment_draw_pile, deck_manager.equipment_discard_pile)
		
		if card:
			deck_manager.hand.append(card)
	
	# Emit signal to update UI
	deck_manager.hand_updated.emit(deck_manager.hand)
	print("Drew %d cards - hand now has %d cards" % [cards_needed, deck_manager.hand.size()])

func on_pile_selected(pile_type: String):
	"""Player chose which pile to draw from"""
	if current_phase != Phase.DRAW:
		print("ERROR: Can only draw during DRAW phase!")
		return
	
	if not can_draw_this_turn:
		print("ERROR: Already drew this turn!")
		return
	
	# Draw 2 cards
	var drawn_cards = deck_manager.draw_from_pile(pile_type)
	print("Drew %d cards from %s pile" % [drawn_cards.size(), pile_type])
	
	can_draw_this_turn = false
	enter_play_phase()

func enter_play_phase():
	"""Enter the play phase where player can summon and equip"""
	current_phase = Phase.PLAY
	phase_changed.emit("PLAY")
	print("\n--- PLAY PHASE ---")
	print("Summon units or equip items. Click 'End Turn' when ready.")
	waiting_for_player = true

func on_card_played(card: CardBase, target_lane_index: int, target_unit: Unit = null) -> bool:
	"""Handle when player plays a card"""
	if current_phase != Phase.PLAY:
		print("ERROR: Can only play cards during PLAY phase!")
		return false
	
	var success = false
	
	if card is BodyCardResource:
		# Summon unit to lane
		success = summon_unit_to_lane(card, target_lane_index, true)
	elif card is EquipmentCardResource:
		# Equip to target unit
		if target_unit:
			success = equip_unit(card, target_unit)
		else:
			print("ERROR: Equipment needs a target unit!")
			return false
	
	if success:
		# Remove card from hand
		deck_manager.discard_card(card)
		print("Card played successfully!")
	
	return success

func summon_unit_to_lane(card_data: BodyCardResource, lane_index: int, is_player: bool) -> bool:
	"""Summon a unit to the specified lane"""
	if lane_index < 0 or lane_index >= lanes.size():
		print("ERROR: Invalid lane index %d" % lane_index)
		return false
	
	var lane = lanes[lane_index]
	
	if is_player:
		if lane.has_player_unit():
			print("ERROR: Lane %d already has a player unit!" % lane_index)
			return false
		lane.summon_player_unit(card_data)
	else:
		if lane.has_enemy_unit():
			print("ERROR: Lane %d already has an enemy unit!" % lane_index)
			return false
		lane.summon_enemy_unit(card_data)
	
	return true

func equip_unit(equipment: EquipmentCardResource, unit: Unit) -> bool:
	"""Equip an item to a unit"""
	if not unit:
		return false
	
	return unit.equip(equipment)

func end_turn():
	"""Player ends their turn"""
	if current_phase != Phase.PLAY:
		print("ERROR: Can only end turn during PLAY phase!")
		return
	
	# Auto-discard all remaining cards in hand
	if deck_manager.hand.size() > 0:
		print("Discarding %d unplayed cards" % deck_manager.hand.size())
		var cards_to_discard = deck_manager.hand.duplicate()
		for card in cards_to_discard:
			deck_manager.discard_card(card)
	
	# Combat happens AFTER discarding
	enter_combat_phase()

func enter_advance_phase():
	"""Enemies advance from spawn (column 2) to battle position (column 1)"""
	current_phase = Phase.ADVANCE
	phase_changed.emit("ADVANCE")
	print("\n--- ADVANCE PHASE ---")
	
	# Move all enemies forward
	for lane in lanes:
		lane.advance_enemies()
	
	# Short delay to see the movement
	await get_tree().create_timer(0.8).timeout
	
	# After advancing, go to cleanup (spawn new enemies)
	enter_cleanup_phase()

func enter_combat_phase():
	"""Resolve combat in all lanes"""
	current_phase = Phase.COMBAT
	phase_changed.emit("COMBAT")
	print("\n--- COMBAT PHASE ---")
	
	# Resolve each lane and collect overflow damage (await for animations)
	for lane in lanes:
		var overflow = await lane.resolve_combat()
		var overflow_to_player = overflow[0]
		var overflow_to_enemy = overflow[1]
		
		if overflow_to_player > 0:
			take_damage(overflow_to_player)
		
		if overflow_to_enemy > 0:
			deal_enemy_damage(overflow_to_enemy)
	
	combat_resolved.emit()
	
	# Check win/loss before advance
	if check_win_condition():
		game_won.emit()
		print("\n🎉 YOU WIN! 🎉")
		return
	
	if check_loss_condition():
		game_lost.emit()
		print("\n💀 YOU LOST! 💀")
		return
	
	# After combat, enemies advance
	enter_advance_phase()

func enter_cleanup_phase():
	"""Enemy AI spawns new units, then start next player turn"""
	current_phase = Phase.CLEANUP
	phase_changed.emit("CLEANUP")
	print("\n--- CLEANUP PHASE ---")
	
	# Wait a moment after advance before spawning (visual clarity)
	await get_tree().create_timer(0.8).timeout
	
	# Enemy AI spawns new units at column 2
	if enemy_ai:
		print("\nEnemy reinforcements arriving...")
		enemy_ai.spawn_enemies(lanes)
	
	# Print board state
	print("\nBoard State:")
	for lane in lanes:
		print("  " + lane.get_lane_state())
	
	# Start next player turn
	await get_tree().create_timer(1.0).timeout
	start_turn()

func check_win_condition() -> bool:
	"""Check if player has defeated all enemies (completed wave)"""
	if enemy_hp <= 0:
		_start_next_wave()
		return false  # Don't end game, continue to next wave
	return false

func _start_next_wave():
	"""Start the next wave with increased difficulty"""
	wave_number += 1
	difficulty_multiplier += 0.15  # +15% difficulty per wave
	enemies_killed_this_wave = 0
	
	# Reset enemy HP to max
	enemy_hp = max_enemy_hp
	
	# Clear remaining enemies from board
	for lane in lanes:
		for slot in [lane.enemy_slot_1, lane.enemy_slot_2]:
			if slot.current_unit:
				slot.current_unit.queue_free()
				slot.current_unit = null
	
	print("\n\n🎉 WAVE %d COMPLETE! 🎉" % (wave_number - 1))
	print("🌊 Starting WAVE %d | Difficulty: %.1fx (Enemies get +%.0f%% HP/ATK)" % [wave_number, difficulty_multiplier, (difficulty_multiplier - 1.0) * 100])
	print("💚 Player HP restored to %d" % max_player_hp)
	
	# Optional: Restore some player HP between waves
	player_hp = min(player_hp + 5, max_player_hp)  # Heal 5 HP between waves
	
	# Continue gameplay - don't emit game_won
	# The cleanup phase will spawn new enemies with scaled stats

func check_loss_condition() -> bool:
	"""Check if player has lost (HP reaches 0)"""
	return player_hp <= 0

func take_damage(amount: int):
	"""Player takes damage (from overflow or direct attacks)"""
	player_hp -= amount
	print("💔 Player took %d damage! (%d HP remaining)" % [amount, player_hp])
	
	# Emit signal for UI update
	phase_changed.emit("HP_UPDATE")

func deal_enemy_damage(amount: int):
	"""Enemy takes damage (from unblocked player units)"""
	enemy_hp -= amount
	print("⚔️ Enemy took %d damage! (%d HP remaining)" % [amount, enemy_hp])
	
	# Emit signal for UI update
	phase_changed.emit("HP_UPDATE")

func get_current_phase_name() -> String:
	"""Get current phase as string"""
	match current_phase:
		Phase.DRAW:
			return "DRAW"
		Phase.PLAY:
			return "PLAY"
		Phase.ADVANCE:
			return "ADVANCE"
		Phase.COMBAT:
			return "COMBAT"
		Phase.CLEANUP:
			return "CLEANUP"
		_:
			return "UNKNOWN"

# ============ XP & PROGRESSION ============

func award_xp(amount: int) -> void:
	"""Award XP to the player and check for level-up"""
	player_xp += amount
	print("⭐ +%d XP! Total: %d XP" % [amount, player_xp])
	xp_gained.emit(amount, player_xp, _xp_for_next_level())
	_check_level_up()

func _check_level_up() -> void:
	"""Check if accumulated XP triggers a level-up"""
	var threshold = _xp_threshold_for_level(player_level)
	while player_xp >= threshold:
		player_level += 1
		unspent_stat_points += 3
		# Full heal on level-up
		player_hp = max_player_hp
		print("🎉 LEVEL UP! Now level %d | HP fully restored | +3 stat points" % player_level)
		level_up.emit(player_level, 3)
		phase_changed.emit("HP_UPDATE")
		threshold = _xp_threshold_for_level(player_level)

func _xp_threshold_for_level(level: int) -> int:
	"""Total XP required to have reached the given level"""
	# Level 1→2: 100, Level 2→3: 300, Level 3→4: 600 ...
	# Sum of 100*N for N in 1..level-1
	var total = 0
	for n in range(1, level):
		total += 100 * n
	return total

func _xp_for_next_level() -> int:
	"""XP needed to reach the next level from the current one"""
	return _xp_threshold_for_level(player_level + 1) - player_xp

func allocate_stat(stat_name: String, amount: int) -> bool:
	"""Spend stat points. Returns true if successful."""
	if amount <= 0 or amount > unspent_stat_points:
		print("CombatManager: Cannot allocate %d points (available: %d)" % [amount, unspent_stat_points])
		return false
	
	match stat_name:
		"atk":
			player_atk += amount
			unspent_stat_points -= amount
			print("📈 ATK increased to %d" % player_atk)
			stat_allocated.emit("atk", player_atk)
		"def":
			player_def += amount
			unspent_stat_points -= amount
			print("🛡️ DEF increased to %d" % player_def)
			stat_allocated.emit("def", player_def)
		"vit":
			var hp_gain = amount * 2
			player_vit += amount
			max_player_hp += hp_gain
			player_hp = min(player_hp + hp_gain, max_player_hp)
			unspent_stat_points -= amount
			print("❤️ VIT increased to %d | Max HP now %d" % [player_vit, max_player_hp])
			stat_allocated.emit("vit", player_vit)
			phase_changed.emit("HP_UPDATE")
		_:
			print("CombatManager: Unknown stat '%s'" % stat_name)
			return false
	
	return true

func get_player_stats() -> Dictionary:
	"""Returns current player progression stats"""
	return {
		"level": player_level,
		"xp": player_xp,
		"xp_to_next": _xp_for_next_level(),
		"atk": player_atk,
		"def": player_def,
		"vit": player_vit,
		"unspent_points": unspent_stat_points
	}

func _input(event: InputEvent) -> void:
	"""Debug shortcuts (only in debug builds)"""
	if not OS.is_debug_build():
		return
	if event.is_action_pressed("debug_add_xp"):
		award_xp(100)
	if event.is_action_pressed("debug_reset_stats"):
		player_atk = 0
		player_def = 0
		player_vit = 0
		unspent_stat_points = 0
		print("🔧 Debug: Stats reset")

func _on_unit_died_in_lane(unit: Unit, is_player_unit: bool) -> void:
	"""Award XP when an enemy unit dies"""
	if not is_player_unit:
		enemies_killed_this_wave += 1
		award_xp(10)
