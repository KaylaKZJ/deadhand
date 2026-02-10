# DEADHAND - Game Design Document

**Genre:** Roguelike Deckbuilder Card Battler  
**Inspiration:** Inscryption, Slay the Spire, MTG  
**Theme:** Necromancer building undead army through modular creature construction  
**Target:** Strategic players who enjoy tactical decisions and deckbuilding

---

## 🎯 Core Concept

**"Build your undead army one bone at a time."**

Players command a necromancer traveling through a cursed dungeon, summoning skeletal minions and equipping them with weapons/armor to fight enemies in lane-based combat. Victory comes from smart resource management, strategic equipment choices, and optimal lane positioning.

---

## 🃏 Core Mechanic: Dual Draw Pile System

### Two Separate Decks

**1. BODY PILE (Summonable Units)**
- Skeleton (1 HP / 1 ATK, 2 equipment slots) - Common
- Zombie (3 HP / 2 ATK, 1 equipment slot) - Uncommon  
- Ghost (2 HP / 3 ATK, 1 weapon slot only) - Uncommon
- Lich (10 HP / 5 ATK, 2 equipment slots) - Legendary

**2. EQUIPMENT PILE (Stat Modifiers)**
- Dagger (+1 ATK) - Common
- Rusty Axe (+2 ATK) - Common
- Shield (+3 HP) - Common
- Helnmet (+2 HP) - Common
- Cursed Helmet (+5 HP, -1 ATK) - Uncommon
- Legendary Axe (+5 ATK) - Rare

### Hand Management
- **Draw Phase:** Choose ONE pile per turn, draw 2 cards
- **Strategic Tension:** Need bodies to summon OR equipment to empower existing units?

---

## ⚔️ Combat System

### Lane-Based Board (5 Lanes - Inscryption Style)

```
YOUR SIDE:
Lane 1: [Your Unit] ← → [Enemy Unit]
Lane 2: [Your Unit] ← → [Enemy Unit]  
Lane 3: [Your Unit] ← → [Empty]
Lane 4: [Your Unit] ← → [Empty]
Lane 5: [Your Unit] ← → [Empty]

ENEMY SIDE
```

### Turn Structure

**1. Draw Phase**
- Choose: Draw 2 from Body Pile OR 2 from Equipment Pile

**2. Play Phase (Multiple Actions Allowed)**
- **Summon:** Play body card to empty lane
- **Equip:** Attach equipment to unit already on board

**3. Combat Phase (Automatic)**
- Each lane: Your unit attacks enemy in same lane simultaneously
- Damage resolves, dead units removed
- If enemy survives, it attacks back next turn
- If enemy lane empty, your unit attacks enemy directly (ENEMY takes damage)

**4. Cleanup Phase**
- Enemy spawns new units if slots available
- Draw back to hand limit if under 5 cards

---

## 🎲 Strategic Decisions (Every Turn)

### Decision 1: Pile Priority
**Scenario:** You have 1 naked Skeleton on board, enemy Knight (5 HP) approaching.

**Option A:** Draw Bodies → Get 2 more Skeletons (go wide, 3 weak units)  
**Option B:** Draw Equipment → Get Axe + Shield (buff existing, 1 strong unit)  
**Tension:** Volume vs. Quality? Can you survive with just 1 unit?

---

### Decision 2: Equipment Allocation
**Scenario:** 2 Skeletons on board, you draw 1 Axe.

**Option A:** Equip Skeleton in Lane 1 (facing Knight, needs damage)  
**Option B:** Equip Skeleton in Lane 2 (facing Archer, already winning)  
**Tension:** Solve immediate threat vs. secure easy win?

---

### Decision 4: Lane Positioning
**Scenario:** 3 enemies approaching different lanes.

**Option A:** Spread units evenly (1 per lane, block all)  
**Option B:** Stack 2 units in Lane 1 (kill priority target fast, ignore others)  
**Tension:** Defensive coverage vs. offensive focus?

---

## 💀 Resource Economy: SOULS

### Single Unified Currency
- **Earned:** Kill enemies (+5 souls per basic enemy, +20 for bosses)
- **Spent On:**
  - Shop cards (Legendary Axe = 💀30)
  - Deck services (Remove 2 cards = 💀15)

### No Money Paradox
- Combat rewards ALWAYS useful (souls buy power)
- No separate currencies (ingredients, coins, etc.)
- Trade-offs at every shop (buy Lich OR thin deck?)

---

## 🗺️ Roguelike Map Structure (FTL-Style)

### Level Layout (8 Nodes → Boss → Next Level)
```
START → [Combat] → [Combat] → [Treasure] → [Rest] → [Combat] → [Shop] → [Combat] → [BOSS]
```

### Node Types

