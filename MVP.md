# DEADHAND - MVP Prototype Plan

**Goal:** Playable 5-lane combat system with dual-deck mechanics  
**Timeline:** Week 1 Prototype  
**Scope:** Core gameplay loop only (no map, no progression, no shop)

---

## 🎯 MVP Objectives

**What We're Building:**
- 5-lane combat board
- Dual draw pile system (Body Pile + Equipment Pile)
- Player turn with draw choice, summon, and equip actions
- Enemy AI that spawns and attacks
- Win/loss conditions for a single battle

**What We're NOT Building:**
- Map navigation
- Soul economy / shop
- Unlocks or meta-progression
- Multiple encounters
- Sound/music
- Fancy animations

---

## 📦 Godot Project Structure

```
dead-hand/
├── project.godot
├── scenes/
│   ├── main.tscn                    # Root scene
│   ├── combat_board.tscn            # 5-lane battlefield
│   ├── ui/
│   │   ├── hand_display.tscn        # Player's hand (5 card slots)
│   │   ├── pile_selector.tscn       # Body/Equipment choice buttons
│   │   └── lane_slot.tscn           # Individual lane slot UI
│   └── cards/
│       ├── card_display.tscn        # Visual card representation
│       └── unit_on_board.tscn       # Unit sprite with HP/ATK display
├── scripts/
│   ├── managers/
│   │   ├── deck_manager.gd          # Handles both draw piles
│   │   ├── combat_manager.gd        # Turn flow + combat resolution
│   │   └── enemy_ai.gd              # Enemy spawn/attack logic
│   ├── card_logic/
│   │   ├── base_card.gd             # Parent class for all cards
│   │   ├── body_card.gd             # Summonable units
│   │   └── equipment_card.gd        # Stat modifiers
│   └── board/
│       ├── lane.gd                  # Manages one lane (player + enemy slot)
│       └── unit.gd                  # Individual unit stats/behavior
├── resources/
│   ├── cards/
│   │   ├── bodies/
│   │   │   ├── skeleton.tres        # BodyCard resource
│   │   │   ├── zombie.tres
│   │   │   └── ghost.tres
│   │   ├── equipment/
│   │   │   ├── rusty_axe.tres       # EquipmentCard resource
│   │   │   ├── shield.tres
│   │   │   └── helmet.tres
│   │   └── enemies/
│   │       ├── knight.tres          # EnemyCard resource
│   │       ├── squire.tres
│   │       ├── barbarian.tres
│   │       └── thief.tres
│   └── card_base.gd                 # Resource script for cards
└── assets/
    ├── sprites/
    │   ├── cards/                   # Card artwork (placeholder colored rects)
    │   └── units/                   # Unit sprites on board (simple shapes)
    └── fonts/
        └── main_font.ttf            # UI text
```

---

## 🃏 Resource-Based Card System

### Base Card Resource (`card_base.gd`)
```gdscript
extends Resource
class_name CardBase

@export var card_name: String
@export var card_type: String  # "body", "equipment", "enemy"
@export var description: String
@export var icon: Texture2D  # Card art (optional for MVP)
```

### Body Card Resource (`body_card_resource.gd`)
```gdscript
extends CardBase
class_name BodyCardResource

@export var hp: int
@export var attack: int
@export var equipment_slots: int  # Max equipment this unit can hold
@export var slot_types: Array[String]  # ["weapon", "armor"] or ["weapon_only"]or ["armour_only"]
```

### Equipment Card Resource (`equipment_card_resource.gd`)
```gdscript
extends CardBase
class_name EquipmentCardResource

@export var equipment_type: String  # "weapon" or "armor"
@export var hp_bonus: int = 0
@export var attack_bonus: int = 0
```

### Enemy Card Resource (Reuses BodyCardResource)
- Enemies are just BodyCards with different textures/names
- No equipment slots for MVP (enemies spawn pre-built)

---

## 📋 Card Data (25 Player Cards + 20 Enemy Cards)

