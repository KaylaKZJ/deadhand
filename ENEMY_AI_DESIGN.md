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

## Adding Randomization While Keeping Strategic Depth

### The Problem with Pure Determinism
Slay the Spire and Inscryption use **fully deterministic** enemy AI - same situation always produces the same action. This has benefits (learnable, puzzle-like) but drawbacks:

**Cons of Pure Determinism:**
- Once you learn the pattern, fights feel "solved"
- Replaying the same encounter is identical (boring)
- No emergent moments or surprises
- Can feel robotic rather than intelligent

### The Problem with Pure Randomness
Fully random AI (pick any action at random) feels chaotic and frustrating:

**Cons of Pure Randomness:**
- No skill expression - you can't plan
- "I lost to RNG" moments
- Feels arbitrary rather than strategic
- Hard to balance (too swingy)

### The Solution: **Controlled Randomization**

The sweet spot is **probabilistic decision-making with strategic weights**. The AI has clear preferences, but introduces variance.

---

## Randomization Techniques

### 1. **Weighted Probabilities** (Recommended)
Instead of "always spawn X", use "70% chance to spawn X, 30% Y".

**Example - Aggressive AI:**
```gdscript
func choose_enemy_unit_aggressive() -> BodyCardResource:
    var roll = randf()  # 0.0 to 1.0
    
    if roll < 0.60:  # 60% high-attack
        return [barbarian, thief].pick_random()
    elif roll < 0.90:  # 30% medium
        return knight
    else:  # 10% weak
        return squire
```

**Benefits:**
- Still feels strategic (biased toward high-attack)
- Adds variety (not always Barbarians)
- Learnable (you know the tendencies, just not exact outcome)
- Balanced (percentages are tunable)

**When to use:** All personality types can benefit from this

---

### 2. **Action Sets with Random Selection**
AI has 2-3 valid "good" moves, picks one randomly.

**Example - Mirror AI:**
```gdscript
func choose_spawn_lane_mirror(lanes: Array[Lane]) -> Lane:
    var valid_lanes: Array[Lane] = []
    
    # Find all lanes with player units (all are "good" choices)
    for lane in lanes:
        if lane.has_player_unit() and lane.get_enemy_in_column(2) == null:
            valid_lanes.append(lane)
    
    if valid_lanes.is_empty():
        # Fall back to random empty lane
        valid_lanes = _get_empty_lanes(lanes)
    
    # Pick one randomly from the valid set
    return valid_lanes.pick_random()
```

**Benefits:**
- Always makes a "smart" move (from valid set)
- Unpredictable which smart move it picks
- Feels intelligent but varied

**When to use:** Mirror, Punisher, Defensive (where multiple lanes are equally good)

---

### 3. **Per-Combat Seed** (Deterministic Replay)
Same encounter plays identically WITHIN one attempt, but differently on retry.

**Example Implementation:**
```gdscript
class_name EnemyAI

var combat_seed: int  # Set at combat start
var rng: RandomNumberGenerator

func initialize_combat():
    # Use timestamp or player actions as seed
    combat_seed = Time.get_ticks_msec()
    rng = RandomNumberGenerator.new()
    rng.seed = combat_seed
    
func choose_enemy_unit() -> BodyCardResource:
    # Use seeded RNG instead of global randf()
    var roll = rng.randf()
    if roll < 0.6:
        return barbarian
    else:
        return squire
```

**Benefits:**
- Same fight plays the same during one run (can plan)
- Different on retry (replayability)
- Common in roguelikes (Isaac, Spelunky)

**When to use:** If you want "learnable within a run" but variety across runs

---

### 4. **Personality Traits/Modifiers**
Each enemy AI instance gets random traits that modify behavior.

