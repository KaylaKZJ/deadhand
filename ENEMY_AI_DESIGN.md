# Enemy AI Design Document

## Overview

The enemy AI in DEADHAND uses **algorithmic behavior patterns** to create intelligent-feeling opponents without requiring machine learning or complex scripting. Each AI personality follows deterministic rules, making them learnable but still challenging.

## Design Philosophy

### Inspiration
- **Slay the Spire**: Enemies telegraph their actions, creating strategic planning opportunities
- **Inscryption**: Scripted behaviors that feel smart but are learnable
- **DEADHAND Twist**: Algorithmic patterns that adapt to game state while remaining deterministic

### Core Principles
1. **Deterministic but Complex**: Same game state → same AI decision (learnable patterns)
2. **Variety Between Games**: Random AI personality selection keeps each game fresh
3. **Learnable Counterplay**: Players can recognize AI type and develop counter-strategies
4. **Emergent Complexity**: Simple rules combine to create interesting situations

---

## AI Personality Types

### 1. **Aggressive (Overwhelm)**
**Goal**: Spread pressure across all lanes, force player to defend everywhere

**Spawn Lane Priority**:
1. Empty lanes (spread wide)
2. Random selection among empty lanes

**Unit Type Preference**:
1. High-attack units (Barbarians, Thieves) - 60% chance
2. Medium units (Knights) - 30% chance
3. Weak units (Squires) - 10% chance

**Strategic Behavior**:
- Never stacks enemies in same lane
- Maximizes board presence
- Forces player to make difficult blocking decisions

**Counter-Strategy**:
- Wide defense (units in multiple lanes)
- Equipment spread thin across board
- Race damage - enemy doesn't protect HP well

---

### 2. **Defensive (Fortress)**
**Goal**: Create immovable walls, force player to overcommit resources

**Spawn Lane Priority**:
1. Lanes with existing enemies (stack up)
2. Lanes with player units (contest them directly)
3. Empty lanes (only if no other option)

**Unit Type Preference**:
1. High-HP units (Knights) - 60% chance
2. Medium units (Squires) - 30% chance
3. High-attack units (Barbarians) - 10% chance

**Strategic Behavior**:
- Creates chokepoints
- Forces player to use multiple equipment on one lane
- Protects enemy HP by blocking player attacks

**Counter-Strategy**:
- Focus damage on undefended lanes
- Use high-attack units (Ghost) to one-shot defenders
- Avoid overcommitting to contested lanes

---

### 3. **Mirror (Adaptive)**
**Goal**: Always contest where player invests, neutralize their strategy

**Spawn Lane Priority**:
1. Lanes with player units (direct confrontation)
2. Lanes adjacent to player units (flanking)
3. Empty lanes (if no player units exist)

**Unit Type Preference**:
- **Matches player unit strength**:
  - If player unit HP+ATK ≤ 2: Spawn Squires
  - If player unit HP+ATK ≤ 5: Spawn Knights
  - If player unit HP+ATK > 5: Spawn Barbarians/Thieves

**Strategic Behavior**:
- Reactive rather than proactive
- Minimizes unblocked damage by always contesting
- Makes player's equipment investments less effective

**Counter-Strategy**:
- Bait with weak units in one lane, push damage elsewhere
- Rapid lane switching (summon → attack → abandon)
- Equipment on weak units to trick AI into spawning strong enemies in wrong lanes

---

### 4. **Punisher (Adaptive State-Based)**
**Goal**: Exploit player's current weakness (HP or board position)

**Spawn Lane Priority** (Dynamic):
- **If player HP > 15**: 
  - Empty lanes (push damage)
  - Prioritize undefended lanes
- **If player HP ≤ 15**: 
  - Lanes with enemies (protect HP lead)
  - Defensive positioning

**Unit Type Preference** (Dynamic):
- **If player HP > enemy HP**: Spawn defensive (Knights, Squires)
- **If enemy HP > player HP**: Spawn aggressive (Barbarians, Thieves)
- **If HP equal**: Balanced mix (50/50 split)

**Strategic Behavior**:
- Reads game state and adapts
- Switches between aggressive and defensive
- Most "intelligent-feeling" AI

**Counter-Strategy**:
- Hardest to counter (most adaptive)
- Requires recognizing state thresholds
- Can be baited by managing HP carefully (staying at 16 HP forces defensive AI)

---

### 5. **Wave (Scripted Progression)**
**Goal**: Predictable difficulty curve, forces different responses over time

**Spawn Lane Priority**:
- Random empty lanes

**Unit Type Preference** (Turn-Based):
- **Turns 1-3**: Only Squires (2 HP / 1 ATK)
- **Turns 4-6**: Only Knights (5 HP / 2 ATK)
- **Turns 7-9**: Mix of Barbarians (4 HP / 3 ATK) and Thieves (3 HP / 2 ATK)
- **Turns 10+**: Only Barbarians (maximum pressure)

**Strategic Behavior**:
- Completely predictable
- Creates clear "phases" of difficulty
- Rewards long-term planning

**Counter-Strategy**:
- Easy early game (Squires are weak)
- Plan equipment usage for turn 4 spike
- Race to end before turn 7+ (avoid Barbarian wave)

---

### 6. **Chaotic (Randomized Consistency)**
**Goal**: Variety between games, but consistent within a game

**Initialization**:
- At game start, randomly select 2-3 "favorite" enemy types
- Example: {Barbarians, Squires} or {Knights, Thieves, Barbarians}