### Player Body Pile (10 Cards)
| Card | HP | ATK | Slots | Rarity | Quantity |
|------|----|----|-------|--------|----------|
| Skeleton | 1 | 1 | 2 (weapon + armor) | Common | 6 |
| Zombie | 3 | 2 | 1 (armor only) | Common | 3 |
| Ghost | 2 | 3 | 1 (weapon only) | Uncommon | 1 |

### Player Equipment Pile (15 Cards)
| Card | Type | HP Bonus | ATK Bonus | Quantity |
|------|------|----------|-----------|----------|
| Rusty Axe | Weapon | 0 | +2 | 5 |
| Shield | Armor | +3 | 0 | 5 |
| Helmet | Armor | +2 | 0 | 3 |
| Iron Sword | Weapon | 0 | +3 | 2 |

### Enemy Deck (20 Cards - AI Draws From This)
| Card | HP | ATK | Quantity |
|------|----|----|----------|
| Squire | 2 | 1 | 8 |
| Knight | 5 | 2 | 6 |
| Barbarian | 4 | 3 | 4 |
| Thief | 3 | 2 | 2 |

---

## 🎮 Core Systems Breakdown

### 1. DeckManager (`deck_manager.gd`)
**Responsibilities:**
- Initialize 2 separate piles (body_pile, equipment_pile)
- Shuffle each pile at start
- Draw cards based on player choice
- Manage discard piles (reshuffled when draw pile empty)
- Track hand size (max 5 cards)

**Key Methods:**
```gdscript
func initialize_decks(body_cards: Array[BodyCardResource], equipment_cards: Array[EquipmentCardResource])
func draw_from_pile(pile_type: String) -> Array[CardBase]  # Returns 2 cards
func discard_card(card: CardBase)
func get_hand_cards() -> Array[CardBase]
```

---

### 2. CombatManager (`combat_manager.gd`)
**Responsibilities:**
- Manage turn phases (Draw → Play → Combat → Cleanup)
- Handle player input (which pile to draw from, which card to play)
- Trigger combat resolution
- Check win/loss conditions

**Turn Flow:**
```
1. DRAW PHASE
   - Show "Draw from Body Pile" / "Draw from Equipment Pile" buttons
   - Player clicks → DeckManager.draw_from_pile(choice)
   - Add 2 cards to hand

2. PLAY PHASE
   - Player can:
     a) Drag Body card to empty lane → Summon unit
     b) Drag Equipment card to existing unit → Equip
   - Repeatable until player clicks "End Turn"

3. COMBAT PHASE
   - For each lane:
     * If both player + enemy unit exist → Simultaneous attack
     * Apply damage, remove dead units
     * If enemy lane empty → Enemy takes direct damage (future: Necromancer HP)

4. CLEANUP PHASE
   - Enemy AI spawns new units (fill empty lanes)
   - Check win (all enemies dead + enemy deck empty)
   - Check loss (player has no units + can't summon)
```

**Key Methods:**
```gdscript
func start_turn()
func on_pile_selected(pile_type: String)
func on_card_played(card: CardBase, target_lane: int, target_unit: Unit = null)
func resolve_combat()
func check_win_condition() -> bool
func check_loss_condition() -> bool
```

---

### 3. Lane (`lane.gd`)
**Responsibilities:**
- Hold 1 player unit slot + 1 enemy unit slot
- Visualize unit HP/ATK
- Handle combat in this lane

**Properties:**
```gdscript
var player_unit: Unit = null
var enemy_unit: Unit = null
var lane_index: int  # 0-4
```

**Key Methods:**
```gdscript
func summon_unit(unit_data: BodyCardResource, is_player: bool)
func equip_unit(equipment: EquipmentCardResource, target_unit: Unit)
func resolve_lane_combat()  # Called by CombatManager
```

---

### 4. Unit (`unit.gd`)
**Responsibilities:**
- Track HP, ATK, equipped items
- Display stats on board
- Handle damage/death