**Example - Trait System:**
```gdscript
enum AITrait {
    RECKLESS,   # +20% attack preference, -10% defense
    CAUTIOUS,   # +20% defense preference, spawns further back
    GREEDY,     # Prioritizes lanes with equipped player units
    PATIENT     # Waits 1 extra turn between spawns
}

var personality: Personality  # Base AI type
var traits: Array[AITrait]    # 1-2 random modifiers

func choose_enemy_unit() -> BodyCardResource:
    var base_weights = _get_base_weights_for_personality()
    
    # Apply trait modifiers
    if AITrait.RECKLESS in traits:
        base_weights["attack"] *= 1.2
        base_weights["defense"] *= 0.8
    
    # Select based on modified weights
    return _weighted_selection(base_weights)
```

**Benefits:**
- Same personality feels different each game
- Easy to communicate to player ("Reckless Aggressive AI")
- Stackable modifiers create complexity

**When to use:** If you want high variance but still deterministic within a game

---

### 5. **Stochastic Lane Selection**
Instead of "always pick empty lane", use probability based on lane quality.

**Example - Weighted Lane Selection:**
```gdscript
func choose_spawn_lane_weighted(lanes: Array[Lane]) -> Lane:
    var weights: Array[float] = []
    
    for lane in lanes:
        var weight = 1.0  # Base weight
        
        # Modify weight based on lane state
        if lane.get_enemy_in_column(2) != null:
            weight = 0.0  # Can't spawn here
        elif lane.has_player_unit():
            weight = 3.0  # 3x more likely (contest player)
        elif lane.is_empty():
            weight = 2.0  # 2x more likely (spread wide)
        # else: weight = 1.0 (default)
        
        weights.append(weight)
    
    # Weighted random selection
    return _pick_weighted_random(lanes, weights)
```

**Benefits:**
- Biased toward good moves, but not deterministic
- Can make "suboptimal but not terrible" choices
- Feels more natural/human

**When to use:** Any AI that has clear lane preferences but could benefit from variance

---

### 6. **Cooldowns and History Tracking**
Prevent repetitive patterns by tracking recent actions.

**Example - Unit Diversity:**
```gdscript
var last_spawned_units: Array[String] = []  # Track last 3 spawns
const REPEAT_PENALTY: float = 0.3  # Reduce chance of same unit

func choose_enemy_unit() -> BodyCardResource:
    var units = [squire, knight, barbarian, thief]
    var weights = [1.0, 1.0, 1.0, 1.0]  # Base equal weights
    
    # Penalize recently spawned units
    for i in units.size():
        if units[i].card_name in last_spawned_units:
            weights[i] *= REPEAT_PENALTY
    
    var chosen = _pick_weighted_random(units, weights)
    
    # Update history
    last_spawned_units.append(chosen.card_name)
    if last_spawned_units.size() > 3:
        last_spawned_units.pop_front()
    
    return chosen
```

**Benefits:**
- Creates natural variety
- Prevents "3 Barbarians in a row" spam
- Still allows repeats if unlucky

**When to use:** Chaotic AI, or any AI that might get repetitive

---

## Hybrid Approach: Recommended Implementation

Combine multiple techniques for best results:

```gdscript
class_name EnemyAI

var personality: Personality
var combat_seed: int
var rng: RandomNumberGenerator
var spawn_history: Array[String] = []

func initialize_combat():
    # 1. Per-combat seed for consistent replay
    combat_seed = Time.get_ticks_msec()
    rng = RandomNumberGenerator.new()
    rng.seed = combat_seed
    
    # 2. Random personality selection
    personality = [
        Personality.AGGRESSIVE,
        Personality.DEFENSIVE,
        Personality.MIRROR
    ].pick_random()

func choose_spawn_lane(lanes: Array[Lane]) -> Lane:
    # 3. Action set - find all valid lanes
    var valid_lanes = _get_valid_lanes_for_personality(lanes)
    
    # 4. Weighted selection from valid set
    var weights = _calculate_lane_weights(valid_lanes)
    return _pick_weighted_random(valid_lanes, weights)

func choose_enemy_unit() -> BodyCardResource:
    # 5. Weighted probabilities based on personality
    var base_weights = _get_unit_weights_for_personality()
    
    # 6. History penalty (reduce repeats)
    base_weights = _apply_history_penalty(base_weights)
    
    # 7. Seeded random selection
    return _pick_weighted_random_seeded(all_units, base_weights)
```

