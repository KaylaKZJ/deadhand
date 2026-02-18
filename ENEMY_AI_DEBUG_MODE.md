# Debug Mode: Force AI Personality

## Quick Setup

The `EnemyAI` node now has a `debug_force_personality` property that lets you force-test specific AI personalities.

### How to Use

1. **Open the Scene**: `scenes/main.tscn` (or wherever your `EnemyAI` node is)
2. **Select the EnemyAI node** in the Scene tree
3. **In the Inspector**, find `Debug Force Personality`
4. **Set the value**:
   - `-1` = Random (normal gameplay) ← **Default**
   - `0` = Force AGGRESSIVE
   - `1` = Force DEFENSIVE
   - `2` = Force MIRROR
   - `3` = Force PUNISHER
   - `4` = Force WAVE
   - `5` = Force CHAOTIC

### Visual Guide

```
Inspector Panel:
┌──────────────────────────────────┐
│ EnemyAI (Script)                 │
├──────────────────────────────────┤
│ Debug Force Personality: [  -1 ] │  ← Change this!
│ Deck Manager: [DeckManager    ] │
│ Combat Manager: [CombatManager] │
└──────────────────────────────────┘
```

---

## Example Use Cases

### Test Specific Personality
**Scenario**: You want to see how MIRROR AI behaves

**Steps**:
1. Set `Debug Force Personality` to `2`
2. Run the game
3. Console shows: `🔧 DEBUG MODE: Forced personality to MIRROR`
4. Every game will be MIRROR until you change it

---

### Test All Personalities Sequentially
**Scenario**: Check all 6 AIs one by one

**Steps**:
1. Set to `0` → Test AGGRESSIVE
2. Set to `1` → Test DEFENSIVE
3. Set to `2` → Test MIRROR
4. Set to `3` → Test PUNISHER
5. Set to `4` → Test WAVE
6. Set to `5` → Test CHAOTIC
7. Set to `-1` → Return to random

---

### Test Balance Changes
**Scenario**: You buffed Barbarians, want to test if Aggressive AI uses them more

**Steps**:
1. Set `Debug Force Personality` to `0` (AGGRESSIVE)
2. Play 3-5 games
3. Count how often Barbarians spawn
4. Adjust stats
5. Test again with same AI

---

## Console Output

### Normal Mode (Random)
```
[EnemyAI] Personality selected: DEFENSIVE
```

### Debug Mode (Forced)
```
[EnemyAI] 🔧 DEBUG MODE: Forced personality to MIRROR
```

The 🔧 emoji makes it obvious you're in debug mode!

---

## Personality Enum Reference

For quick reference when setting values:

| Value | Personality | Behavior |
|-------|-------------|----------|
| `0` | AGGRESSIVE | Spreads wide, high-attack units |
| `1` | DEFENSIVE | Stacks enemies, high-HP units |
| `2` | MIRROR | Contests player lanes, matches strength |
| `3` | PUNISHER | Adapts to HP (aggressive/defensive) |
| `4` | WAVE | Weakest → strongest by turn |
| `5` | CHAOTIC | Random 2-3 favorites per game |
| `-1` | **RANDOM** | Normal gameplay (default) |

---

## Code Reference

If you need to set this via script (e.g., for automated testing):

```gdscript
# In main.gd or test script
enemy_ai.debug_force_personality = EnemyAI.Personality.MIRROR
enemy_ai.initialize(deck_manager, combat_manager)

# Or to reset to random
enemy_ai.debug_force_personality = -1
```

---

## Playtesting Workflow

### Quick Personality Check
```
1. Set to 0 (AGGRESSIVE) → Play 1 game → Note behavior
2. Set to 1 (DEFENSIVE)  → Play 1 game → Note behavior
3. Set to 2 (MIRROR)     → Play 1 game → Note behavior
... etc
```

### Deep Testing Single Personality
```
1. Set to desired personality (e.g., 3 = PUNISHER)
2. Play 10+ games
3. Track win rate
4. Adjust weights in enemy_ai.gd if needed
5. Test again
```

### Balance Testing
```
1. Set to -1 (RANDOM)
2. Play 20 games
3. Track which personalities appear (should be ~3-4 of each)
4. Track win rate per personality
5. If any AI has <30% or >70% win rate, tune it
```

---

## Tips

### ✅ Remember to Reset
**Before shipping**: Set `Debug Force Personality` back to `-1` so players get random AIs!

### ✅ Test Counter-Strategies
Force a personality, then try its counter-strategy from the design doc:
- AGGRESSIVE → Spread defense wide
- DEFENSIVE → Focus undefended lanes
- MIRROR → Bait & switch

### ✅ Test Edge Cases
- MIRROR with no player units (should spawn weakest)
- PUNISHER at exactly 15 HP (behavior change threshold)
- WAVE at turn 4, 7, 10 (progression checkpoints)

### ✅ Test Stat Changes
1. Force AGGRESSIVE
2. Note spawn frequency
3. Change enemy attack stats
4. Test again with same forced AI
5. Verify spawn patterns changed

---

## Troubleshooting

### "AI still seems random even when forced"
- Check the console for `🔧 DEBUG MODE` message
- Verify you saved the scene after changing the value
- Make sure you're editing the EnemyAI node, not a different node

### "Invalid value" error
- Value must be -1 to 5 (6 personalities total)
- Values outside this range are ignored (fallback to random)

### "Chaotic still has random favorites"
- This is intended! Forcing CHAOTIC still randomizes favorites each game
- Favorites are consistent within a single combat session

---

## Advanced: Automated Testing Script

Create `test_all_personalities.gd`:

```gdscript
extends Node

var enemy_ai: EnemyAI
var results = {}

func _ready():
    enemy_ai = get_node("../EnemyAI")
    test_all_personalities()

func test_all_personalities():
    for i in range(6):
        enemy_ai.debug_force_personality = i
        results[i] = []
        
        for game in range(10):
            # Run game
            var won = run_single_game()
            results[i].append(won)
        
        print("Personality %d: Win rate %d%%" % [i, calculate_win_rate(results[i])])
    
    # Reset to random
    enemy_ai.debug_force_personality = -1

func run_single_game() -> bool:
    # Your game simulation logic
    pass

func calculate_win_rate(results: Array) -> int:
    var wins = results.filter(func(x): return x == true).size()
    return (wins * 100) / results.size()
```

---

## Summary

**Quick Access**: Inspector → EnemyAI node → `Debug Force Personality`

**Values**:
- `-1` = Random (normal)
- `0-5` = Force specific personality

**Remember**: Set back to `-1` before releasing! 🚀