**Properties:**
```gdscript
var base_hp: int
var base_attack: int
var current_hp: int
var current_attack: int
var equipped_items: Array[EquipmentCardResource] = []
var max_equipment_slots: int
```

**Key Methods:**
```gdscript
func equip(item: EquipmentCardResource) -> bool  # Returns false if slots full
func take_damage(amount: int)
func attack(target: Unit)
func update_stats()  # Recalculate current_hp/attack from base + equipment
func die()
```

---

### 5. EnemyAI (`enemy_ai.gd`)
**Responsibilities:**
- Spawn enemies from enemy deck at end of player turn
- Simple AI: Fill empty lanes left-to-right

**Key Methods:**
```gdscript
func spawn_enemies(available_lanes: Array[Lane])  # Called in Cleanup Phase
```

**Spawn Logic (MVP):**
```
- If lane empty AND enemy deck has cards:
  * Draw 1 card from enemy deck
  * Summon to lane
- Max 3 enemies on board at once (keep it fair for testing)
```

---

## 🎨 UI Layout (Mockup)

```
┌─────────────────────────────────────────────────┐
│  ENEMY SIDE                                     │
│  Lane 1: [Squire HP:2 ATK:1]                   │
│  Lane 2: [Knight HP:5 ATK:2]                   │
│  Lane 3: [Empty]                                │
│  Lane 4: [Barbarian HP:4 ATK:3]                │
│  Lane 5: [Empty]                                │
├─────────────────────────────────────────────────┤
│  PLAYER SIDE                                    │
│  Lane 1: [Skeleton HP:1 ATK:1 (Axe +2)]       │
│  Lane 2: [Empty]                                │
│  Lane 3: [Zombie HP:3 ATK:2 (Shield +3)]       │
│  Lane 4: [Empty]                                │
│  Lane 5: [Empty]                                │
├─────────────────────────────────────────────────┤
│  HAND (5 Cards Max)                            │
│  [Skeleton] [Rusty Axe] [Shield] [Ghost] [Helmet] │
├─────────────────────────────────────────────────┤
│  ACTIONS                                        │
│  [Draw from BODY Pile] [Draw from EQUIPMENT Pile] │
│  [End Turn]                                     │
└─────────────────────────────────────────────────┘
```

---

## 🔨 Implementation Roadmap

### Day 1: Project Setup + Resources
- [ ] Create Godot 4.5 project structure (folders above)
- [ ] Create `CardBase`, `BodyCardResource`, `EquipmentCardResource` scripts
- [ ] Create 10 Body card `.tres` files (6 Skeleton, 3 Zombie, 1 Ghost)
- [ ] Create 15 Equipment card `.tres` files (5 Axe, 5 Shield, 3 Helmet, 2 Sword)
- [ ] Create 20 Enemy card `.tres` files (8 Squire, 6 Knight, 4 Barbarian, 2 Thief)
- [ ] Test: Can you load a card resource in inspector?

### Day 2: Deck + Hand System
- [ ] Create `DeckManager.gd`
  - `initialize_decks()` - Load cards from resources folder
  - `draw_from_pile()` - Shuffle, draw 2 cards
  - `add_to_hand()` - Enforce 5-card limit
- [ ] Create `hand_display.tscn` - Show 5 card slots
- [ ] Create `card_display.tscn` - Visual card (name, HP/ATK or bonuses)
- [ ] Test: Can you draw 2 cards and see them in hand?

### Day 3: Board + Lanes
- [ ] Create `lane.gd` + `lane_slot.tscn`
- [ ] Create `combat_board.tscn` - 5 Lane instances
- [ ] Create `unit.gd` + `unit_on_board.tscn` (display HP/ATK bars)
- [ ] Implement drag-and-drop: Card from hand → Lane
- [ ] Test: Can you summon a Skeleton to Lane 1?

### Day 4: Equipment System
- [ ] Implement `Unit.equip()` - Add equipment to unit, recalculate stats
- [ ] Drag-and-drop: Equipment card → Existing unit
- [ ] Visual feedback: Show equipment icon on unit sprite
- [ ] Test: Equip Axe to Skeleton, does ATK update to 3?

