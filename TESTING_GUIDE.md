# DEADHAND - MVP Prototype Testing Guide

## 🎮 Running the Prototype

### 1. Open in Godot
1. Open Godot 4.5
2. Click "Import"
3. Navigate to `/home/wdkidd/deadHand/dead-hand/`
4. Select `project.godot`
5. Click "Import & Edit"

### 2. First-Time Setup
When you first open the project:
1. Godot will parse all the custom resource scripts
2. You might see some errors initially - this is normal
3. Click **Project > Reload Current Project** to refresh
4. Errors should disappear

### 3. Run the Game
1. Press **F5** or click the "Play" button
2. The main scene (`scenes/main.tscn`) should auto-run
3. If prompted to select a main scene, choose `res://scenes/main.tscn`

---

## 🎯 How to Play

### Turn Flow

**1. DRAW PHASE**
- Click either "Draw from BODY Pile" or "Draw from EQUIPMENT Pile"
- You'll draw 2 cards into your hand (max 5 cards)

**2. PLAY PHASE**
- **To Summon**: Drag a Body card (green) from your hand to an empty lane
- **To Equip**: Drag an Equipment card (blue) from your hand onto an existing unit
- You can summon and equip multiple times per turn
- When done, click "END TURN"

**3. COMBAT PHASE** (Automatic)
- All units in lanes attack simultaneously
- Player units attack enemy units in the same lane
- If a unit's HP reaches 0, it dies

**4. CLEANUP PHASE** (Automatic)
- Enemy AI spawns new units (up to 3 total enemies)
- New turn begins

---

## ✅ Testing Checklist

### Day 1 Tests (Core Systems)
- [ ] Game starts without crashes
- [ ] Can draw from Body Pile (see 2 cards in hand)
- [ ] Can draw from Equipment Pile (see 2 cards in hand)
- [ ] Hand shows max 5 cards
- [ ] Card colors: Body (green), Equipment (blue)

### Day 2 Tests (Summoning)
- [ ] Can drag Skeleton to Lane 1
- [ ] Unit appears on board with HP: 1/1, ATK: 1
- [ ] Cannot summon to same lane twice
- [ ] Can summon to different lanes

### Day 3 Tests (Equipment)
- [ ] Can drag Rusty Axe (+2 ATK) onto Skeleton
- [ ] Skeleton's ATK updates to 3
- [ ] Can drag Shield (+3 HP) onto Skeleton
- [ ] Skeleton's HP updates to 4/4
- [ ] Cannot equip more than 2 items to Skeleton

### Day 4 Tests (Combat)
- [ ] Summon Skeleton (HP: 1, ATK: 1) to Lane 1
- [ ] Enemy spawns (e.g., Squire HP: 2, ATK: 1)
- [ ] Click "END TURN"
- [ ] Combat resolves: Skeleton takes 1 damage (dies), Squire takes 1 damage (HP: 1/2)
- [ ] Dead units disappear

### Day 5 Tests (Equipment + Combat)
- [ ] Summon Skeleton to Lane 1
- [ ] Equip Rusty Axe (+2 ATK) → ATK becomes 3
- [ ] Equip Shield (+3 HP) → HP becomes 4/4
- [ ] End turn
- [ ] Skeleton survives and kills enemy Squire

### Day 6 Tests (Enemy AI)
- [ ] After combat, enemies spawn to fill empty lanes
- [ ] Max 3 enemies on board at once
- [ ] Different enemy types appear (Squire, Knight, Barbarian, Thief)

### Day 7 Tests (Win/Loss)
- [ ] **Win Condition**: Kill all enemies and deplete enemy deck → "YOU WIN" message
- [ ] **Loss Condition**: All your units die + no body cards left → "YOU LOST" message

---

## 🐛 Common Issues & Fixes

### Issue: "Could not find type CardBase"
**Fix**: Click **Project > Reload Current Project**

### Issue: Cards don't appear in hand
**Fix**: Check console for errors. Verify card resources loaded:
```
Decks initialized:
  Body pile: 10 cards
  Equipment pile: 15 cards
  Enemy pile: 20 cards
```

### Issue: Can't drag cards
**Fix**: 
1. Make sure you're in PLAY phase (not DRAW phase)
2. Check that `card_display.tscn` has `mouse_filter = PASS`

### Issue: Units don't appear on board
**Fix**: Check that `unit_on_board.tscn` is loaded correctly at `res://scenes/cards/unit_on_board.tscn`

### Issue: Combat doesn't resolve
**Fix**: 
1. Check console for combat messages
2. Verify Lane's `resolve_combat()` is called

---

## 📊 Debug Console

Watch the console for useful output:

```
========== TURN 1 ==========
--- DRAW PHASE ---

Drew 2 cards from body pile

--- PLAY PHASE ---
Summon units or equip items. Click 'End Turn' when ready.
Skeleton equipped Rusty Axe!

--- COMBAT PHASE ---
=== Lane 0 Combat ===
Skeleton attacks Squire for 3 damage!
Squire took 3 damage! (0 HP remaining)
Squire has died!
=================

--- CLEANUP PHASE ---
Spawned Knight to Lane 1

Board State:
  Lane 0 | Player: Skeleton (HP: 1/1, ATK: 3) equipped with: Rusty Axe | Enemy: Empty
  Lane 1 | Player: Empty | Enemy: Knight (HP: 5/5, ATK: 2)
  ...
```

---

## 🎯 Playtest Questions (After 10 Turns)

**Document your answers:**

1. **Draw Decision Tension**
   - How often did you struggle to choose Body vs Equipment?
   - Score: 1 (always obvious) to 5 (always hard choice)

2. **Equipment Allocation**
   - Did you ever regret which unit you equipped?
   - Did you run out of bodies or equipment more?

3. **Lane Positioning**
   - Did lane choice matter?
   - Or is it just "fill empty slot"?

4. **Combat Feel**
   - Did units die too fast or too slow?
   - Were enemy spawns overwhelming or too weak?

5. **Interesting Decisions**
   - How many turns had a non-obvious "best move"?
   - When did you feel clever vs frustrated?

---

## 🔄 Next Steps After Testing

### If Fun:
- Add more card variety (Lich, Cursed Helmet, spells)
- Add enemy variety (different spawn patterns)
- Add animations (attack flash, death fade)
- Build rest of game (map, shop, progression)

### If Boring:
- Identify which decision felt stale
- Iterate on core mechanic before building more
- Try: 3 piles instead of 2? Lane bonuses? Equipment that breaks?

---

## 📝 Known MVP Limitations

- **No Animations**: Units just appear/disappear
- **No Sound**: Silent combat
- **No Win/Loss Screen**: Just console message
- **Simple AI**: Enemies spawn left-to-right only
- **No Saving**: Each run starts fresh
- **No Settings**: Fixed difficulty

**This is intentional! We're testing core fun, not polish.**

---

**Ready to playtest! 🎲💀**