**Spawn Lane Priority**:
- Random lanes (no preference)

**Unit Type Preference**:
- 70% chance: Spawn from "favorites" list
- 30% chance: Spawn any enemy type

**Strategic Behavior**:
- High variance between games
- Consistent within a single game (you learn the pattern)
- Feels "unpredictable" but is technically learnable

**Counter-Strategy**:
- Observe first 2-3 spawns to identify favorites
- Build deck strategy around expected enemy types
- Adapt on the fly

---

## Implementation Architecture

### EnemyAI Class Structure
```gdscript
class_name EnemyAI

enum Personality {
    AGGRESSIVE,
    DEFENSIVE,
    MIRROR,
    PUNISHER,
    WAVE,
    CHAOTIC
}

var current_personality: Personality
var favorite_units: Array[BodyCardResource]  # For CHAOTIC
var game_turn: int  # For WAVE
```

### Core Functions

#### `select_personality()`
- Called at game start
- Randomly chooses AI personality
- Initializes personality-specific data (e.g., CHAOTIC favorites)

#### `choose_spawn_lane(lanes: Array[Lane]) -> Lane`
- Returns best lane based on personality
- Takes current board state as input
- Implements lane priority logic

#### `choose_enemy_unit(lane: Lane) -> BodyCardResource`
- Returns best enemy type for selected lane
- Considers personality preferences
- May read game state (player HP, unit stats, etc.)

#### `spawn_enemies(lanes: Array[Lane])`
- Main entry point (called each turn)
- Calls `choose_spawn_lane()` and `choose_enemy_unit()`
- Respects spawn limits (2 per turn, 5 max on board)

---

## UI Integration

### Personality Indicator (Top of Screen)
Display current AI personality to help players learn:
- "Enemy Strategy: AGGRESSIVE" (red text)
- "Enemy Strategy: DEFENSIVE" (blue text)
- "Enemy Strategy: MIRROR" (purple text)
- etc.

### Intent System (Optional - Advanced)
Like Slay the Spire, show what enemy will do next turn:
- "Planning to spawn in lanes: 2, 4"
- "Targeting: High-attack units"

This requires adding a "telegraph" phase before actual spawning.

---

## Balancing Considerations

### AI Strength Ranking (Estimated)
1. **Punisher** - Hardest (adapts to game state)
2. **Mirror** - Hard (neutralizes player strategy)
3. **Defensive** - Medium-Hard (forces resource commitment)
4. **Aggressive** - Medium (predictable but pressuring)
5. **Chaotic** - Medium (depends on favorite units)
6. **Wave** - Easiest (completely predictable)

### Win Rate Targets
- **Wave**: 70% player win rate (tutorial AI)
- **Aggressive/Chaotic**: 50% player win rate (baseline)
- **Defensive/Mirror**: 40% player win rate (challenging)
- **Punisher**: 30% player win rate (hard mode)

### Tuning Knobs
If AI too strong/weak, adjust:
1. **Unit type probabilities** (make favorites weaker/stronger)
2. **Spawn limits** (reduce from 2/turn to 1/turn)
3. **HP thresholds** (Punisher switches at 15 → change to 12 or 18)
4. **Enemy stats** (nerf Barbarian to 4/2 instead of 4/3)

---

## Testing Plan

### Phase 1: Individual AI Testing
- Play 5 games against each AI personality
- Track: win rate, avg game length, most frustrating moments
- Identify obviously broken strategies

### Phase 2: Balance Tuning
- Adjust probabilities and thresholds
- Aim for 40-60% player win rate across all AIs
- Ensure no single counter-strategy beats all AIs

### Phase 3: Variety Testing
- Play 20 games with random AI selection
- Confirm each AI feels distinct
- Validate that players can learn patterns within 2-3 games

### Phase 4: Advanced Players
- Give to experienced card game players
- See if they can identify AI personality from spawns
- Test if meta-strategies emerge

---

## Future Enhancements

### 1. Hybrid Personalities
Combine two behaviors:
- "Defensive-Punisher": Fortress when ahead, aggressive when behind
- "Aggressive-Wave": Spreads wide but with scripted unit progression

### 2. Difficulty Modes
- **Easy**: Always use Wave AI
- **Normal**: Random selection (all 6 AIs)
- **Hard**: Only Punisher and Mirror

### 3. AI Learning (Meta)
Track which strategies players use most:
- If player always goes wide → spawn more Mirror AI
- If player turtles → spawn more Aggressive AI
- Creates dynamic difficulty over multiple sessions

### 4. Named Enemies
Give each AI personality a character:
- **Aggressive**: "The Horde" (goblin swarm)
- **Defensive**: "The Fortress" (armored knights)
- **Mirror**: "The Shadow" (mimics player)
- **Punisher**: "The Tactician" (strategic general)
- **Wave**: "The Siege" (organized army)
- **Chaotic**: "The Wildcard" (unpredictable mercenaries)

---

## Summary

This AI system provides:
✅ **Depth**: 6 distinct personalities with unique counter-strategies  
✅ **Learnability**: Deterministic patterns players can master  
✅ **Variety**: Random selection keeps games fresh  
✅ **Scalability**: Easy to add new personalities or tune existing ones  
✅ **Engagement**: Players feel like they're outsmarting an intelligent opponent  

The algorithmic approach is perfect for a small-scale card battler - sophisticated enough to feel smart, simple enough to implement and balance quickly.