**1. Combat Nodes (60%)** - Fight enemies, earn souls
- Enemies scale with level (Level 1 = 3 HP Knights, Level 5 = 10 HP Death Knights)
- Win = souls + card reward

**2. Treasure Nodes (15%)** - Choose 1 of 3 cards
- Draft mechanic (build your deck strategically)
- Rare cards appear more often in later levels

**3. Rest Nodes (10%)** - Pick one:
- Heal Necromancer 15 HP
- Sacrifice 3 cards → Unlock legendary unit
- Upgrade 1 card (Skeleton → Armored Skeleton)

**4. Shop Nodes (10%)** - Spend souls
- Buy legendary cards (Lich, Vampire, Legendary Axe)
- Remove cards (deck thinning)
- Unlock new card types

**5. Boss Nodes (5%)** - End of each level
- Harder enemy with 30+ HP, special abilities
- Must defeat to progress to next level
- Rewards: Rare card + 💀50 souls

---

## 📈 Progression Systems

### 1. Unlocks (Permanent Across Runs)
- **New Body Cards:** Defeat Level 3 Boss → Unlock Vampire unit
- **New Equipment:** Complete 5 runs → Unlock Flaming Sword
- **New Spells:** Sacrifice 100 total cards → Unlock Mass Resurrection

### 2. Meta-Progression (Optional - Post-MVP)
- Necromancer levels grant starting bonuses (+10 starting souls)
- Achievements unlock alternate starting decks

### 3. Run Variety
- Different starting decks:
  - "Skeleton Swarm" (20 Skeletons, 5 weak axes)
  - "Lich Rush" (5 Skeletons, 3 Raise Dead spells)
  - "Tank Build" (10 Zombies, 10 Shields)

---

## 🎴 Card Types Reference

### Body Cards (30% of combined deck)

| Card | HP | ATK | Slots | Rarity | Soul Cost |
|------|----|----|-------|--------|-----------|
| Skeleton | 1 | 1 | 2 (Weapon + Armor) | Common | Free |
| Zombie | 3 | 2 | 1 (Armor only) | Common | Free |
| Ghost | 2 | 3 | 1 (Weapon only) | Uncommon | Free |
| Armored Skeleton | 3 | 1 | 2 | Uncommon | 💀10 |
| Lich | 10 | 5 | 2 | Legendary | 💀40 |
| Vampire | 6 | 4 | 2 (Lifesteal) | Legendary | 💀30 |

### Equipment Cards (50% of combined deck)

| Card | Type | Bonus | Rarity | Soul Cost |
|------|------|-------|--------|-----------|
| Rusty Axe | Weapon | +2 ATK | Common | Free |
| Shield | Armor | +3 HP | Common | Free |
| Iron Sword | Weapon | +3 ATK | Uncommon | 💀15 |
| Cursed Helmet | Armor | +5 HP, -1 ATK | Uncommon | 💀10 |
| Legendary Axe | Weapon | +5 ATK | Rare | 💀30 |
| Dragon Scale Armor | Armor | +8 HP | Rare | 💀25 |

### Spell Cards (20% of combined deck)

| Card | Effect | Cost | Rarity |
|------|--------|------|--------|
| Raise Dead | Summon 2 Skeletons | Sacrifice 1 unit | Common |
| Soul Harvest | Draw 3 cards | Kill 1 ally | Uncommon |
| Mass Resurrection | Summon 5 Skeletons | 💀20 | Rare |
| Summon Lich | Add Lich to board | Sacrifice 3 units | Legendary |

---

## 🎨 Visual Style

### Art Direction
- **Pixel Art** (16x16 for cards, 32x32 for board units)
- **Dark Color Palette:** Purples, greens, blacks (necromancy theme)
- **Particle Effects:** Bone dust on summon, soul wisps on death
- **UI:** Inscryption-inspired card frames with occult symbols

### Reference Games
- **Inscryption** - Card aesthetics, mysterious vibe
- **Slay the Spire** - Clean UI, readable card text
- **Stacklands** - Simple object icons (but less cluttered)

---

## 🛠️ Technical Implementation (Godot 4.5)

### Reusable Systems from Lemonade Stand

**1. DeckManager.gd**
- Manages 2 separate draw/discard piles
- Hand size limit enforcement (5 cards max)
- Draw choice logic (player picks pile)

**2. CombatBoard.gd**
- 3-lane system with unit placement
- Combat resolution (simultaneous attacks per lane)
- Equipment attachment to units

**3. CardDisplay.gd**
- Drag-and-drop from hand to board
- Visual equipment attachment (show axe icon on unit sprite)

**4. Unit.gd (Extends CharacterBody2D)**
- HP/ATK tracking per unit
- Equipment slot management (max 2 items)
- Combat animation triggers

---

## 📊 Scope & Milestones