**This approach gives you:**
- ✅ Strategic depth (personality-driven weights)
- ✅ Replayability (random personality, seeded variance)
- ✅ Consistency within combat (seeded RNG)
- ✅ Natural variety (history tracking)
- ✅ Tunability (adjust weights for balance)

---

## Comparison: Deterministic vs. Randomized

| Aspect | Pure Deterministic | Controlled Random | Pure Random |
|--------|-------------------|-------------------|-------------|
| **Learnability** | ✅ Easy | ✅ Medium | ❌ Hard |
| **Replayability** | ❌ Low | ✅ High | ✅ High |
| **Strategic Depth** | ✅ High | ✅ High | ❌ Low |
| **Frustration** | ✅ Low | ✅ Low | ❌ High |
| **Feels "Smart"** | ⚠️ Robotic | ✅ Natural | ❌ Arbitrary |
| **Implementation** | ✅ Simple | ⚠️ Medium | ✅ Simple |
| **Examples** | StS, Inscryption | Hearthstone, Griftlands | None (bad idea) |

---

## Tuning Randomness Levels

Too much randomness? Adjust these dials:

### Low Randomness (More Like StS)
- Use 90/10 probability splits (heavily biased)
- Small action sets (2 valid moves max)
- Long history tracking (last 5 spawns)
- **Result:** Feels mostly deterministic with occasional variance

### Medium Randomness (Recommended)
- Use 60/30/10 probability splits
- Moderate action sets (3-4 valid moves)
- Short history tracking (last 3 spawns)
- **Result:** Clear tendencies but unpredictable outcomes

### High Randomness (More Like Hearthstone)
- Use 40/30/30 probability splits (more even)
- Large action sets (5+ valid moves)
- No history tracking
- **Result:** Feels chaotic but still strategic

---

## Testing Randomized AI

### Playtest Metrics
Track these across 20+ games:

1. **Variance**: Do the same encounters feel different each time?
2. **Skill Expression**: Can skilled players still win consistently?
3. **Frustration Moments**: Are there "BS losses" to bad RNG?
4. **Pattern Recognition**: Can players identify AI personality within 2-3 turns?

### Balance Iteration
1. Start with **medium randomness** (60/30/10 splits)
2. Play 10 games and track frustration moments
3. If too random: increase bias (70/20/10 or 80/15/5)
4. If too predictable: decrease bias (50/30/20)
5. Repeat until win rate is 40-60%

---

## Implementation Architecture (Updated for Randomization)

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

enum AITrait {
    NONE,
    RECKLESS,   # +20% attack preference
    CAUTIOUS,   # +20% defense preference
    GREEDY,     # Prioritizes equipped units
    PATIENT     # Slower spawn rate
}

var current_personality: Personality
var combat_seed: int
var rng: RandomNumberGenerator
var favorite_units: Array[BodyCardResource]  # For CHAOTIC
var game_turn: int  # For WAVE
var spawn_history: Array[String] = []  # Track last N spawns
var traits: Array[AITrait] = []  # Personality modifiers (optional)

func _init():
    # Initialize seeded RNG for this combat
    combat_seed = Time.get_ticks_msec()
    rng = RandomNumberGenerator.new()
    rng.seed = combat_seed
```

### Utility Functions (Randomization Helpers)

```gdscript
func _pick_weighted_random(options: Array, weights: Array[float]):
    """Select random element from options using weights"""
    var total_weight = 0.0
    for w in weights:
        total_weight += w
    
    var roll = rng.randf() * total_weight
    var cumulative = 0.0
    
    for i in options.size():
        cumulative += weights[i]
        if roll < cumulative:
            return options[i]
    
    return options[-1]  # Fallback

func _apply_history_penalty(weights: Dictionary) -> Dictionary:
    """Reduce weight of recently spawned units"""
    const PENALTY = 0.3
    var modified = weights.duplicate()
    
    for unit_name in spawn_history:
        if unit_name in modified:
            modified[unit_name] *= PENALTY
    
    return modified

