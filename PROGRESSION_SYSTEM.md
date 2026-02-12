# Player Progression System - Design Document

## Core Concept
Players earn XP from killing enemies during runs and spend it between runs to permanently upgrade their character stats. These stats unlock new cards, increase survivability, and enable new playstyles.

---

## Four Core Stats

### 1. **STRENGTH** 💪
*Unlocks heavy weapons and armor - the "tank" stat*

**Equipment Unlocks:**
- **Level 1** (Starting): Rusty Axe (2 ATK), Wooden Shield (+1 HP)
- **Level 2** (50 XP): Iron Sword (3 ATK), Chain Mail (+4 HP)
- **Level 3** (150 XP): **Great Axe** (6 ATK, 2-handed!), Plate Armor (+6 HP, +1 ATK)
- **Level 4** (300 XP): **Warhammer** (8 ATK, stuns enemies 1 turn), Tower Shield (+8 HP, blocks overflow)

**Passive Bonus:**
- +1 base damage to ALL attacks (melee and ranged)
- Represents raw physical power

---

### 2. **VITALITY** ❤️
*Increases max HP - pure survivability*

**No Equipment Unlocks** (Vitality is about raw HP, not gear)

**Level Progression:**
- **Level 1** (Starting): 20 Max HP
- **Level 2** (50 XP): 30 Max HP (+10)
- **Level 3** (150 XP): 45 Max HP (+15)
- **Level 4** (300 XP): 65 Max HP (+20)

**Passive Bonus:**
- Each body card gets +2 HP when deployed (based on your vitality level)
- Example: Level 3 Vitality = Skeleton (2 HP) becomes 8 HP when played
- **This makes "weak" bodies viable late-game!**

---

### 3. **DEXTERITY** 🏹
*Unlocks ranged weapons and dual-wielding - the "agile" stat*

**Equipment Unlocks:**
- **Level 1** (Starting): Dagger (1 ATK, fast), Leather Armor (+2 HP)
- **Level 2** (50 XP): **Longbow** (3 ATK, ranged, 2-handed), Dual Daggers (2+2 ATK, fills both weapon slots)
- **Level 3** (150 XP): **Crossbow** (5 ATK, ranged, 1-handed!), Studded Leather (+3 HP, +1 ATK)
- **Level 4** (300 XP): **Throwing Knives** (2 ATK, ranged, reusable!), Shadow Cloak (+1 HP, "First Strike" ability)

**Passive Bonus:**
- Ranged attacks can hit Column 2 even if Column 1 is occupied
- +1 equipment slot at Level 3 (allows true dual-wielding with shield)
- Represents precision and multi-tasking

---

### 4. **MANA** 🔮 *(Future Expansion)*
*Unlocks spell cards that can be cast during play phase*

**Level Progression:**
- **Level 1** (Starting): No spells available
- **Level 2** (50 XP): Unlock Fireball spell (3 damage to all enemies in chosen lane)
- **Level 3** (150 XP): Unlock Heal spell (restore 5 HP to target unit)
- **Level 4** (300 XP): Unlock Resurrect spell (revive dead unit with 1 HP)

**Passive Bonus:**
- +1 spell slot in hand per level
- Spells are drawn from a separate "spell pile" during draw phase

---

## Build Archetypes & Strategic Choices

### Tank Build (Strength + Vitality Focus)
**Early Investment:** STR 2, VIT 2 (100 XP total)
- **Equipment:** Iron Sword (3 ATK) + Chain Mail (+4 HP) + Wooden Shield (+1 HP)
- **Bodies:** Zombie (3 HP) becomes 9 HP with VIT bonus
- **Playstyle:** Absorb damage, win through attrition
- **Weakness:** Slow to kill Column 2 enemies (no ranged)

### Glass Cannon (Strength + Dexterity Focus)
**Early Investment:** STR 3, DEX 2 (250 XP total)
- **Equipment:** Great Axe (6 ATK, 2-handed) OR Longbow (3 ATK, ranged)
- **Playstyle:** High damage, flexible targeting, but fragile
- **Weakness:** Low max HP, dies to overflow damage

### Ranger (Dexterity + Vitality Focus)
**Early Investment:** DEX 3, VIT 2 (250 XP total)
- **Equipment:** Crossbow (5 ATK, ranged) + Shield + Studded Leather
- **Bodies:** High HP from Vitality, safe ranged attacks
- **Playstyle:** Kite enemies, never get hit in Column 0
- **Weakness:** Lower raw damage than STR builds

