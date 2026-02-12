extends Node
class_name DeckManager
## Manages two separate draw piles (Body and Equipment) and player's hand

signal cards_drawn(cards: Array[CardBase])
signal hand_updated(hand: Array[CardBase])

# Deck arrays
var body_draw_pile: Array[BodyCardResource] = []
var body_discard_pile: Array[BodyCardResource] = []
var equipment_draw_pile: Array[EquipmentCardResource] = []
var equipment_discard_pile: Array[EquipmentCardResource] = []

# Enemy deck
var enemy_draw_pile: Array[BodyCardResource] = []
var enemy_discard_pile: Array[BodyCardResource] = []

# Player's hand
var hand: Array[CardBase] = []
const MAX_HAND_SIZE: int = 5

func _ready():
	initialize_decks()

func initialize_decks():
	"""Load all card resources and build initial decks with correct quantities"""
	_build_body_pile()
	_build_equipment_pile()
	_build_enemy_pile()
	
	# Shuffle all piles
	body_draw_pile.shuffle()
	equipment_draw_pile.shuffle()
	enemy_draw_pile.shuffle()
	
	print("Decks initialized:")
	print("  Body pile: %d cards" % body_draw_pile.size())
	print("  Equipment pile: %d cards" % equipment_draw_pile.size())
	print("  Enemy pile: %d cards" % enemy_draw_pile.size())

func _build_body_pile():
	"""Build body pile: 6 Skeletons, 3 Zombies, 1 Ghost"""
	var skeleton = load("res://resources/cards/bodies/skeleton.tres") as BodyCardResource
	var zombie = load("res://resources/cards/bodies/zombie.tres") as BodyCardResource
	var ghost = load("res://resources/cards/bodies/ghost.tres") as BodyCardResource
	
	# Add 6 Skeletons
	for i in 6:
		body_draw_pile.append(skeleton)
	
	# Add 3 Zombies
	for i in 3:
		body_draw_pile.append(zombie)
	
	# Add 1 Ghost
	body_draw_pile.append(ghost)

func _build_equipment_pile():
	"""Build equipment pile: 5 Axes, 5 Shields, 3 Helmets, 2 Swords"""
	var axe = load("res://resources/cards/equipment/rusty_axe.tres") as EquipmentCardResource
	var shield = load("res://resources/cards/equipment/shield.tres") as EquipmentCardResource
	var helmet = load("res://resources/cards/equipment/helmet.tres") as EquipmentCardResource
	var leather_helmet = load("res://resources/cards/equipment/leather_helmet.tres") as EquipmentCardResource
	var sword = load("res://resources/cards/equipment/iron_sword.tres") as EquipmentCardResource
	var longbow = load("res://resources/cards/equipment/longbow.tres") as EquipmentCardResource
	var leather_armor = load("res://resources/cards/equipment/leather_armor.tres") as EquipmentCardResource
	
	# Add 5 Axes
	for i in 5:
		equipment_draw_pile.append(axe)
	
	# Add 5 Swords
	for i in 5:
		equipment_draw_pile.append(sword)

	# Add 4 Longbow
	for i in 4:
		equipment_draw_pile.append(longbow)

	# Add 5 Shields
	for i in 5:
		equipment_draw_pile.append(shield)

	# Add 3 Helmets
	for i in 3:
		equipment_draw_pile.append(helmet)
		
	# Add 3 Leather Armor
	for i in 3:
		equipment_draw_pile.append(leather_armor)

	# Add 3 Leather Helmets
	for i in 3:
		equipment_draw_pile.append(leather_helmet)
	


func _build_enemy_pile():
	"""Build enemy pile: 12 Squires, 2 Knights, 4 Barbarians, 2 Thieves"""
	var squire = load("res://resources/cards/enemies/squire.tres") as BodyCardResource
	var knight = load("res://resources/cards/enemies/knight.tres") as BodyCardResource
	var barbarian = load("res://resources/cards/enemies/barbarian.tres") as BodyCardResource
	var thief = load("res://resources/cards/enemies/thief.tres") as BodyCardResource
	
	# Add 12 Squires
	for i in 12:
		enemy_draw_pile.append(squire)
	
	# Add 2 Knights
	for i in 2:
		enemy_draw_pile.append(knight)
	
	# Add 4 Barbarians
	for i in 4:
		enemy_draw_pile.append(barbarian)
	
	# Add 2 Thieves
	for i in 2:
		enemy_draw_pile.append(thief)

func draw_from_pile(pile_type: String) -> Array[CardBase]:
	"""Draw 2 cards from specified pile (body or equipment)"""
	var drawn_cards: Array[CardBase] = []
	
	match pile_type:
		"body":
			for i in 2:
				var card = _draw_single_card(body_draw_pile, body_discard_pile)
				if card:
					drawn_cards.append(card)
		"equipment":
			for i in 2:
				var card = _draw_single_card(equipment_draw_pile, equipment_discard_pile)
				if card:
					drawn_cards.append(card)
		_:
			print("ERROR: Invalid pile type: " + pile_type)
	
	# Add to hand
	for card in drawn_cards:
		if hand.size() < MAX_HAND_SIZE:
			hand.append(card)
		else:
			print("Hand full! Discarding: " + card.card_name)
	
	cards_drawn.emit(drawn_cards)
	hand_updated.emit(hand)
	return drawn_cards

func draw_enemy_card() -> BodyCardResource:
	"""Draw 1 card from enemy pile"""
	return _draw_single_card(enemy_draw_pile, enemy_discard_pile)

func _draw_single_card(draw_pile: Array, discard_pile: Array):
	"""Draw one card from a pile, reshuffling discard if needed"""
	# If draw pile empty, reshuffle discard
	if draw_pile.is_empty():
		if discard_pile.is_empty():
			print("Both draw and discard piles empty!")
			return null
		draw_pile.append_array(discard_pile)
		discard_pile.clear()
		draw_pile.shuffle()
		print("Reshuffled discard pile into draw pile")
	
	return draw_pile.pop_back()

func discard_card(card: CardBase):
	"""Remove card from hand and add to appropriate discard pile"""
	hand.erase(card)
	
	if card is BodyCardResource:
		body_discard_pile.append(card)
	elif card is EquipmentCardResource:
		equipment_discard_pile.append(card)
	
	hand_updated.emit(hand)

func discard_enemy_card(card: BodyCardResource):
	"""Add enemy card to enemy discard pile"""
	enemy_discard_pile.append(card)

func get_hand_cards() -> Array[CardBase]:
	"""Get current hand"""
	return hand

func get_hand_size() -> int:
	"""Get current hand size"""
	return hand.size()

func has_room_in_hand() -> bool:
	"""Check if there's room in hand for more cards"""
	return hand.size() < MAX_HAND_SIZE