func _update_spawn_history(unit_name: String):
    """Track spawned unit, keep only last 3"""
    spawn_history.append(unit_name)
    if spawn_history.size() > 3:
        spawn_history.pop_front()
```

### Core Functions

### Core Functions

#### `select_personality()`
- Called at game start
- Randomly chooses AI personality
- Initializes personality-specific data (e.g., CHAOTIC favorites)
- Can optionally assign random traits

```gdscript
func select_personality():
    # Random personality selection
    current_personality = [
        Personality.AGGRESSIVE,
        Personality.DEFENSIVE,
        Personality.MIRROR,
        Personality.PUNISHER
    ].pick_random()
    
    # Optional: Add random traits (10% chance)
    if rng.randf() < 0.10:
        traits.append([
            AITrait.RECKLESS,
            AITrait.CAUTIOUS,
            AITrait.GREEDY
        ].pick_random())
    
    # Initialize personality-specific data
    if current_personality == Personality.CHAOTIC:
        _select_favorite_units()
```

#### `choose_spawn_lane(lanes: Array[Lane]) -> Lane`
- Returns best lane based on personality (with randomization)
- Takes current board state as input
- Implements lane priority logic with weighted selection

```gdscript
func choose_spawn_lane(lanes: Array[Lane]) -> Lane:
    # Get valid lanes based on personality
    var valid_lanes = []
    var weights = []
    
    match current_personality:
        Personality.AGGRESSIVE:
            # Prefer empty lanes, but weighted random
            for lane in lanes:
                if lane.get_enemy_in_column(2) == null:
                    var weight = 1.0
                    if lane.is_empty():
                        weight = 3.0  # 3x more likely
                    valid_lanes.append(lane)
                    weights.append(weight)
        
        Personality.DEFENSIVE:
            # Prefer lanes with existing enemies
            for lane in lanes:
                if lane.get_enemy_in_column(2) == null:
                    var weight = 1.0
                    if lane.has_enemy_unit():
                        weight = 5.0  # 5x more likely
                    valid_lanes.append(lane)
                    weights.append(weight)
        
        Personality.MIRROR:
            # Prefer lanes with player units
            for lane in lanes:
                if lane.get_enemy_in_column(2) == null:
                    var weight = 1.0
                    if lane.has_player_unit():
                        weight = 4.0  # 4x more likely
                    valid_lanes.append(lane)
                    weights.append(weight)
    
    if valid_lanes.is_empty():
        return null
    
    # Weighted random selection
    return _pick_weighted_random(valid_lanes, weights)
```

#### `choose_enemy_unit(lane: Lane) -> BodyCardResource`
- Returns best enemy type for selected lane (with probabilities)
- Considers personality preferences
- May read game state (player HP, unit stats, etc.)
- Applies history penalty to avoid repetition

```gdscript
func choose_enemy_unit(lane: Lane) -> BodyCardResource:
    # Get base weights for personality
    var weights = {}
    
    match current_personality:
        Personality.AGGRESSIVE:
            weights = {
                "barbarian": 0.60,  # 60% high-attack
                "thief": 0.20,
                "knight": 0.15,     # 15% medium
                "squire": 0.05      # 5% weak
            }
        
        Personality.DEFENSIVE:
            weights = {
                "knight": 0.60,     # 60% high-HP
                "squire": 0.30,     # 30% medium
                "barbarian": 0.10   # 10% weak
            }
        
        Personality.MIRROR:
            # Dynamic weights based on player unit
            var player_unit = lane.get_player_unit()
            if player_unit:
                var total_stats = player_unit.hp + player_unit.attack
                if total_stats <= 2:
                    weights = {"squire": 1.0}
                elif total_stats <= 5:
                    weights = {"knight": 1.0}
                else:
                    weights = {"barbarian": 0.7, "thief": 0.3}
            else:
                weights = {"squire": 1.0}  # Default
        
        Personality.PUNISHER:
            # State-based weights
            var player_hp = get_player_hp()
            if player_hp > 15:
                weights = {"barbarian": 0.7, "thief": 0.3}  # Aggressive
            else:
                weights = {"knight": 0.6, "squire": 0.4}    # Defensive
    
    # Apply history penalty
    weights = _apply_history_penalty(weights)
    
    # Convert weights to arrays for selection
    var units = []
    var weight_values = []
    for unit_name in weights.keys():
        units.append(get_unit_resource(unit_name))
        weight_values.append(weights[unit_name])
    
    # Weighted random selection
    var chosen = _pick_weighted_random(units, weight_values)
    _update_spawn_history(chosen.card_name)
    
    return chosen
