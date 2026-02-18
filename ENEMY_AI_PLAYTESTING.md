# Enemy AI Playtesting Guide

## Goal
Test all 6 AI personalities, verify they feel distinct, and ensure 40-60% win rate.

## Phase 1: Personality Recognition (5 games)

### Test Matrix
Play 5 games and track which personality appears:

| Game | Personality | Recognized by Turn 3? | Notes |
|------|-------------|----------------------|-------|
| 1    |             | ☐ Yes ☐ No           |       |
| 2    |             | ☐ Yes ☐ No           |       |
| 3    |             | ☐ Yes ☐ No           |       |
| 4    |             | ☐ Yes ☐ No           |       |
| 5    |             | ☐ Yes ☐ No           |       |

**Success Criteria**: Player can identify AI type within 3 turns by observing spawn patterns.

### Recognition Guide
Check console at game start: `[EnemyAI] Personality selected: AGGRESSIVE`

Then observe:
- **Aggressive**: Lanes 1, 3, 5 filled by turn 3
- **Defensive**: Lanes 2, 2, 2 (stacking)
- **Mirror**: Spawns only where you have units
- **Punisher**: Behavior changes when HP drops
- **Wave**: Only Squires early, only Knights turn 4+
- **Chaotic**: Only 2-3 specific enemy types

---

## Phase 2: Win Rate Balance (20 games)

### Tracking Sheet

| Game # | Personality | Result | Turn Count | Player HP | Notes |
|--------|-------------|--------|------------|-----------|-------|
| 1      |             | W / L  |            |           |       |
| 2      |             | W / L  |            |           |       |
| ...    |             | W / L  |            |           |       |
| 20     |             | W / L  |            |           |       |

### Win Rate Targets by Personality
- **Wave**: 60-70% (tutorial AI, easiest)
- **Aggressive**: 45-55% (baseline)
- **Chaotic**: 45-55% (baseline)
- **Defensive**: 35-45% (challenging)
- **Mirror**: 35-45% (challenging)
- **Punisher**: 25-35% (hard mode)

**Success Criteria**: Overall win rate between 40-60% across all games.

---

## Phase 3: Specific Behavior Tests

### Test 1: Aggressive Spread
1. Start game, identify Aggressive AI
2. **Expected**: By turn 3, enemies in 4-5 different lanes
3. **Expected**: No lane has 2+ enemies
4. **Expected**: Mostly Barbarians and Thieves

**Result**: ☐ Pass ☐ Fail  
**Notes**: _____________________

---

### Test 2: Defensive Stacking
1. Start game, identify Defensive AI
2. Summon player units to lanes 2 and 4
3. **Expected**: Enemies stack in same lanes as player (2 and 4)
4. **Expected**: Mostly Knights and Squires

**Result**: ☐ Pass ☐ Fail  
**Notes**: _____________________

---

### Test 3: Mirror Matching
1. Start game, identify Mirror AI
2. Turn 1: Summon weak unit (Skeleton: 1 HP / 1 ATK)
3. **Expected**: Enemy spawns Squire in same lane
4. Turn 2: Summon strong unit (Zombie: 4 HP / 2 ATK)
5. **Expected**: Enemy spawns Knight or Barbarian in that lane

**Result**: ☐ Pass ☐ Fail  
**Notes**: _____________________

---

### Test 4: Mirror with No Units
1. Start game, identify Mirror AI
2. Turn 1: Do NOT summon any units
3. **Expected**: Enemy spawns in random lane (no player units to contest)

**Result**: ☐ Pass ☐ Fail  
**Notes**: _____________________

---

### Test 5: Punisher HP Threshold
1. Start game, identify Punisher AI
2. Track spawns while player HP > 15
3. **Expected**: Enemies spread wide, high-attack units (Barbarians)
4. Take damage until player HP = 14
5. **Expected**: Behavior shifts - enemies stack defensively, Knights/Squires

**Result**: ☐ Pass ☐ Fail  
**HP > 15 spawns**: _____________________  
**HP ≤ 15 spawns**: _____________________

---

### Test 6: Wave Progression
1. Start game, identify Wave AI
2. Turns 1-3: **Expected** only Squires
3. Turns 4-6: **Expected** only Knights
4. Turns 7+: **Expected** Barbarians + Thieves

**Result**: ☐ Pass ☐ Fail  
**Turn 1-3 spawns**: _____________________  
**Turn 4-6 spawns**: _____________________  
**Turn 7+ spawns**: _____________________

---

### Test 7: Chaotic Consistency
1. Start game, identify Chaotic AI
2. Track all enemy spawns for 5 turns
3. **Expected**: Only 2-3 unique enemy types appear
4. Restart game, get Chaotic again
5. **Expected**: Different favorite units than previous game

**Result**: ☐ Pass ☐ Fail  
**Game 1 favorites**: _____________________  
**Game 2 favorites**: _____________________

---

