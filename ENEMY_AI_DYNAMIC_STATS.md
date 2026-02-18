# Enemy AI Dynamic Stats System

## Overview
The Enemy AI now **dynamically reads stats from enemy resource files** instead of using hardcoded assumptions. This means you can change enemy stats in `.tres` files and the AI will automatically adapt its behavior.

## What Changed

### Before (Hardcoded)
```gdscript
func _get_aggressive_weights() -> Dictionary:
    return {
        "Barbarian": 0.35,  # Had to manually set these
        "Thief": 0.25,
        "Knight": 0.25,
        "Squire": 0.15
    }
```

**Problem**: If you change Barbarian's attack from 3 to 5, the AI wouldn't know it's now stronger.

### After (Dynamic)
```gdscript
func _get_aggressive_weights() -> Dictionary:
    var weights = {}
    
    for unit_name in available_enemy_types.keys():
        var card: BodyCardResource = available_enemy_types[unit_name]
        # Weight by attack value - higher attack = higher weight
        weights[unit_name] = float(card.attack) / 10.0
    
    return _normalize_weights(weights)
```

**Benefit**: AI automatically prefers units with higher attack stats, no matter what you set in the resource files.

---

## How Each Personality Now Works

### 1. Aggressive (High-Attack Preference)
**Formula**: `weight = attack / 10.0`

- Unit with 3 ATK → weight 0.30
- Unit with 5 ATK → weight 0.50
- **Result**: Naturally prefers higher-attack enemies

**Example**: If you create a new enemy "Berserker" with 6 ATK, Aggressive AI will automatically prefer it over Barbarians.

---

### 2. Defensive (High-HP Preference)
**Formula**: `weight = hp / 10.0`

- Unit with 2 HP → weight 0.20
- Unit with 5 HP → weight 0.50
- **Result**: Naturally prefers tankier enemies

**Example**: If you buff Knight's HP from 5 to 7, Defensive AI will spawn Knights even more often.

---

### 3. Mirror (Match Player Strength)
**Formula**: `similarity = 1.0 / (1.0 + |enemy_total - player_total|)`

- Player has 3 HP + 2 ATK = 5 total
- Enemy A: 2 HP + 1 ATK = 3 total → difference 2 → weight 0.33
- Enemy B: 3 HP + 2 ATK = 5 total → difference 0 → weight 1.00
- **Result**: Spawns Enemy B (exact match)

**Example**: If player summons a 8-total-stat unit, AI will spawn the closest match available (e.g., 6-7 total).

---

### 4. Punisher (Adaptive)
**Behavior**: 
- Player HP > 15: Uses Aggressive weights (prefer high attack)
- Player HP ≤ 15: Uses Defensive weights (prefer high HP)

**Example**: If you nerf all enemy HP by 1, Punisher will still pick the highest-HP units when defensive.

---

### 5. Wave (Weakest → Strongest Progression)
**Dynamic Sorting**: 
1. Sorts enemies by `HP + Attack` (total stats)
2. Turn 1-3: Spawns weakest enemy type (70% chance)
3. Turn 4-6: Spawns 2nd weakest (70% chance)
4. Turn 7-9: Spawns 2nd strongest (70% chance)
5. Turn 10+: Spawns strongest (70% chance)

**Example**:
- Current enemies: Squire (2+1=3), Knight (5+2=7), Thief (3+2=5), Barbarian (4+3=7)
- Sorted: Squire (3), Thief (5), Knight (7), Barbarian (7)
- Turn 1-3: 70% Squire, 20% Thief, 10% others
- Turn 4-6: 70% Thief, 20% Squire/Knight, 10% Barbarian
- Turn 7+: 70% Knight/Barbarian (tied for strongest)

**Benefit**: If you add a new "Ogre" with 10 total stats, it automatically becomes the "final boss" in Wave progression.

---

### 6. Chaotic (Random Favorites)
**No Change**: Still randomly picks 2-3 favorites at game start (70% chance), but now works with any enemy types you add.

---

## New Helper Functions

### `_normalize_weights(weights: Dictionary) -> Dictionary`
**Purpose**: Ensures all weights sum to 1.0 (valid probability distribution)

**Example**:
```gdscript
Input:  {"Knight": 0.5, "Squire": 0.3, "Barbarian": 0.2}  # Sum = 1.0
Output: {"Knight": 0.5, "Squire": 0.3, "Barbarian": 0.2}  # Already normalized

Input:  {"Knight": 5.0, "Squire": 3.0}  # Sum = 8.0
Output: {"Knight": 0.625, "Squire": 0.375}  # Normalized to 1.0
```

---

### `_get_weakest_unit_weights() -> Dictionary`
**Purpose**: Returns the weakest enemy (used by Mirror when player has no units)

**Logic**: Finds enemy with lowest `HP + Attack`, returns weight 1.0 for it

---

## Adding New Enemies

### Before Dynamic System
1. Create `resources/enemies/ogre.tres` (10 HP, 5 ATK)
2. ❌ **FORGOT THIS**: Update enemy_ai.gd with "Ogre" hardcoded weights
3. AI never spawns Ogres (broken!)

### With Dynamic System
1. Create `resources/enemies/ogre.tres` (10 HP, 5 ATK)
2. ✅ **That's it!** AI automatically:
   - Aggressive: Heavily prefers Ogre (highest attack)
   - Defensive: Heavily prefers Ogre (highest HP)
   - Mirror: Spawns Ogre vs strong player units
   - Wave: Ogre becomes the turn 10+ spawn
   - Punisher: Uses Ogre when going aggressive