### MVP (4 Weeks)
**Week 1: Paper Prototype**
- [ ] 25-card Player deck (10 bodies, 15 equipment)
- [ ] 20-card Enemy deck (20 bodies - knight, squire, barbarian, theif)
- [ ] 5-lane board mockup
- [ ] Playtest 10 turns: Are decisions interesting?

**Week 2: Core Systems**
- [ ] DeckManager (dual piles, draw logic)
- [ ] CombatBoard (5 lanes, unit placement)
- [ ] Card resources (BodyCard, EquipmentCard .tres files)
- [ ] Basic UI (hand display, lane slots)

**Week 3: Combat & Cards**
- [ ] Combat resolution (lane-based attacks)
- [ ] 10 body cards (Skeleton, Zombie, Ghost variants)
- [ ] 10 equipment cards (Axes, Shields, Helmets)
- [ ] Unit HP bars, death animations

**Week 4: Map & Progression**
- [ ] 5-node map (Combat → Treasure → Rest → Combat → Boss)
- [ ] Soul economy (earn from kills, spend at shop)
- [ ] Win condition (defeat boss, progress to Level 2)
- [ ] Lose condition (Necromancer HP hits 0)

### Post-MVP (Weeks 5-8)
- [ ] 8 full levels (difficulty scaling)
- [ ] 20 unique enemies (Knights, Archers, Mages, Bosses)
- [ ] 30+ cards (legendary units, rare equipment, spells)
- [ ] Meta-progression (unlocks across runs)
- [ ] Sound/Music (card play SFX, combat music)

---

## 🎯 Success Metrics

### Core Loop Validation
**Must achieve in playtests:**
- 80%+ of turns have non-obvious "best move"
- Players sacrifice cards at least 20% of the time
- Players change draw pile choice 40%+ of turns
- Combat deaths feel fair (not RNG bullshit)

### Replayability
- 5+ distinct viable builds (Swarm, Tank, Lich Rush, etc.)
- Players replay to unlock new cards
- Each run feels different (map RNG, card draft variance)

---

## 🚫 Non-Goals (What We're NOT Building)

- ❌ Multiplayer/PvP (single-player only)
- ❌ Procedural dungeon generation (fixed 8-level campaign)
- ❌ Story/narrative (pure mechanics-focused)
- ❌ 100+ cards (tight, balanced 30-50 card pool)
- ❌ Mobile port (PC-first, keyboard/mouse controls)

---

## 🎮 Input & Controls

### Keyboard/Mouse
- **Draw Phase:** Click Body Pile OR Equipment Pile button
- **Play Phase:** Drag card from hand → Lane slot (summon) or existing unit (equip)
- **Sacrifice:** Drag card to Altar zone (pops up during Rest nodes)
- **End Turn:** Spacebar or "End Turn" button

### Gamepad (Optional - Post-MVP)
- D-pad: Navigate cards in hand
- A: Play selected card
- B: Cancel/Discard
- Triggers: Switch between Body/Equipment pile highlight

---

## 📝 Open Questions (To Resolve in Prototyping)

1. **Should equipment be permanent or consumable?**
   - Option A: Equipment stays on unit forever (until unit dies)
   - Option B: Equipment breaks after X uses (more decision tension)

2. **Can players equip same unit multiple times per turn?**
   - Option A: Yes (stack Axe + Shield same turn)
   - Option B: No (one equipment action per unit per turn)

3. **What happens to equipped items when unit dies?**
   - Option A: Lost forever (high stakes)
   - Option B: Return to equipment discard pile (recycle-able)

4. **Should there be a discard action (throw away card for draw)?**
   - Option A: Yes (hand management tool)
   - Option B: No (forces commitment, Inscryption doesn't have this)

5. **Enemy targeting AI:**
   - Option A: Always target lowest HP unit in lane (predictable)
   - Option B: Random target selection (chaotic, harder to plan)

---

## 🎉 Why This Game Works

### ✅ Proven Mechanics
- Inscryption's dual-deck system (validated design)
- Slay the Spire's deckbuilding loop (addictive formula)
- MTG's resource management (tap/untap analogy)

### ✅ Strategic Depth
- 6+ meaningful decisions per turn
- Multiple viable builds (not one dominant strategy)
- Risk/reward at every node (map routing choices)

### ✅ Technical Feasibility
- 75% of code reusable from Lemonade Stand
- Godot 4.5 handles card drag-and-drop natively
- Art scope manageable (pixel sprites, no animation-heavy cutscenes)

### ✅ Replayability
- Roguelike structure (each run ~30 minutes)
- Unlocks incentivize multiple runs
- Draft variance keeps runs fresh

---

**Next Step:** Paper prototype this weekend. If hand choices feel boring, iterate BEFORE coding!
