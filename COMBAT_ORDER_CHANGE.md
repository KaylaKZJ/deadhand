# Player Attacks First - Combat Order Change

## ⚔️ What Changed

**Before:** Units attacked simultaneously (both dealt damage at same time)  
**After:** **Player units attack FIRST, enemies counter only if alive**

---

## 🎯 Why This Matters

### Key Advantage: You Can Kill Enemies Before They Hit You!

**Example:**
```
Your Skeleton + Iron Sword: 1 HP, 4 ATK
Enemy Squire: 2 HP, 1 ATK

OLD (Simultaneous):
- Both attack at once
- Squire dies, Skeleton takes 1 damage (dies)
- Result: Trade

NEW (Player First):
- Skeleton attacks → Squire dies (2 HP → 0)
- Squire is DEAD, cannot counter-attack
- Result: Skeleton survives! ✅
```

---

## 💡 Strategic Implications

### 1. **Glass Cannon Builds Are Now Viable**

**High ATK, Low HP:**
- Skeleton (1 HP) + Iron Sword (+3 ATK) = **4 ATK**
- Can one-shot Squires (2 HP) and Thieves (3 HP)
- **Takes 0 damage** if enemy dies first!

### 2. **ATK Equipment Has New Value**

**Before:** Shield always better (survive counter-attack)  
**After:** Sword can be better (kill before counter)

**Decision:**
- Enemy has 2 HP? → Equip Rusty Axe (+2 ATK) to one-shot
- Enemy has 5 HP? → Equip Shield (+3 HP) to survive

### 3. **Risk/Reward Choices**

**Aggressive (High Risk, High Reward):**
- Stack ATK equipment
- Try to one-shot enemies
- If it works: Take 0 damage!
- If it fails: Overflow damage hurts

**Defensive (Low Risk, Low Reward):**
- Stack HP equipment
- Tank hits and prevent overflow
- Always survives (if enough HP)
- Slower enemy kills

---

## 📊 Combat Examples

### Example 1: One-Shot Success
```
Lane 1:
- Your: Skeleton (1 HP, 1 ATK) + Iron Sword (+3 ATK) = 4 ATK
- Enemy: Squire (2 HP, 1 ATK)

Combat:
1. Skeleton attacks Squire for 4 damage
2. Squire dies (2 HP - 4 ATK = -2)
3. Squire CANNOT counter (already dead)

Result: Skeleton wins, takes 0 damage! 🎉
```

### Example 2: Failed One-Shot (Overflow)
```
Lane 2:
- Your: Skeleton (1 HP, 1 ATK) + Rusty Axe (+2 ATK) = 3 ATK
- Enemy: Knight (5 HP, 2 ATK)

Combat:
1. Skeleton attacks Knight for 3 damage (5 → 2 HP)
2. Knight survives, counter-attacks for 2 damage
3. Skeleton dies (1 HP - 2 ATK = -1)
4. Overflow: 1 damage to player

Result: Knight survives, you take 1 damage 💔
```

### Example 3: Tank Build (Survives)
```
Lane 3:
- Your: Zombie (3 HP, 2 ATK) + Shield (+3 HP) = 6 HP, 2 ATK
- Enemy: Barbarian (4 HP, 4 ATK)

Combat:
1. Zombie attacks Barbarian for 2 damage (4 → 2 HP)
2. Barbarian counter-attacks for 4 damage (6 → 2 HP)
3. Zombie survives with 2 HP!

Result: Both survive, no overflow ✅
Next turn: Zombie finishes off weakened Barbarian
```

---

## 🎮 Gameplay Impact

### Encourages Diverse Strategies:

#### Strategy 1: "Assassin Build"
- Focus: High ATK
- Cards: Skeletons + Iron Swords
- Goal: One-shot everything
- Risk: Die if you miss the kill

#### Strategy 2: "Tank Build"
- Focus: High HP
- Cards: Zombies + Shields
- Goal: Survive everything, prevent overflow
- Risk: Slower, enemies accumulate

#### Strategy 3: "Balanced Build"
- Focus: Medium ATK + HP
- Cards: Skeletons + Axe + Shield
- Goal: Flexibility for any matchup
- Risk: Not optimized for specific threats

---

## 🧪 Test Scenarios

### Test 1: One-Shot Mechanic
1. Summon Skeleton
2. Equip Iron Sword (1 HP, 4 ATK)
3. End turn → Squire (2 HP) spawns
4. End turn → Watch combat
5. **Expected:** Skeleton kills Squire, takes 0 damage

### Test 2: Failed One-Shot
1. Summon Skeleton (naked, 1 HP, 1 ATK)
2. End turn → Knight (5 HP, 2 ATK) spawns
3. End turn → Watch combat
4. **Expected:** 
   - Skeleton damages Knight (5 → 4 HP)
   - Knight kills Skeleton
   - 1 overflow damage to player

### Test 3: Tank Survives
1. Summon Zombie + Shield (6 HP, 2 ATK)
2. End turn → Barbarian (4 HP, 4 ATK) spawns
3. End turn → Watch combat
4. **Expected:**
   - Zombie damages Barbarian (4 → 2 HP)
   - Barbarian damages Zombie (6 → 2 HP)
   - Both survive, no overflow

---

## 📈 Balance Considerations

### Makes These Cards Better:
- **Iron Sword** (+3 ATK) - Can enable one-shots
- **Rusty Axe** (+2 ATK) - Cheap way to boost killing power
- **Ghost** (2 HP, 3 ATK) - High base ATK for one-shots
- **Skeleton** - Low HP okay if you kill first

### Makes These Cards Still Important:
- **Shield** (+3 HP) - Still needed vs big threats
- **Zombie** (3 HP) - Still best blocker
- **Helmet** (+2 HP) - Prevents overflow

### Creates Build Variety:
- **Early game:** Mix of bodies (need board)
- **Mid game:** Choose ATK or HP based on threats
- **Late game:** Optimize builds for remaining enemies

---

## 🎯 Design Goals Achieved

✅ **More interesting decisions** (ATK vs HP trade-off)  
✅ **Rewards skillful play** (one-shot = no damage taken)  
✅ **Multiple viable strategies** (aggro vs tank vs balanced)  
✅ **Tactical depth** (knowing when to go offensive)  
✅ **Risk/reward tension** (glass cannon risk vs tank safety)

---

## 🔄 Code Changes

### File: `scripts/board/lane.gd`

**Old Combat Resolution:**
```gdscript
# Enemy attacks first
enemy_unit.attack_target(player_unit)
# Player counter-attacks
player_unit.attack_target(enemy_unit)
```

**New Combat Resolution:**
```gdscript
# Player attacks FIRST
player_unit.attack_target(enemy_unit)

# Enemy counter-attacks ONLY if still alive
if enemy_unit and is_instance_valid(enemy_unit):
    enemy_unit.attack_target(player_unit)
```

Simple change, huge impact!

---

**Player attacks first = Tactical advantage! Use it wisely!** ⚔️💀
