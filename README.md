# 🎲 DEADHAND MVP - Build Complete! 💀

## ✅ What We Built

You now have a fully playable prototype of the DEADHAND combat system!

### Core Features Implemented:
- ✅ **Dual Draw Pile System** - Choose Body or Equipment each turn
- ✅ **5-Lane Combat Board** - Strategic positioning matters
- ✅ **Player HP System** - 20 HP, lose when it reaches 0
- ✅ **Overflow Damage** - Excess damage goes to player!
- ✅ **Card System** - 10 body cards, 15 equipment cards, 20 enemy cards
- ✅ **Unit Stats** - HP, ATK, equipment slots that update in real-time
- ✅ **Equipment System** - Equip weapons/armor to power up units
- ✅ **Turn-Based Combat** - Draw → Play → Combat → Cleanup phases
- ✅ **Enemy AI** - Spawns enemies automatically (max 3)
- ✅ **Win/Loss Conditions** - Deplete enemy deck OR lose all HP

---

## 📁 Project Structure

```
dead-hand/
├── scenes/
│   ├── main.tscn                    ← Main game scene (start here!)
│   ├── lane.tscn                    ← Individual lane
│   ├── cards/
│   │   ├── card_display.tscn        ← Card in hand
│   │   └── unit_on_board.tscn       ← Unit on battlefield
│   └── ui/
│       (future: hand_display, etc.)
├── scripts/
│   ├── main.gd                      ← Main orchestrator
│   ├── managers/
│   │   ├── deck_manager.gd          ← Handles both draw piles
│   │   ├── combat_manager.gd        ← Turn flow + combat
│   │   └── enemy_ai.gd              ← Enemy spawning
│   ├── card_logic/
│   │   ├── card_base.gd             ← Base resource class
│   │   ├── body_card.gd             ← Body card resource
│   │   ├── equipment_card.gd        ← Equipment resource
│   │   └── card_display.gd          ← Card UI logic
│   └── board/
│       ├── lane.gd                  ← Lane management
│       └── unit.gd                  ← Unit stats + behavior
├── resources/
│   └── cards/
│       ├── bodies/
│       │   ├── skeleton.tres        (x6 in deck)
│       │   ├── zombie.tres          (x3 in deck)
│       │   └── ghost.tres           (x1 in deck)
│       ├── equipment/
│       │   ├── rusty_axe.tres       (x5 in deck)
│       │   ├── shield.tres          (x5 in deck)
│       │   ├── helmet.tres          (x3 in deck)
│       │   └── iron_sword.tres      (x2 in deck)
│       └── enemies/
│           ├── squire.tres          (x8 in deck)
│           ├── knight.tres          (x6 in deck)
│           ├── barbarian.tres       (x4 in deck)
│           └── thief.tres           (x2 in deck)
├── assets/
│   └── sprites/
│       (placeholder for future art)
├── DEADHAND_GDD.md                  ← Full game design doc
├── MVP.md                           ← Implementation plan
├── TESTING_GUIDE.md                 ← How to test (read this!)
└── project.godot
```

---

## 🚀 How to Run

1. **Open Godot 4.5**
2. **Import Project**: Select `project.godot`
3. **Reload**: Click `Project > Reload Current Project` (fixes any initial errors)
4. **Play**: Press **F5**

---

## 🎮 How to Play

### Turn Structure:

1. **DRAW PHASE**
   - Click "Draw from BODY Pile" (green cards)
   - OR "Draw from EQUIPMENT Pile" (blue cards)
   - Adds 2 cards to your hand

2. **PLAY PHASE**
   - Drag **Body Cards** (Skeleton, Zombie, Ghost) to empty lanes
   - Drag **Equipment Cards** (Axe, Shield, Helmet) onto your units
   - When ready, click "END TURN"

3. **COMBAT PHASE** (automatic)
   - **Player units attack first!** (tactical advantage)
   - Enemy counter-attacks only if still alive
   - Dead units removed
   - **Overflow damage goes to player!**

4. **CLEANUP PHASE** (automatic)
   - Enemies spawn to fill lanes (max 3 total)
   - Next turn begins

### ⚠️ **New: Overflow Damage System**

When an enemy kills your unit with overkill damage, **you take the excess!**

**Example:**
- Enemy Barbarian (4 ATK) attacks your Skeleton (1 HP)
- Your Skeleton dies
- 3 overflow damage → **You lose 3 HP!**

**Strategy:**
- **Player attacks first** - Kill enemies before they hit you!
- Use high-ATK units to one-shot threats
- Use high-HP units (Zombies) to block big threats
- Equip shields to absorb more damage
- Don't leave lanes empty - direct attacks hurt!

---

## 🎯 Example Turn