---

## Balancing Examples

### Example 1: Nerf Barbarians
**Change**: `resources/enemies/barbarian.tres` - Attack 3 → 2

**AI Response**:
- Aggressive: Spawns Barbarians 40% less often (lower attack weight)
- Mirror: Barbarians now match weaker player units
- Wave: Barbarians drop from turn 7+ to turn 4-6 tier

---

### Example 2: Buff Squires
**Change**: `resources/enemies/squire.tres` - HP 2 → 4

**AI Response**:
- Defensive: Spawns Squires 100% more often (higher HP weight)
- Mirror: Squires now match medium-strength player units
- Wave: Squires might move from turn 1-3 to turn 4-6 tier

---

### Example 3: Add Glass Cannon
**New Enemy**: "Assassin" (1 HP, 5 ATK) = 6 total stats

**AI Response**:
- Aggressive: Spawns Assassins frequently (highest attack)
- Defensive: Rarely spawns Assassins (lowest HP)
- Mirror: Spawns vs medium player units (6 total)
- Wave: Appears in turn 4-6 or 7-9 depending on other enemies

---

## Testing the Dynamic System

### Test 1: Stat Changes Propagate
1. Open `resources/enemies/knight.tres`
2. Change HP from 5 → 10
3. Start game with Defensive AI
4. ✅ **Expected**: Knights spawn way more often (highest HP)

---

### Test 2: New Enemy Integration
1. Duplicate `barbarian.tres` → `ogre.tres`
2. Set stats: 12 HP, 6 ATK (18 total)
3. Add to enemy deck in `DeckManager`
4. Start game with any AI
5. ✅ **Expected**: Ogre appears based on stats (heavily in Aggressive/Wave late)

---

### Test 3: Rebalance Without Code Changes
1. **Problem**: Aggressive AI too hard
2. **Solution**: Reduce all enemy attack stats by 1
3. ✅ **Expected**: Aggressive AI automatically becomes easier (no code changes!)

---

## Performance Notes

- **Calculation Frequency**: Weight calculations happen 2x per turn (max 2 spawns)
- **Complexity**: O(n) where n = number of enemy types (typically 4-6)
- **Caching**: Enemy types cached at game start in `available_enemy_types`
- **Impact**: Negligible - dynamic calculation is faster than reading strings

---

## Debugging

### Check Calculated Weights
Add debug output to see what the AI is thinking:

```gdscript
func _get_aggressive_weights() -> Dictionary:
    var weights = {}
    
    for unit_name in available_enemy_types.keys():
        var card: BodyCardResource = available_enemy_types[unit_name]
        weights[unit_name] = float(card.attack) / 10.0
        print("[Aggressive] %s (ATK %d) → weight %.2f" % [unit_name, card.attack, weights[unit_name]])
    
    return _normalize_weights(weights)
```

**Console Output**:
```
[Aggressive] Squire (ATK 1) → weight 0.10
[Aggressive] Knight (ATK 2) → weight 0.20
[Aggressive] Thief (ATK 2) → weight 0.20
[Aggressive] Barbarian (ATK 3) → weight 0.30
[After normalization] Squire: 0.125, Knight: 0.25, Thief: 0.25, Barbarian: 0.375
```

---

## Migration Guide (If Reverting)

If you need to go back to hardcoded weights:

```gdscript
func _get_aggressive_weights() -> Dictionary:
    # Replace dynamic calculation with fixed values
    return {
        "Barbarian": 0.35,
        "Thief": 0.25,
        "Knight": 0.25,
        "Squire": 0.15
    }
```

But you'll lose the automatic adaptation benefits!

---

## Summary of Benefits

✅ **No Code Changes Needed**: Adjust enemy stats in `.tres` files, AI adapts automatically  
✅ **New Enemy Support**: Add new enemies without touching `enemy_ai.gd`  
✅ **Easier Balancing**: Nerf/buff enemies, AI behavior updates naturally  
✅ **More Accurate**: AI always knows true enemy strength (no outdated hardcoded values)  
✅ **Future-Proof**: Works with any number of enemy types  
✅ **Maintainable**: Less code to update when rebalancing  

---

## Future Enhancements

### Weighted by Multiple Stats
```gdscript
func _get_aggressive_weights() -> Dictionary:
    var weights = {}
    
    for unit_name in available_enemy_types.keys():
        var card: BodyCardResource = available_enemy_types[unit_name]
        # Consider both attack AND HP (70% attack, 30% HP)
        weights[unit_name] = (card.attack * 0.7 + card.hp * 0.3) / 10.0
    
    return _normalize_weights(weights)
```

### Consider Equipment Slots
```gdscript
# Prefer enemies with more equipment slots (harder to kill when equipped)
weights[unit_name] = card.hp + card.equipment_slots * 2.0
```

### Read Custom Properties
If you add new stats to `BodyCardResource`:
```gdscript
@export var armor: int = 0
@export var speed: int = 1
```

AI can automatically use them:
```gdscript
# Prefer armored enemies when defensive
weights[unit_name] = card.hp + card.armor * 1.5
```

---

## Conclusion

The AI is now **data-driven** instead of **hardcoded**. You control AI behavior by adjusting enemy stats, not by editing AI code. This makes balancing faster, adding content easier, and reduces bugs from outdated assumptions.

**Golden Rule**: If you want the AI to prefer an enemy type, give it higher stats for that personality's focus (attack for Aggressive, HP for Defensive, etc.).