### Balanced Generalist
**Investment:** STR 2, VIT 2, DEX 2 (150 XP total)
- **Equipment:** Mix of melee + ranged options
- **Playstyle:** Adaptable, can handle any situation
- **Weakness:** Master of none, lacks specialization power spikes

**Key Insight:** There's no "correct" build - each run might favor different stats based on what equipment cards you draw!

---

## Equipment Gating Philosophy

### Why Stat Requirements Matter

**Creates Tension:**
- You find a Great Axe in your starting hand
- It requires Strength 3 (you're at Strength 1)
- Do you spend 200 XP rushing to unlock it?
- Or adapt your strategy to what you CAN use?

**Example Equipment Cards:**

```gdscript
# resources/cards/equipment/great_axe.tres
extends EquipmentCardResource

@export var display_name = "Great Axe"
@export var equipment_type = "weapon"
@export var hp_bonus = 0
@export var attack_bonus = 6
@export var slots_required = ["weapon", "shield"]  # 2-handed

# NEW: Stat requirements
@export var required_strength = 3
@export var required_dexterity = 0
@export var required_vitality = 0

# Visual feedback in deck
@export var locked_color = Color(0.5, 0.5, 0.5, 0.5)  # Grayed out if can't use
```

### Bodies Stay Unlocked From Start

**All basic bodies available always:**
- Skeleton (2 HP, 1 ATK, 4 slots) - Versatile
- Zombie (3 HP, 2 ATK, 3 slots) - Tanky
- Ghost (1 HP, 3 ATK, 2 slots) - Glass cannon

**Why?**
- Bodies are your "characters" - shouldn't be locked
- Equipment defines playstyle, not bodies
- Vitality passive makes "weak" bodies viable late-game
  - Example: Skeleton normally 2 HP, but with VIT 4 = 10 HP!

---

## Diablo-Style Excitement

### Loot Drop Fantasy
When you kill an enemy, equipment cards go into your hand:
- **Green border** = You can equip this now
- **Red border** = "Requires STR 3" (you have STR 2)
- **Creates goals:** "One more STR level and I can use that Warhammer!"

### Replayability
- Run 1: Found Crossbow early → invest in DEX
- Run 2: Found Great Axe early → invest in STR
- Run 3: Found Throwing Knives → hybrid DEX/VIT build

**The equipment you draw shapes your progression choices!**

---

## XP Economy

### Earning XP During Runs

| Event | XP Reward |
|-------|-----------|
| Kill basic enemy (Squire) | 10 XP |
| Kill tough enemy (Knight, Barbarian) | 20 XP |
| Kill boss enemy | 50 XP |
| Survive 5 turns | 5 XP |
| Win the run | 100 XP bonus |

**Example Run:**
- Killed 8 Squires: 80 XP
- Killed 3 Knights: 60 XP  
- Survived 20 turns: 20 XP
- Won the run: 100 XP
- **Total: 260 XP**

### Spending XP Between Runs

| Stat Level | XP Cost | Cumulative XP |
|------------|---------|---------------|
| 1 → 2 | 50 XP | 50 XP |
| 2 → 3 | 150 XP | 200 XP |
| 3 → 4 | 300 XP | 500 XP |

**Total XP to max one stat:** 500 XP  
**Total XP to max all stats:** 2000 XP (~20-30 runs)

---

## Persistent Save Data Structure

```gdscript
var player_progression = {
	# Stat levels (1-4)
	"strength": 1,
	"vitality": 1,
	"dexterity": 1,
	"mana": 1,
	
	# XP tracking
	"total_xp_earned": 0,      # Lifetime XP across all runs
	"available_xp": 0,         # Unspent XP for upgrades
	
	# Statistics
	"runs_completed": 0,
	"runs_won": 0,
	"total_enemies_killed": 0,
	"total_turns_survived": 0,
	
	# Unlocks (derived from stat levels)
	"unlocked_bodies": ["skeleton", "zombie", "ghost"],
	"unlocked_equipment": ["helmet", "shield", "rusty_axe", "iron_sword", "longbow"],
	"unlocked_spells": []
}
```

---

## UI/UX Flow

### During Run

**HUD Display:**
```
Top-Right Corner:
┌─────────────────┐
│ XP This Run: 47 │
└─────────────────┘
```

**Kill Feedback:**
- Floating text appears when enemy dies: `+10 XP` (yellow, fades up)
- Sound effect: *coin/chime sound*

### After Run (Win or Loss)

**1. Results Screen**
```
╔══════════════════════════════╗
║      RUN COMPLETE!           ║
╠══════════════════════════════╣
║ Result: VICTORY / DEFEAT     ║
║ Turns Survived: 27           ║
║ Enemies Killed: 15           ║
║                              ║
║ XP Earned: +150              ║
║ Total XP: 347                ║
╚══════════════════════════════╝
     [Continue to Upgrades]
```

**2. Upgrade Screen**
```
╔════════════════════════════════════════╗
║         CHARACTER UPGRADES             ║
╠════════════════════════════════════════╣
║ Available XP: 150                      ║
║                                        ║
║ ┌──────────────────────────────────┐  ║
║ │ STRENGTH      [■■■□]  Lv 3       │  ║
║ │ Next: Unlock Berserker           │  ║
║ │ Cost: 150 XP      [UPGRADE NOW!] │  ║
║ └──────────────────────────────────┘  ║
║                                        ║
║ ┌──────────────────────────────────┐  ║
║ │ VITALITY      [■■□□]  Lv 2       │  ║
║ │ Next: 30 Max HP, Plate Armor     │  ║
║ │ Cost: 150 XP      [UPGRADE NOW!] │  ║
║ └──────────────────────────────────┘  ║
║                                        ║
║ ┌──────────────────────────────────┐  ║
║ │ DEXTERITY     [■□□□]  Lv 1       │  ║
║ │ Next: Unlock Crossbow            │  ║
║ │ Cost: 50 XP       [UPGRADE NOW!] │  ║
║ └──────────────────────────────────┘  ║
║                                        ║
║ ┌──────────────────────────────────┐  ║
║ │ MANA          [■□□□]  Lv 1       │  ║
║ │ Next: Unlock Fireball Spell      │  ║
║ │ Cost: 50 XP       [Not enough XP]│  ║
║ └──────────────────────────────────┘  ║
╚════════════════════════════════════════╝
      [Back to Menu]  [Start New Run]
```

---

## Integration with Existing Systems

### DeckManager Changes

```gdscript
# Equipment filtering based on player progression
func get_available_equipment() -> Array[EquipmentCardResource]:
	var available = []
	for item in all_equipment:
		# Include ALL equipment in deck, but mark locked ones
		available.append(item)
	return available

func get_equippable_items() -> Array[EquipmentCardResource]:
	# Only items player can currently use
	var equippable = []
	for item in all_equipment:
		if item.can_be_equipped_by_player():
			equippable.append(item)
	return equippable

# Bodies are ALWAYS available (no filtering)
func get_available_body_cards() -> Array[BodyCardResource]:
	return all_body_cards  # No filtering!
```

### Card Resource Changes

**EquipmentCardResource (PRIMARY FOCUS):**
```gdscript
@export var required_strength: int = 0   # 0 = no requirement
@export var required_dexterity: int = 0
@export var required_vitality: int = 0   # Not used for equipment, but future-proofs

# Visual feedback
@export var locked_tint: Color = Color(0.5, 0.5, 0.5, 0.5)

func can_be_equipped_by_player() -> bool:
	return (PlayerProgression.strength >= required_strength and
	        PlayerProgression.dexterity >= required_dexterity)

func get_requirement_text() -> String:
	var reqs = []
	if required_strength > 0:
		var color = "green" if PlayerProgression.strength >= required_strength else "red"
		reqs.append("[color=%s]STR %d[/color]" % [color, required_strength])
	if required_dexterity > 0:
		var color = "green" if PlayerProgression.dexterity >= required_dexterity else "red"
		reqs.append("[color=%s]DEX %d[/color]" % [color, required_dexterity])
	return "Requires: " + ", ".join(reqs) if reqs.size() > 0 else ""
```

**BodyCardResource (UNCHANGED - always available):**
```gdscript
@export var xp_value: int = 10  # XP awarded when killed as enemy
# No stat requirements - all bodies available from start
```

### CombatManager Changes

```gdscript
var xp_earned_this_run: int = 0

signal xp_gained(amount: int)

func on_enemy_killed(enemy_card: BodyCardResource):
	var xp = enemy_card.xp_value
	xp_earned_this_run += xp
	xp_gained.emit(xp)
	
	# Show floating "+10 XP" text at enemy position
	show_xp_popup(xp)

func end_run(victory: bool):
	if victory:
		xp_earned_this_run += 100  # Win bonus
	
	PlayerProgression.add_xp(xp_earned_this_run)
	show_results_screen()
```

### New PlayerProgression Singleton

```gdscript
extends Node

# Stat levels (1-4)
var strength: int = 1
var vitality: int = 1
var dexterity: int = 1
var mana: int = 1

# XP
var total_xp_earned: int = 0
var available_xp: int = 0

# Stats
var runs_completed: int = 0
var runs_won: int = 0

# Max HP derived from vitality
var max_hp: int:
	get:
		return 20 + ((vitality - 1) * 10)  # 20/30/45/65

# Base damage bonus from strength
var strength_bonus: int:
	get:
		return strength - 1  # 0/1/2/3 bonus damage

# HP bonus applied to deployed bodies from vitality
var vitality_hp_bonus: int:
	get:
		return (vitality - 1) * 2  # 0/2/4/6 bonus HP per body

# Extra equipment slot from dexterity (at level 3+)
var has_extra_slot: bool:
	get:
		return dexterity >= 3

func add_xp(amount: int):
	total_xp_earned += amount
	available_xp += amount
	save_progression()

func upgrade_stat(stat_name: String) -> bool:
	var current_level = get(stat_name)
	var cost = get_upgrade_cost(current_level)
	
	if available_xp >= cost and current_level < 4:
		available_xp -= cost
		set(stat_name, current_level + 1)
		save_progression()
		return true
	return false

func get_upgrade_cost(current_level: int) -> int:
	match current_level:
		1: return 50
		2: return 150
		3: return 300
		_: return 999999  # Max level

func save_progression():
	# Save to user://progression.save
	pass

func load_progression():
	# Load from user://progression.save
	pass
```

---

## Visual Feedback for Locked Equipment

### In-Hand Card Display

**CardDisplay.gd changes:**
```gdscript
func update_display(card_resource: CardBase):
	if card_resource is EquipmentCardResource:
		# Check if player meets requirements
		if not card_resource.can_be_equipped_by_player():
			# Gray out the card
			modulate = Color(0.5, 0.5, 0.5, 1.0)
			
			# Add "LOCKED" badge
			var lock_icon = TextureRect.new()
			lock_icon.texture = preload("res://assets/sprites/ui/lock_icon.png")
			lock_icon.position = Vector2(5, 5)
			add_child(lock_icon)
			
			# Show requirements text
			description_label.text += "\n\n" + card_resource.get_requirement_text()
		else:
			modulate = Color(1, 1, 1, 1)  # Full color
```

### Attempting to Equip Locked Item

**Unit.equip() validation:**
```gdscript
func equip(equipment: EquipmentCardResource) -> bool:
	# NEW: Check player progression requirements
	if not equipment.can_be_equipped_by_player():
		# Show error message
		var label = Label.new()
		label.text = "Requires %s" % equipment.get_requirement_text()
		label.add_theme_color_override("font_color", Color.RED)
		# Float up and fade out
		return false
	
	# Existing slot validation...
	var required_slots = equipment.get_required_slots()
	# ... rest of equip logic
```

### Deck Building UI

**Show locked items grayed out in deck:**
```
╔════════════════════════════════════════╗
║         EQUIPMENT DECK                 ║
╠════════════════════════════════════════╣
║ ✅ Iron Sword (STR 2) - 3 ATK         ║
║ ✅ Longbow (DEX 2) - 3 ATK, Ranged    ║
║ 🔒 Great Axe (STR 3) - 6 ATK          ║  <- Grayed out
║ 🔒 Crossbow (DEX 3) - 5 ATK, Ranged   ║  <- Grayed out
║ ✅ Wooden Shield - +1 HP               ║
╚════════════════════════════════════════╝
```

---

## Implementation Phases

### Phase 1: MVP (Core Loop)
1. ✅ Create PlayerProgression singleton
2. ✅ Add XP tracking during runs
3. ✅ Display XP in HUD
4. ✅ Show floating "+XP" on kills
5. ✅ Create post-run results screen
6. ✅ Create upgrade screen UI
7. ✅ Implement Vitality → Max HP increase
8. ✅ Implement Strength → Unlock 1-2 new body cards
9. ✅ Add required_strength to body cards
10. ✅ Filter deck based on unlocks

### Phase 2: Equipment Unlocks
1. ✅ Add required_vitality/dexterity to equipment
2. ✅ Create Chain Mail, Plate Armor cards
3. ✅ Create Crossbow card
4. ✅ Implement Strength melee damage bonus
5. ✅ Implement Dexterity overflow dodge

### Phase 3: Advanced Features
1. ✅ Dual Wield system (dexterity level 3)
2. ✅ Create new body cards (Knight, Berserker, Paladin, Assassin)
3. ✅ Save/load progression to disk
4. ✅ Statistics tracking screen

### Phase 4: Mana & Spells (Future)
1. ⬜ Design spell card system
2. ⬜ Implement spell casting during play phase
3. ⬜ Create Fireball, Heal, Resurrect spells
4. ⬜ Spell pile separate from body/equipment piles

---

## Balancing Philosophy

### Equipment Gating Creates Strategic Decisions

**Early Game (0-200 XP):**
- Can use: Rusty Axe, Dagger, Wooden Shield
- **Decision:** Rush STR 2 for Iron Sword? Or DEX 2 for Longbow?
- **Impact:** Defines your playstyle for next 5-10 runs

**Mid Game (200-500 XP):**
- Can unlock: Great Axe (STR 3) OR Crossbow (DEX 3)
- **Decision:** Specialize further? Or diversify with VIT for survivability?
- **Impact:** Commitments matter - can't just "have everything"

**Late Game (500+ XP):**
- Multiple stats at level 3-4
- **Decision:** Perfect your main build OR become generalist?
- **Impact:** Different strategies emerge (tank, ranged, hybrid)

### Equipment Power Budget

**Starter Gear (no requirements):**
- Rusty Axe: 2 ATK
- Dagger: 1 ATK
- Wooden Shield: +1 HP

**Mid-Tier (STR/DEX 2 = 50 XP investment):**
- Iron Sword: 3 ATK (+50% damage)
- Longbow: 3 ATK, ranged
- Chain Mail: +4 HP

**High-Tier (STR/DEX 3 = 200 XP investment):**
- Great Axe: 6 ATK (+200% damage from starter!)
- Crossbow: 5 ATK, ranged, 1-handed
- Plate Armor: +6 HP, +1 ATK

**Top-Tier (STR/DEX 4 = 500 XP investment):**
- Warhammer: 8 ATK, stun ability
- Throwing Knives: 2 ATK, ranged, reusable
- Tower Shield: +8 HP, blocks overflow

### XP Economy
- **Average run earns 50-150 XP**: 
  - Bad run (loss early): ~30 XP
  - Good run (loss late): ~80 XP
  - Victory: ~150-200 XP

### Stat Progression Timeline
- **First upgrade (level 2)**: 1 good run
- **Second upgrade (level 3)**: 3-4 runs
- **Third upgrade (level 4)**: 6-8 more runs
- **One stat maxed**: ~10-15 runs (3-5 hours)
- **All stats maxed**: ~25-35 runs (10-15 hours)

### Vitality vs Offensive Stats

**Vitality is ALWAYS useful:**
- More max HP = more mistakes forgiven
- +2 HP per body makes "weak" bodies strong
- Safe choice for new players

**Strength/Dexterity are HIGH RISK/REWARD:**
- Unlock powerful gear
- But fragile without Vitality investment
- Experienced players prefer damage > HP

**Ideal Ratios:**
- **New players:** 50% VIT, 25% STR, 25% DEX
- **Experienced:** 25% VIT, 40% STR, 35% DEX
- **"Pro" strategies:** All-in on one stat (glass cannon)

---

## Future Expansions

### Prestige System
- Reset all stats to level 1
- Gain permanent "Prestige Points"
- Unlock cosmetic card backs
- New game+ difficulty with better XP rewards

### Achievement Unlocks
- "Win without taking damage" → Unlock Vampire body
- "Kill 100 enemies with ranged" → Unlock Sniper Rifle
- "Equip 4 items on one unit" → Unlock Artificer body (4 slots)

### PvP Mode
- Use your progression stats
- Battle another player's deck
- Winner takes a % of loser's XP (competitive risk/reward)

---

## Open Questions for Design

1. **Should XP be shareable between stats or separate?**
   - Current: Shared pool, spend flexibly
   - Alternative: Earn Strength XP separately from Vitality XP

2. **Should there be XP loss on defeat?**
   - Current: No penalty, always make progress
   - Alternative: Lose 25% XP on defeat (high stakes)

3. **Should max level be 4 or higher?**
   - Current: 4 levels feels achievable
   - Alternative: 10 levels with diminishing returns

4. **Should there be a level requirement for harder content?**
   - Example: "Level 2 Strength required to fight Boss mode"

---

## Summary

This progression system transforms the game from single-session to long-term engagement. Every run matters, losses still grant progress, and players can customize their playstyle through stat allocation. The four-stat system is simple enough to understand but deep enough to create build variety.

**Core Loop:**
Play Run → Earn XP → Spend on Stats → Unlock Cards → Try New Strategies → Repeat

**Player Motivation:**
"I died but earned 80 XP. One more upgrade and I can unlock the Berserker!"

---

*Document Version 1.0 - Created: February 11, 2026*