```
TURN 1:
1. Draw from BODY → Get Skeleton + Skeleton
2. Summon Skeleton to Lane 1
3. Summon Skeleton to Lane 3
4. END TURN → Skeletons fight enemies

TURN 2:
1. Draw from EQUIPMENT → Get Rusty Axe + Shield
2. Equip Axe to Skeleton in Lane 1 (ATK: 1 → 3)
3. Equip Shield to Skeleton in Lane 3 (HP: 1 → 4)
4. END TURN → Equipped Skeletons fight

TURN 3:
1. Draw from BODY → Get Zombie + Skeleton
2. Summon Zombie to Lane 2 (HP: 3, ATK: 2)
3. Summon Skeleton to Lane 4
4. END TURN → Swarm the enemy!
```

---

## 🧪 Testing Priorities

### Must Test:
1. **Draw tension** - Is choosing pile hard?
2. **Equipment decisions** - Which unit to equip?
3. **Combat balance** - Units dying too fast/slow?
4. **Enemy spawns** - Too many/few enemies?
5. **Fun factor** - Do 10 turns feel engaging?

### See `TESTING_GUIDE.md` for full checklist!

---

## 🔧 Known Limitations (MVP Only)

- **No animations** - Units just appear/disappear
- **No sound effects** - Silent gameplay
- **Basic UI** - Functional but plain
- **Simple AI** - Enemies spawn left-to-right
- **No save/load** - Each run starts fresh
- **No win/loss screen** - Just console message

**This is fine!** We're testing core mechanics, not polish.

---

## 📊 Debug Tips

### Console Output
The game prints helpful debug info:

```
========== TURN 1 ==========
Decks initialized:
  Body pile: 10 cards
  Equipment pile: 15 cards
  Enemy pile: 20 cards

Drew 2 cards from body pile

Skeleton equipped Rusty Axe!

=== Lane 0 Combat ===
Skeleton attacks Squire for 3 damage!
Squire took 3 damage! (0 HP remaining)
Squire has died!
```

### Common Errors:
- **"Could not find type CardBase"** → Reload project
- **Cards don't appear** → Check console for load errors
- **Can't drag cards** → Make sure you're in PLAY phase

---

## 🎯 Playtest Goals

After 10 turns, ask yourself:

1. **Did I feel clever?** (Strategic satisfaction)
2. **Did I make tough choices?** (Not just autopilot)
3. **Did equipment matter?** (Worth the draw?)
4. **Did I care about lanes?** (Or just fill randomly?)
5. **Did I want to keep playing?** (Engagement)

**If 3+ answers are "no", iterate on core mechanic before building more!**

---

## 🔄 Next Steps

### If Prototype is Fun:
1. ✅ Add more card types (Lich, Cursed Helmet, spells)
2. ✅ Add enemy variety (ranged, AOE, boss units)
3. ✅ Add animations (attack flashes, death particles)
4. ✅ Build map system (Combat → Treasure → Boss)
5. ✅ Add soul economy + shop

### If Prototype is Boring:
1. ❌ Identify stale decision points
2. ❌ Iterate on draw system (3 piles? Reroll option?)
3. ❌ Test lane bonuses (Lane 3 = +1 ATK?)
4. ❌ Re-test before expanding scope

---

## 🎨 Future Features (Post-MVP)

- **Spell Cards**: Raise Dead, Soul Harvest, Mass Resurrection
- **Legendary Units**: Lich, Vampire, Death Knight
- **Map Nodes**: Treasure, Rest, Shop, Boss fights
- **Meta-Progression**: Unlock new cards across runs
- **Animations**: Attack swooshes, death particles, card glows
- **Sound/Music**: Card play SFX, combat music, death sounds
- **Polished UI**: Card frames, health bars, turn indicators

---

## 💡 Design Reminders

### Core Pillars:
1. **Every draw is a dilemma** (Bodies OR Equipment?)
2. **Equipment creates scaling** (Naked units weak, equipped strong)
3. **Lanes create positioning** (Where to place matters)
4. **Combat is deterministic** (No RNG bullshit)

### Red Flags:
- ❌ Draw choice feels obvious every turn
- ❌ Equipment doesn't feel worth it
- ❌ Lanes don't matter (just fill randomly)
- ❌ Combat is too slow (20+ turns per battle)

---

## 📞 Troubleshooting

### Project Won't Open:
- Verify Godot 4.5 installed
- Check `project.godot` exists
- Try: File > Open Project > Select folder

### Errors on First Load:
- **Normal!** Godot parsing custom resources
- Solution: Project > Reload Current Project

### Game Won't Start:
- Check main scene set: `res://scenes/main.tscn`
- Try: Run > Run Project (F5)

### Units Don't Spawn:
- Check console for error messages
- Verify `.tres` files loaded correctly
- Try: View card resources in Inspector

---

## 🎉 You're Ready!

**Everything is set up and ready to playtest!**

1. Open Godot
2. Press F5
3. Play 10 turns
4. Document your experience
5. Iterate based on fun factor

**Good luck, necromancer! 🎲💀**

---

*Built with Godot 4.5 | MVP Prototype v1.0*
