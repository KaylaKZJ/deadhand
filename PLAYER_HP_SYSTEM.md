# Player HP & Overflow Damage System

## 🩸 New Mechanic Overview

Players now start with **20 HP** and lose when it reaches 0. This adds urgency and strategic depth to lane management!

---

## 💔 How Damage Works

### 1. **Overflow Damage (Overkill)**
When an enemy kills your unit, excess damage carries over to you!

**Example 1:**
```
Enemy Knight (5 ATK) attacks your Skeleton (1 HP)
→ Skeleton dies
→ 4 overflow damage to player
→ Player: 20 HP → 16 HP
```

**Example 2:**
```
Enemy Barbarian (4 ATK) attacks your equipped Skeleton (4 HP, with Shield)
→ Skeleton dies (exactly)
→ 0 overflow damage
→ Player HP stays same ✅
```

### 2. **Direct Attacks (Empty Lanes)**
If a lane has NO player unit, the enemy attacks you directly!

```
Lane 3: No player unit, Enemy Thief (2 ATK)
→ Thief attacks player for 2 damage
→ Player: 18 HP → 16 HP
```

---

## 🎯 Strategic Implications

### Before (No HP):
- Losing units was annoying but not critical
- Could ignore some lanes
- Just needed 1 body card to keep playing

### After (With HP):
- **Every unit matters** - they're your HP buffer!
- **Lane coverage critical** - empty lanes = direct damage
- **Equipment timing matters** - shields prevent overflow
- **Risk/reward on bodies** - sacrifice weak unit or tank up?

---

## 🛡️ Defensive Strategies

### 1. **Use Zombies as Blockers**
Zombies (3 HP, 2 ATK) are natural tanks:
- Can survive Squire (1 ATK) hits
- Absorb more damage before overflow
- **Best for blocking high ATK enemies**

### 2. **Equip Shields Early**
Shield (+3 HP) turns Skeleton into 4 HP blocker:
- Skeleton: 1 HP → Dies to everything
- Skeleton + Shield: 4 HP → Survives Knight (2 ATK) twice!

### 3. **Fill Lanes Quickly**
Don't leave lanes empty!
- Empty lane = Free damage to you
- Even a 1 HP Skeleton blocks 1 ATK
- Better to have weak blocker than none

### 4. **Prioritize Threats**
Kill high ATK enemies first:
- Barbarian (4 ATK) → Can deal 4+ overflow damage
- Squire (1 ATK) → Only 1 overflow max
- Use equipped units to one-shot threats

---

## 📊 Math Examples

### Scenario 1: Naked Skeleton vs Knight (Player Attacks First!)
```
Your Skeleton: 1 HP, 1 ATK
Enemy Knight: 5 HP, 2 ATK

Combat:
- Skeleton attacks Knight FIRST (5 → 4 HP)
- Knight counter-attacks Skeleton (1 HP → dies)
- Overflow: 2 ATK - 1 HP = 1 damage to you
Result: You take 1 damage (Knight survives with 4 HP)
```

### Scenario 2: Equipped Skeleton vs Knight (One-Shot!)
```
Your Skeleton + Shield + Axe: 4 HP, 3 ATK
Enemy Knight: 5 HP, 2 ATK

Combat:
- Skeleton attacks Knight FIRST (5 → 2 HP)
- Knight counter-attacks Skeleton (4 → 2 HP, survives!)
Result: No overflow damage! Both units survive
```

### Scenario 3: High ATK Skeleton vs Squire (Kill Before Counter!)
```
Your Skeleton + Iron Sword: 1 HP, 4 ATK
Enemy Squire: 2 HP, 1 ATK

Combat:
- Skeleton attacks Squire FIRST (2 → 0 HP, DEAD!)
- Squire does NOT counter-attack (already dead)
Result: You take 0 damage! Skeleton survives! ✅
```

### Scenario 4: Empty Lane vs Barbarian
```
Lane 1: Empty
Enemy Barbarian: 4 HP, 4 ATK

Combat:
- No blocker
- Barbarian attacks you directly
Result: You take 4 damage
```

---

## 🎯 Strategic Implications

### Attack Order Matters!

**OLD (Simultaneous):**
- Both units always dealt damage to each other
- No way to avoid counter-attacks
- Low HP units always died