```

#### `spawn_enemies(lanes: Array[Lane])`
- Main entry point (called each turn)
- Calls `choose_spawn_lane()` and `choose_enemy_unit()`
- Respects spawn limits (2 per turn, 5 max on board)
- Now includes randomization logic

```gdscript
func spawn_enemies(lanes: Array[Lane]):
    var spawned_count = 0
    var max_spawns = 2
    
    while spawned_count < max_spawns:
        var lane = choose_spawn_lane(lanes)
        if lane == null:
            break  # No valid lanes
        
        var unit = choose_enemy_unit(lane)
        if unit:
            lane.summon_enemy_unit(unit, 2)
            spawned_count += 1
        else:
            break  # No units available
    
    game_turn += 1
```

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

## Choosing Your Approach

### Quick Decision Guide

**Choose DETERMINISTIC (like StS/Inscryption) if:**
- ✅ You want a puzzle-like, skill-based experience
- ✅ You value learnability over replayability
- ✅ You have limited development time (simpler to implement)
- ✅ Your game has other sources of variance (card draw, equipment drops)
- ✅ You want players to feel like they "mastered" the AI

**Choose RANDOMIZED (controlled probabilities) if:**
- ✅ You want high replayability
- ✅ You want each encounter to feel fresh
- ✅ You have other deterministic elements (fixed decks, scripted events)
- ✅ You want AI to feel "alive" rather than "programmed"
- ✅ You're okay with occasional "unlucky" moments

**Choose HYBRID (recommended for DEADHAND) if:**
- ✅ You want best of both worlds
- ✅ You can invest time in balancing probabilities
- ✅ You want strategic depth AND variety
- ✅ You want the AI to feel intelligent but not robotic

### Implementation Roadmap

**Phase 1: Start Deterministic (MVP)**
- Implement 2-3 personalities with fixed patterns
- Get the core game loop working
- Playtest for basic balance

**Phase 2: Add Controlled Randomization**
- Convert fixed choices to weighted probabilities (60/30/10 splits)
- Add action sets (pick from valid moves randomly)
- Implement history tracking to prevent repetition

**Phase 3: Polish with Advanced Features**
- Add per-combat seeds for consistent replay
- Implement personality traits/modifiers
- Add UI indicators showing AI tendencies

**Phase 4: Balance and Tune**
- Adjust probability weights based on win rates
- Fine-tune randomness levels (more/less variance)
- Add difficulty modes (easy = deterministic, hard = randomized)

---

## Summary

This AI system provides:
✅ **Depth**: 6 distinct personalities with unique counter-strategies  
✅ **Learnability**: Deterministic patterns players can master  
✅ **Variety**: Random selection keeps games fresh  
✅ **Scalability**: Easy to add new personalities or tune existing ones  
✅ **Engagement**: Players feel like they're outsmarting an intelligent opponent  
✅ **Randomization**: Controlled variance adds replayability without sacrificing strategy  

The **hybrid algorithmic + probabilistic approach** is perfect for a small-scale card battler:
- Sophisticated enough to feel smart
- Simple enough to implement and balance quickly
- Flexible enough to tune randomness levels based on playtesting
- Replayable enough to keep players engaged across multiple runs

**Recommended Starting Point:**
1. Implement **Aggressive** and **Defensive** personalities with **60/30/10 weighted probabilities**
2. Add **history tracking** to prevent repetitive spawns
3. Playtest and adjust weights until 40-60% win rate
4. Add more personalities once core system feels good
