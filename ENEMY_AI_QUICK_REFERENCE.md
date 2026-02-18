# Enemy AI Quick Reference

## Personality Types at a Glance

| Personality | Goal | Lane Priority | Unit Preference | Difficulty |
|------------|------|---------------|-----------------|------------|
| **AGGRESSIVE** | Spread wide | Empty lanes (3x) | Barbarians (35%), Thieves (25%) | Medium |
| **DEFENSIVE** | Stack up | Lanes with enemies (5x) | Knights (60%), Squires (30%) | Medium-Hard |
| **MIRROR** | Contest player | Lanes with player units (4x) | Matches player strength | Hard |
| **PUNISHER** | Exploit weakness | Adapts to HP (>15 aggressive) | Adapts to HP situation | Hardest |
| **WAVE** | Scripted ramp | Random | Turn-based (Squires→Knights→Barbarians) | Easiest |
| **CHAOTIC** | Random favorites | Random | 70% favorites, 30% others | Medium |

## How to Identify AI by Turn 3

### Aggressive
- ✅ Enemies in 3-5 different lanes
- ✅ No stacking (max 1 per lane)
- ✅ Mix of Barbarians and Thieves

### Defensive
- ✅ Enemies clustered in 1-2 lanes
- ✅ Multiple enemies stacked together
- ✅ Mostly Knights and Squires

### Mirror
- ✅ Enemies always in your lanes
- ✅ If you have no units, no spawns
- ✅ Enemy strength matches yours

### Punisher
- ✅ Changes behavior when you hit 15 HP
- ✅ Above 15 HP: spreads wide, high attack
- ✅ Below 15 HP: stacks defensively

### Wave
- ✅ Only Squires turns 1-3
- ✅ Only Knights turns 4-6
- ✅ Completely predictable

### Chaotic
- ✅ Only 2-3 enemy types appear
- ✅ Same types keep spawning
- ✅ Different each game

## Counter-Strategies

### vs Aggressive
1. **Spread defense** - Put units in multiple lanes
2. **Race damage** - They don't block well
3. **Equipment distribution** - Spread thin across board

### vs Defensive
1. **Avoid contested lanes** - Don't fight their walls
2. **Focus undefended lanes** - Push damage where they're weak
3. **High-attack units** - One-shot their defenders

### vs Mirror
1. **Bait and switch** - Weak unit in one lane, push another
2. **Rapid lane switching** - Summon → attack → abandon
3. **Equipment on weak units** - Trick them into wrong spawns

### vs Punisher
1. **HP management** - Stay at 16 HP to force defensive mode
2. **Recognize thresholds** - Watch behavior shift at 15 HP
3. **Adapt quickly** - Most dynamic AI, hardest to counter

### vs Wave
1. **Save equipment** - Stockpile for turn 4+ spike
2. **Rush victory** - End before turn 7 Barbarian wave
3. **Plan ahead** - Completely predictable, no surprises

### vs Chaotic
1. **Observe early** - Identify favorites by turn 2
2. **Build counters** - Adapt deck to expected enemies
3. **Flexible strategy** - Can't predict until you see it

## Tuning Guide for Developers

### To Make AI Easier
```gdscript
# Reduce spawn rate
const MAX_SPAWNS_PER_TURN: int = 1  # Was 2

# Weaken unit preferences
"Barbarian": 0.20,  # Was 0.35 (less high-attack)
"Squire": 0.30      # Was 0.15 (more low-attack)

# Increase history penalty
const REPEAT_PENALTY: float = 0.1  # Was 0.3 (more variety = weaker combos)
```

### To Make AI Harder
```gdscript
# Increase spawn rate (dangerous!)
const MAX_SPAWNS_PER_TURN: int = 3  # Was 2

# Strengthen unit preferences
"Barbarian": 0.50,  # Was 0.35 (more high-attack)
"Knight": 0.70      # Was 0.60 (tankier)

# Reduce history penalty
const REPEAT_PENALTY: float = 0.5  # Was 0.3 (less penalty = more spam)
```

### To Add More Variety
```gdscript
# Flatten probabilities
"Barbarian": 0.30,  # Was 0.35
"Thief": 0.25,      # Was 0.25
"Knight": 0.25,     # Was 0.25
"Squire": 0.20      # Was 0.15 (more even distribution)
```

### To Make More Predictable
```gdscript
# Steeper probabilities
"Knight": 0.80,     # Was 0.60 (dominant choice)
"Squire": 0.15,     # Was 0.30
"Barbarian": 0.05   # Was 0.10 (rare)
```

## Debug Console Output

### What You'll See
```
[EnemyAI] Personality selected: AGGRESSIVE
[EnemyAI] Cached 4 unique enemy types

=== ENEMY SPAWN (Turn 1 | AGGRESSIVE) ===
Enemies on board: 0/5
Can spawn: 2 enemies
  -> Spawned Barbarian to Lane 2
  -> Spawned Thief to Lane 5
Total spawned: 2
================================
```

### Key Indicators
- **Personality line** - Shows which AI is active
- **Turn counter** - Helps track Wave AI progression
- **Lane selection** - Shows which lanes AI prefers
- **Unit spawns** - Shows which enemy types appear most

## Testing Checklist

- [ ] Play 5 games, see all 6 personalities
- [ ] Aggressive: Confirm wide spread (3+ lanes by turn 2)
- [ ] Defensive: Confirm stacking (2+ in one lane by turn 3)
- [ ] Mirror: Test with no units (should skip spawns)
- [ ] Mirror: Test with weak/strong units (observe matching)
- [ ] Punisher: Drop to 14 HP, observe behavior change
- [ ] Wave: Confirm turn 4 spike (all Knights)
- [ ] Wave: Confirm turn 7 spike (all Barbarians)
- [ ] Chaotic: Restart 3x, see different favorites
- [ ] History: Confirm no 3+ same unit in a row
- [ ] Balance: Target 40-60% win rate across all AIs

## Common Issues

### "AI spawns same unit repeatedly"
→ Check `spawn_history` is updating correctly
→ Verify `REPEAT_PENALTY` is being applied

### "AI never spawns in my lanes" (Mirror)
→ Intended behavior if you have no units
→ Mirror AI needs targets to contest

### "AI behavior doesn't match personality"
→ Check console for personality name
→ Verify weights are being applied correctly

### "AI spawns too many enemies"
→ Check `MAX_SPAWNS_PER_TURN` (should be 2)
→ Verify `MAX_ENEMIES_ON_BOARD` (should be 5)

### "Wave AI doesn't follow turn pattern"
→ Check `game_turn` is incrementing
→ Verify turn thresholds (≤3, ≤6, ≤9, else)

## Performance Notes

- **RNG Seeding**: Consistent within combat, varies between games
- **Card Caching**: Enemy types cached at init for fast lookups
- **Weight Calculation**: Done per spawn (2x per turn max)
- **History Tracking**: Array capped at 3 items (constant memory)

All operations are O(n) where n = number of lanes (5) or enemy types (4-6). No performance concerns for typical gameplay.