**NEW (Player First):**
- **You can one-shot enemies before they hit you!**
- High ATK builds are now viable (Glass Cannon strategy)
- Rewards aggressive equipment choices

### New Viable Strategies:

#### 1. **Glass Cannon (High ATK, Low HP)**
```
Skeleton (1 HP) + Iron Sword (+3 ATK) = 4 ATK
→ Kills Squire (2 HP) before it can counter!
→ No damage taken!
```

#### 2. **Tank Build (High HP, Low ATK)**
```
Zombie (3 HP) + Shield (+3 HP) = 6 HP, 2 ATK
→ Survives multiple hits
→ Prevents overflow damage
```

#### 3. **Balanced (Medium Both)**
```
Skeleton + Axe + Shield = 4 HP, 3 ATK
→ Can kill or tank depending on matchup
```

---

## 🎮 UI Changes

### New HP Display (Top Left)
```
HP: 20/20  (White - Safe)
HP: 12/20  (Orange - Caution)
HP: 4/20   (Red - Danger!)
```

### Combat Log Messages
```
=== Lane 1 Combat ===
Knight attacks Skeleton for 2 damage!
Skeleton took 2 damage! (0 HP remaining)
Skeleton has died!
⚠️ Overflow damage: 1 damage goes to player!
=================

💔 Player took 1 damage! (19 HP remaining)
```

---

## ✅ Win/Loss Conditions (Updated)

### Old Loss Condition:
- No units on board + No body cards in hand/deck

### New Loss Condition:
- **Player HP reaches 0**

Much simpler and more intuitive!

---

## 🧪 Testing the New System

### Test 1: Overflow Damage
1. Summon Skeleton (1 HP) to Lane 1
2. End turn → Enemy spawns (e.g., Knight with 2 ATK)
3. End turn → Combat resolves
4. Watch: "Overflow damage: 1 damage goes to player!"
5. Check HP label: Should show 19/20

### Test 2: Direct Attack
1. Draw equipment cards (skip bodies)
2. End turn → Enemy spawns
3. End turn → Enemy attacks empty lane
4. Watch: "Knight attacks player directly for 2 damage!"
5. Check HP label: Should decrease

### Test 3: Shield Saves You
1. Summon Skeleton + equip Shield (4 HP total)
2. End turn → Enemy Knight (2 ATK) spawns
3. End turn → Skeleton survives with 2 HP
4. Check: HP label unchanged! (No overflow)

---

## 🎯 Balance Implications

### This Makes You:
- **Value high ATK builds** (Kill before counter-attack!)
- **Value high HP units** (Zombies prevent overflow)
- **Equip strategically** (ATK to one-shot, HP to tank)
- **Fill lanes faster** (Can't ignore threats)
- **Think ahead** (Can I kill this before it hits me?)

### Prevents:
- Stalling indefinitely
- Ignoring combat
- Leaving lanes empty
- Infinite defensive strategies

### Encourages:
- **Aggressive play** (killing enemies = no counter-attack)
- **Strategic equipment** (when to buff ATK vs HP)
- **Risk/reward** (glass cannon vs tank builds)
- **Diverse strategies** (multiple viable builds)

---

## 📝 Code Changes Summary

### Files Modified:
1. **`combat_manager.gd`**
   - Added `player_hp` and `max_player_hp` variables
   - Added `take_damage()` method
   - Updated loss condition to check HP
   - Combat phase now collects overflow damage

2. **`lane.gd`**
   - `resolve_combat()` now returns overflow damage
   - Calculates overkill when enemy kills player unit
   - Handles empty lane direct attacks

3. **`main.gd`**
   - Added `player_hp_label` reference
   - Added `_update_hp_display()` method
   - Color codes HP (white/orange/red)

4. **`main.tscn`**
   - Added PlayerHPLabel to UI

---

## 🚀 Future Enhancements (Optional)

- [ ] Heal mechanics (Rest nodes restore 5 HP?)
- [ ] Max HP upgrades (Find relic: +5 max HP)
- [ ] Armor system (Reduce overflow by 1?)
- [ ] Lifesteal units (Vampire: attacks heal you)
- [ ] Damage animations (screen shake on hit)
- [ ] HP bar visual (progress bar instead of text)

Current implementation is fully functional - these are polish/expansion features!

---

**HP system is live! Test it out and watch those overflow damage numbers!** 🩸💀