### Day 5: Combat Resolution
- [ ] Create `CombatManager.gd`
- [ ] Implement `resolve_combat()`:
  - Loop through lanes
  - Simultaneous attacks (player unit vs enemy unit)
  - Apply damage, remove dead units
- [ ] Add "End Turn" button → Triggers combat phase
- [ ] Test: Does Skeleton (HP:1) die to Knight (ATK:2)?

### Day 6: Enemy AI + Turn Flow
- [ ] Create `EnemyAI.gd`
- [ ] Implement enemy spawning (fill empty lanes after combat)
- [ ] Implement full turn cycle:
  1. Draw phase (player picks pile)
  2. Play phase (summon + equip)
  3. Combat phase (resolve lanes)
  4. Cleanup phase (enemy spawns)
- [ ] Test: Play 3 full turns, does enemy spawn correctly?

### Day 7: Win/Loss + Polish
- [ ] Implement win condition (enemy deck empty + all enemies dead)
- [ ] Implement loss condition (player can't summon + no units on board)
- [ ] Add UI labels (turn counter, deck sizes, "You Win!" screen)
- [ ] Playtest 10 turns: Document decisions made
- [ ] Bug fixes + tweaks

---

## 🎯 Playtest Questions (Day 7)

**After 10 turns, answer these:**

1. **Draw Decision Tension**
   - How often did you struggle to choose Body vs Equipment?
   - Were there turns where the choice felt obvious?

2. **Equipment Allocation**
   - Did you ever regret which unit you equipped?
   - Did you run out of bodies or equipment more often?

3. **Lane Positioning**
   - Did lane choice matter? (Or is it just "fill empty slot"?)
   - Should lanes have different properties (bonus ATK in lane 3)?

4. **Combat Feel**
   - Did units die too fast or too slow?
   - Were enemy spawns overwhelming or too weak?

5. **Interesting Decisions**
   - How many turns had a non-obvious "best move"?
   - When did you feel clever vs. frustrated?

---

## 🚀 Success Criteria

**MVP is complete when:**
- ✅ You can play 10 full turns without crashes
- ✅ All card types (bodies, equipment, enemies) work correctly
- ✅ Combat resolves correctly (damage, death, equipment bonuses apply)
- ✅ Enemy AI spawns opponents each turn
- ✅ Win/loss conditions trigger properly
- ✅ At least 50% of turns have interesting decisions (not autopilot)

**Red Flags to Watch For:**
- ❌ Every turn feels the same (always draw bodies, always equip same way)
- ❌ Equipment feels useless (naked units win anyway)
- ❌ Enemy spawns too predictable (always Squire → boring)
- ❌ Combat too slow (takes 20+ turns to win one battle)

---

## 📝 Next Steps After MVP

**If prototype is fun:**
1. Add 3 more card types (Lich, Cursed Helmet, Raise Dead spell)
2. Implement enemy variety (different spawn patterns)
3. Add basic animations (attack flash, death fade)
4. Build map node system (Combat → Treasure → Boss)

**If prototype is boring:**
1. Identify which decision felt stale
2. Iterate on core mechanic (maybe 3 piles instead of 2?)
3. Re-test before building more content

---

## 🎮 Controls Reference (MVP)

| Action | Input | Result |
|--------|-------|--------|
| Draw from Body Pile | Click "Body Pile" button | Draw 2 body cards |
| Draw from Equipment Pile | Click "Equipment Pile" button | Draw 2 equipment cards |
| Summon Unit | Drag body card to empty lane | Spawn unit in lane |
| Equip Unit | Drag equipment to unit on board | Attach equipment, update stats |
| End Turn | Click "End Turn" or Spacebar | Resolve combat, enemy spawns |
| Restart Battle | Click "Restart" (on win/loss screen) | Reset board, reshuffle decks |

---

**Let's build this! 🎲💀**