### Test 8: Spawn History Tracking
1. Any personality
2. Track 5 consecutive spawns
3. **Expected**: No more than 2 of the same unit in a row
4. **Expected**: If unit appears 2x, next spawn is different

**Result**: ☐ Pass ☐ Fail  
**Spawn sequence**: _____________________  
**Repeats observed**: _____________________

---

## Phase 4: Counter-Strategy Validation

### Test 9: Counter Aggressive (Spread Defense)
1. Get Aggressive AI
2. Strategy: Summon units to 4+ lanes by turn 3
3. Equip spread thin across board
4. **Expected**: Win rate 50-60% (slightly favored)

**Games Played**: ____ / 5  
**Wins**: ____ / 5  
**Notes**: _____________________

---

### Test 10: Counter Defensive (Focus Fire)
1. Get Defensive AI
2. Strategy: Focus all damage on undefended lanes
3. Ignore contested lanes
4. **Expected**: Win rate 50-60% (slightly favored)

**Games Played**: ____ / 5  
**Wins**: ____ / 5  
**Notes**: _____________________

---

### Test 11: Counter Mirror (Bait & Switch)
1. Get Mirror AI
2. Strategy: Summon weak unit to lane 1
3. Wait for enemy to contest
4. Push damage through other lanes
5. **Expected**: Win rate 50-60% (slightly favored)

**Games Played**: ____ / 5  
**Wins**: ____ / 5  
**Notes**: _____________________

---

### Test 12: Counter Wave (Early Rush)
1. Get Wave AI
2. Strategy: Maximize damage turns 1-6 (before Barbarians)
3. Save equipment for turn 4-6
4. **Expected**: Win rate 70%+ (very favorable)

**Games Played**: ____ / 5  
**Wins**: ____ / 5  
**Notes**: _____________________

---

## Phase 5: Frustration Testing

### Red Flag Checklist
Track any "unfair" moments:

- ☐ **3+ same enemy in a row** (history tracking broken)
- ☐ **5+ enemies spawned in one turn** (spawn limit broken)
- ☐ **Unwinnable spawn pattern** (too many high-attack enemies)
- ☐ **AI never spawns** (logic bug)
- ☐ **All personalities feel the same** (weights not distinct enough)
- ☐ **Can't identify AI type by turn 5** (not learnable)

**Frustration Events**: _____________________

---

## Balance Adjustment Recommendations

### If AI Too Strong (Win Rate < 30%)
1. Reduce `MAX_SPAWNS_PER_TURN` from 2 → 1
2. Nerf high-attack weights (Barbarian 35% → 25%)
3. Buff low-attack weights (Squire 15% → 25%)
4. Increase history penalty (0.3 → 0.1)

### If AI Too Weak (Win Rate > 70%)
1. Increase high-attack weights (Barbarian 35% → 50%)
2. Reduce low-attack weights (Squire 15% → 5%)
3. Tighten lane weights (3x → 5x for preferred lanes)
4. Reduce history penalty (0.3 → 0.5)

### If AI Too Predictable (Boring)
1. Flatten probabilities (60/30/10 → 40/30/30)
2. Reduce history penalty (0.3 → 0.5 allows more repeats)
3. Add more personalities to rotation
4. Implement personality traits (Reckless, Cautious, etc.)

### If AI Too Random (Frustrating)
1. Steepen probabilities (60/30/10 → 80/15/5)
2. Increase history penalty (0.3 → 0.1 enforces variety)
3. Remove Chaotic from rotation
4. Add more deterministic elements

---

## Final Checklist

- [ ] All 6 personalities appear in 20 games
- [ ] Players can identify AI by turn 3 (80%+ success rate)
- [ ] Overall win rate between 40-60%
- [ ] Counter-strategies work (50-70% win rate with correct strategy)
- [ ] No "unfair" frustration moments
- [ ] AI feels intelligent but learnable
- [ ] Spawn history prevents repetition
- [ ] No performance issues (smooth gameplay)

---

## Bug Report Template

**Issue**: _____________________  
**Personality**: _____________________  
**Turn Number**: _____________________  
**Board State**: _____________________  
**Expected Behavior**: _____________________  
**Actual Behavior**: _____________________  
**Console Output**: _____________________  

---

## Success Metrics Summary

| Metric | Target | Result | Pass/Fail |
|--------|--------|--------|-----------|
| Overall Win Rate | 40-60% | ___% | ☐ Pass ☐ Fail |
| Personality Recognition | 80%+ by turn 3 | ___% | ☐ Pass ☐ Fail |
| Wave Win Rate | 60-70% | ___% | ☐ Pass ☐ Fail |
| Punisher Win Rate | 25-35% | ___% | ☐ Pass ☐ Fail |
| Frustration Events | 0-2 per 20 games | ___ | ☐ Pass ☐ Fail |
| Counter-Strategy Works | 50-70% with correct counter | ___% | ☐ Pass ☐ Fail |

**Overall Assessment**: ☐ Ready to Ship ☐ Needs Balance Tweaks ☐ Needs Rework

**Final Notes**: _____________________
