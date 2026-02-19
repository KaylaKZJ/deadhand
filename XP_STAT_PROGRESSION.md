# XP & Stat Progression System

## Overview
Players gain XP by killing enemies, level up to earn stat points, and allocate those points to permanently boost all units in their deck. This provides meaningful progression to counterbalance the infinite enemy wave scaling.

## Core Mechanics

### XP Gain
- **Trigger:** Every enemy unit death
- **Amount:** 10 XP per kill (flat rate for MVP)
- **Future enhancement:** Enemy cards will have `xp_reward` field for varied XP values
- **Tracking:** Real-time in `CombatManager.player_xp`

### Level-Up System
**Thresholds:**
- Level 1→2: 100 XP total (10 kills)
- Level 2→3: 200 XP total (20 more kills, 30 cumulative)
- Level 3→4: 300 XP total (30 more kills, 60 cumulative)
- **Formula:** Level N requires `100 * N` XP beyond previous level

**Level-Up Trigger (Can occur mid-combat):**
1. Check XP threshold after every enemy kill
2. When threshold crossed:
   - Pause combat state (no phase transitions during level-up)
   - Increment `player_level`
   - Grant 3 `unspent_stat_points`
   - **Full heal:** `player_hp = max_player_hp`
   - Show floating notification: "⭐ LEVEL UP! HP Restored! +3 Stat Points"
   - Make stat allocation button glow/pulse
   - Resume combat (player can allocate immediately or defer)

### Stat Points Allocation
**Earned per level:** 3 points to distribute freely

**Three stats available:**
- **ATK (Attack):** Flat damage bonus to all player units
- **DEF (Defense):** Damage mitigation for all player units
- **VIT (Vitality):** Increases max player HP pool

**Allocation rules:**
- Can spend points at any time (not forced during level-up)
- `unspent_stat_points` persist between waves/combats
- No refunds or respec (spend carefully)
- Allocation is permanent for the entire run

---

## Stat Formulas & Effects

### ATK (Attack Power)
**Effect:** Adds flat damage to every player unit's attack

**Formula:**
```
unit.final_damage = unit.base_attack + equipped_weapon_bonus + player_atk
```

**Example:**
- Skeleton base: 2 ATK
- Rusty Axe: +2 ATK
- Player ATK stat: 5
- **Final damage:** 2 + 2 + 5 = **9 damage**

**Scaling:**
- Linear scaling (each point = +1 damage to all units)
- No diminishing returns
- Multiplicative with weapon bonuses

---

### DEF (Defense)
**Effect:** Reduces incoming damage to all player units via soft-cap mitigation formula

**Formula:**
```
damage_reduction_percent = player_def / (player_def + 20)
unit.damage_taken = incoming_damage * (1 - damage_reduction_percent)
```

**Examples:**
| Player DEF | Reduction % | 10 Damage → Taken |
|------------|-------------|-------------------|
| 0          | 0%          | 10 damage         |
| 5          | 20%         | 8 damage          |
| 10         | 33%         | 6.7 damage        |
| 20         | 50%         | 5 damage          |
| 40         | 67%         | 3.3 damage        |
| 80         | 80%         | 2 damage          |

**Scaling:**
- Diminishing returns built-in (asymptotic approach to 100%)
- First 20 points very impactful (0→50% reduction)
- After 40 DEF, gains become marginal
- Recommended soft cap: 50 DEF (71% reduction)

---

### VIT (Vitality)
**Effect:** Increases maximum player HP (overflow damage pool)

**Formula:**
```
max_player_hp = base_max_hp + (player_vit * 2)
```

**On VIT increase:**
- Recalculate `max_player_hp` immediately
- Also restore HP: `player_hp += vit_increase * 2` (capped at new max)
- Example: VIT 0→5 grants +10 max HP AND heals +10 HP

**Base values:**
- Starting max HP: 20
- VIT to HP ratio: 1:2 (1 VIT = 2 max HP)

**Example progression:**
| Player VIT | Max HP | Total Increase |
|------------|--------|----------------|
| 0          | 20     | Base           |
| 5          | 30     | +10 HP         |
| 10         | 40     | +20 HP         |
| 20         | 60     | +40 HP         |

**Scaling:**
- Linear scaling (no diminishing returns)
- Synergizes with DEF (more HP + damage reduction = survivability)
- Recommended cap: 30 VIT (80 max HP)

---

## UI/UX Flow

### Level-Up Notification
**Trigger:** XP threshold crossed (can happen during any phase)

**Visual:**
- Large centered banner/panel: "⭐ LEVEL UP! ⭐"
- Text: "Level X → Level Y"
- Text: "HP Fully Restored!"
- Text: "+3 Stat Points Available"
- Auto-dismisses after 2 seconds OR player presses any key
- Stat button begins glowing/pulsing

**Audio:** Play level-up sound effect (fanfare/ding)

---

### Stat Allocation Button (Persistent UI Element)
**Location:** Top-right corner of main UI (near turn/phase labels)

**Visual States:**
1. **Inactive (no points):**
   - Gray icon/text: "Stats"
   - Non-interactive or shows "0 points" tooltip
   
2. **Active (points available):**
   - Glowing yellow/gold pulsing animation
   - Badge showing number: "Stats (3)"
   - Attention-grabbing (particle effect optional)

3. **Hover:**
   - Tooltip: "Allocate X stat points (ATK/DEF/VIT)"

**Click behavior:**
- Opens stat allocation modal panel
- Pauses combat (or allows allocation during PLAY phase)

---

### Stat Allocation Panel (Modal)
**Layout:**
```
╔═══════════════════════════════════╗
║     STAT ALLOCATION               ║
║                                   ║
║  Level: X    Unspent Points: Y    ║
║                                   ║
║  ATK (Attack):     5   [-] [+]    ║
║    Effect: +5 damage to all units ║
║                                   ║
║  DEF (Defense):    3   [-] [+]    ║
║    Effect: 13% damage reduction   ║
║                                   ║
║  VIT (Vitality):   2   [-] [+]    ║
║    Effect: Max HP = 24            ║
║                                   ║
║         [Apply]     [Cancel]      ║
╚═══════════════════════════════════╝
```

**Interaction:**
- **[+] button:** Increment staged allocation (if unspent points > 0)
- **[-] button:** Decrement staged allocation (if staged > 0)
- **Real-time preview:** Show "Effect" text updating with staged values
- **Apply button:** Commits changes, updates `CombatManager` stats, closes panel
- **Cancel button:** Discards staged changes, closes panel (points remain unspent)
- **ESC key:** Same as Cancel

**Validation:**
- Cannot allocate more points than available
- Cannot go negative ([-] button disabled at 0)
- Apply button disabled if no changes staged

---

## Card & Unit Display

### Stat Display Philosophy
**All cards and units display modified stats (base + player bonuses) at all times**

**Rationale:**
- Players see the actual combat values they'll get
- No mental math required
- Consistent with "what you see is what you get" UX
- Leveling up feels more rewarding (cards visibly get stronger)

**Implementation:**
- **Cards in hand:** Display `base_stat + player_bonus`
  - Example: Skeleton (2 base ATK) with +5 player ATK shows "7 ATK"
  - Updates automatically when player allocates stat points
- **Units on board:** Display current modified stats
  - Same calculation, updates in real-time
- **Enemy cards/units:** Display base stats only (no player bonuses)

**Display Update Triggers:**
- When `CombatManager.stat_allocated` signal fires
- When cards are drawn/created (calculate on instantiation)
- When units are spawned (calculate during initialize)

---

## Integration Points

### CombatManager (scripts/managers/combat_manager.gd)
**New variables:**
```gdscript
# Player progression
var player_xp: int = 0
var player_level: int = 1
var player_atk: int = 0
var player_def: int = 0
var player_vit: int = 0
var unspent_stat_points: int = 0

# Tracking
var enemies_killed_this_wave: int = 0  # For future stats/achievements
```

**New signals:**
```gdscript
signal level_up(new_level: int, stat_points_gained: int)
signal xp_gained(amount: int, current_xp: int, xp_for_next_level: int)
signal stat_allocated(stat_name: String, new_value: int)
```

**New methods:**
```gdscript
func award_xp(amount: int) -> void
func _check_level_up() -> void
func _xp_for_next_level() -> int
func allocate_stat(stat_name: String, amount: int) -> bool
func get_player_stats() -> Dictionary  # Returns {atk, def, vit, level, xp}
```

**Hook points:**
- Connect to `Unit.died` signal during unit spawning
- Award XP when `unit.is_player_unit == false` (enemy death)
- Check level-up after every XP award

---

### Unit (scripts/board/unit.gd)
**Modifications needed:**

1. **Damage calculation (attacking):**
```gdscript
func get_total_attack() -> int:
    var bonus = 0
    if is_player_unit and combat_manager:
        bonus = combat_manager.player_atk
    return current_attack + bonus
```

2. **Damage calculation (taking damage):**
```gdscript
func take_damage(amount: int) -> void:
    var mitigated_damage = amount
    
    if is_player_unit and combat_manager:
        var def_value = combat_manager.player_def
        var reduction = def_value / float(def_value + 20.0)
        mitigated_damage = int(amount * (1.0 - reduction))
        
        if mitigated_damage < amount:
            print("%s: Reduced %d → %d (%.0f%% mitigation)" % [
                card_data.card_name, 
                amount, 
                mitigated_damage, 
                reduction * 100
            ])
    
    current_hp -= mitigated_damage
    # ... rest of damage logic
```

3. **Combat manager reference:**
```gdscript
var combat_manager: CombatManager = null  # Set during initialize()

func initialize(data, is_player, lane, column, level, combat_mgr):
    # ... existing code ...
    combat_manager = combat_mgr
```

---

### CardDisplay (scripts/card_logic/card_display.gd)
**Modifications needed:**

1. **Add combat manager reference:**
```gdscript
var combat_manager: CombatManager = null

func _ready():
    # Get combat manager from scene tree
    combat_manager = get_tree().get_first_node_in_group("combat_manager")
    if combat_manager:
        combat_manager.stat_allocated.connect(_on_stat_changed)
```

2. **Update display to show modified stats:**
```gdscript
func set_card_data(card: CardBase):
    card_data = card
    _update_display()

func _update_display():
    if not card_data:
        return
    
    # ... existing name/description code ...
    
    # Calculate modified stats for player body cards
    if card_data is BodyCardResource:
        var displayed_atk = card_data.attack
        if combat_manager and not card_data.is_enemy_card:
            displayed_atk += combat_manager.player_atk
        
        attack_label.text = "ATK: %d" % displayed_atk
        hp_label.text = "HP: %d" % card_data.hp
    elif card_data is EquipmentCardResource:
        # Equipment shows base bonuses only
        # (final unit stats will show after equipping)
        pass

func _on_stat_changed(stat_name: String, new_value: int):
    # Refresh display when stats change
    _update_display()
```

---

### Lane (scripts/board/lane.gd)
**Modifications:**
- Pass `combat_manager` reference to units during spawn:
- Ensure CombatManager is accessible from lane (stored as variable or fetched from scene tree)

```gdscript
func summon_player_unit(card_data):
    # ...
    unit.initialize(card_data, true, lane_index, 0, 1, combat_manager)

func summon_enemy_unit(card_data):
    # ...
    unit.initialize(card_data, false, lane_index, column, level, combat_manager)
```

---

### Main (scripts/main.gd)
**New UI elements:**
- Add stat allocation button to UI container
- Connect button pressed signal to open stat panel
- Add level/XP display labels (optional for MVP)

**New scene references:**
```gdscript
@onready var stat_button: Button = $UI/StatButton
@onready var level_label: Label = $UI/LevelLabel  # Optional
```

**Signal connections:**
```gdscript
combat_manager.level_up.connect(_on_level_up)
combat_manager.xp_gained.connect(_on_xp_gained)
stat_button.pressed.connect(_on_stat_button_pressed)
```

---

## Additional Implementation Notes

### CombatManager Group Setup
**Important:** Add the CombatManager node to the "combat_manager" group in the scene:
1. Select the CombatManager node in the scene tree
2. Go to the Node tab → Groups
3. Add to group: "combat_manager"

This allows CardDisplay and other systems to find it via `get_tree().get_first_node_in_group("combat_manager")`.

### Unit Signal Requirements
The Unit class must emit a `died` signal for XP tracking:
```gdscript
signal died(was_player_unit: bool)

func take_damage(amount: int):
    # ... existing damage logic ...
    if current_hp <= 0:
        died.emit(is_player_unit)
        queue_free()
```

---

## Balance Tuning Knobs

### XP Curve
**Current settings:**
- XP per kill: 10
- XP per level: `100 * level`

**Tuning considerations:**
- If leveling too slow: reduce per-level requirement OR increase XP per kill
- If leveling too fast: increase per-level multiplier (e.g., `150 * level`)
- Wave difficulty vs. level curve: aim for 1 level every 2-3 waves early game

**Future enhancements:**
- Different XP values per enemy type (weak = 5, strong = 20)
- Bonus XP for perfect waves (no player units lost)
- Diminishing XP at high levels (exponential curve)

---

### Stat Effectiveness
**ATK tuning:**
- Current: +1 damage per point
- If too weak: change to +2 damage OR make it multiplicative (e.g., +5% per point)
- If too strong: add soft cap or diminishing returns

**DEF tuning:**
- Current: `reduction = DEF / (DEF + 20)`
- Divisor controls curve steepness (lower = faster gains, higher = slower)
- Alternative formulas:
  - `DEF / (DEF + 30)` — slower gains (50% at 30 DEF)
  - `DEF / (DEF + 15)` — faster gains (50% at 15 DEF)

**VIT tuning:**
- Current: +2 max HP per point
- If HP pool too small: increase to +3 or +5 per point
- If HP pool too large: decrease to +1 per point

---

### Enemy Scaling (Existing)
**Current:** `difficulty_multiplier += 0.15` per wave (+15% HP/ATK)

**Balance target:**
- Player should gain ~1 level per 2 waves early game
- Each level (3 points) should offset ~1.5 waves of enemy scaling
- By wave 10: enemies ~2.5x stronger, player should be level 5-6 (~15-18 stat points)

**Recommended adjustments:**
- Reduce enemy scaling to +10% per wave (0.10 multiplier)
- Or increase XP per kill to 15-20 to match current scaling

---

## Implementation Phases

### Phase 1: Backend (Core Systems)
- [x] Design documentation
- [ ] Add XP/level/stat variables to `CombatManager`
- [ ] Implement `award_xp()` and `_check_level_up()` methods
- [ ] Connect XP award to `Unit.died` signal
- [ ] Add full heal on level-up
- [ ] Implement `allocate_stat()` method with validation

### Phase 2: Combat Integration
- [ ] Pass `combat_manager` reference to all units
- [ ] Modify `Unit.get_total_attack()` to include player ATK bonus
- [ ] Modify `Unit.take_damage()` to apply player DEF mitigation
- [ ] Update VIT to recalculate `max_player_hp` on allocation
- [ ] Test damage calculations with debug prints

### Phase 3: UI Implementation
- [ ] Create stat allocation panel scene (`scenes/ui/stat_panel.tscn`)
- [ ] Script stat panel with +/- buttons and preview
- [ ] Add stat button to main UI with glowing state
- [ ] Create level-up notification banner/popup
- [ ] Connect signals and test UI flow

### Phase 4: Balance & Polish
- [ ] Add debug mode for rapid XP gain (testing)
- [ ] Playtest levels 1-5, tune XP curve
- [ ] Playtest waves 1-10, tune stat effectiveness vs. enemy scaling
- [ ] Add visual feedback (damage numbers, mitigation indicators)
- [ ] Add sound effects (level-up, stat allocation, XP gain)

---

## Future Enhancements

### XP System
- Enemy cards have custom `xp_reward` field (rare enemies = more XP)
- XP bonus for overkill damage
- XP bonus for combo kills (multiple enemies in one turn)
- Prestige system (reset levels for permanent bonuses)

### Stat System
- More stats: SPEED (attack first), CRIT (chance for 2x damage), ARMOR_PIERCE
- Diminishing returns: exponential cost (e.g., ATK 0-10 costs 1 pt/level, 10-20 costs 2 pts/level)
- Stat presets: "Offensive", "Defensive", "Balanced" quick-allocate buttons
- Respec option: costs gold or special currency to reset stats

### UI/UX
- Stat comparison tooltips (hover to see "before/after" damage)
- Stat history graph (track allocation over time)
- Recommended builds (based on playstyle or cards in deck)
- Animated stat increases (number ticks up with particles)

---

## Testing Checklist

### Core Functionality
- [ ] Enemy death awards XP correctly
- [ ] XP accumulates and level-up triggers at threshold
- [ ] Full heal occurs on level-up
- [ ] Stat points increment correctly (+3 per level)
- [ ] Stat allocation changes `player_atk/def/vit` values
- [ ] ATK bonus applies to all player units in combat
- [ ] DEF mitigation reduces damage correctly (verify math)
- [ ] VIT increases max HP and restores HP on allocation
- [ ] Unspent points persist across waves

### Edge Cases
- [ ] Level up during COMBAT phase (mid-combat)
- [ ] Level up during ADVANCE phase (between combats)
- [ ] Multiple levels gained in one wave (rapid XP)
- [ ] Allocate 0 points (cancel without spending)
- [ ] Try to allocate more points than available (validation)
- [ ] VIT allocation when player HP is full (no overheal)
- [ ] VIT allocation when player HP is low (grants HP bonus)

### Balance Validation
- [ ] Level 1→2 takes ~2 waves (20 kills)
- [ ] By wave 5, player is level 3-4
- [ ] ATK bonus noticeably increases damage output
- [ ] DEF bonus noticeably improves unit survivability
- [ ] VIT bonus allows surviving extra overflow hits
- [ ] Enemy scaling doesn't outpace player progression

---

## Technical Notes

### Performance Considerations
- XP checks after every unit death (frequent calls)
  - Keep `_check_level_up()` lightweight (simple threshold comparison)
  - Avoid expensive operations in XP award path
- DEF formula uses float division (acceptable overhead per hit)
  - Cache reduction percentage if performance issues arise

### Save/Load Requirements (Future)
Persistent data to save:
```json
{
  "player_xp": 350,
  "player_level": 4,
  "player_atk": 7,
  "player_def": 5,
  "player_vit": 3,
  "unspent_stat_points": 1
}
```

**Note:** Wave tracking and other game state should be saved separately by the main game manager.

### Debugging Tools
Add to `CombatManager` for testing:
```gdscript
func _input(event):
    if OS.is_debug_build():
        if event.is_action_pressed("debug_add_xp"):
            award_xp(100)  # Instant level-up
        if event.is_action_pressed("debug_reset_stats"):
            player_atk = 0
            player_def = 0
            player_vit = 0
            unspent_stat_points = 0
```

---

## Summary

This XP & Stat Progression system provides:
- **Dynamic progression:** Level-ups happen organically through combat
- **Player agency:** Choose how to build character (ATK vs DEF vs VIT)
- **Balance solution:** Counters infinite enemy scaling with permanent growth
- **Immediate feedback:** Full heal on level-up feels rewarding
- **Flexible timing:** Allocate stats mid-combat or between waves

The system is designed to be simple (3 stats, clear formulas), tunable (many balance knobs), and extensible (easy to add more stats or XP sources later).

**Implementation Priority:** This system should be implemented after the core combat loop is stable, as it builds upon existing unit damage/HP mechanics and requires UI extensions. Test thoroughly with various stat allocations to ensure formulas are balanced against enemy scaling.
```gdscript
func update_display():
    # ... existing HP display code ...
    
    # Update ATK label with player bonus
    if attack_label:
        var total_atk = get_total_attack()
        attack_label.text = "ATK: %d" % total_atk
```

---

### Main (scripts/main.gd)
**New UI elements:**
- Add stat allocation button to UI container
- Connect button pressed signal to open stat panel
- Add level/XP display labels (optional for MVP)

**New scene references:**
```gdscript
@onready var stat_button: Button = $UI/StatButton
@onready var level_label: Label = $UI/LevelLabel  # Optional
```

**Signal connections:**
```gdscript
combat_manager.level_up.connect(_on_level_up)
combat_manager.xp_gained.connect(_on_xp_gained)
stat_button.pressed.connect(_on_stat_button_pressed)
```

---

## Balance Tuning Knobs

### XP Curve
**Current settings:**
- XP per kill: 10
- XP per level: `100 * level`

**Tuning considerations:**
- If leveling too slow: reduce per-level requirement OR increase XP per kill
- If leveling too fast: increase per-level multiplier (e.g., `150 * level`)
- Wave difficulty vs. level curve: aim for 1 level every 2-3 waves early game

**Future enhancements:**
- Different XP values per enemy type (weak = 5, strong = 20)
- Bonus XP for perfect waves (no player units lost)
- Diminishing XP at high levels (exponential curve)

---

### Stat Effectiveness
**ATK tuning:**
- Current: +1 damage per point
- If too weak: change to +2 damage OR make it multiplicative (e.g., +5% per point)
- If too strong: add soft cap or diminishing returns

**DEF tuning:**
- Current: `reduction = DEF / (DEF + 20)`
- Divisor controls curve steepness (lower = faster gains, higher = slower)
- Alternative formulas:
  - `DEF / (DEF + 30)` — slower gains (50% at 30 DEF)
  - `DEF / (DEF + 15)` — faster gains (50% at 15 DEF)

**VIT tuning:**
- Current: +2 max HP per point
- If HP pool too small: increase to +3 or +5 per point
- If HP pool too large: decrease to +1 per point

---

### Enemy Scaling (Existing)
**Current:** `difficulty_multiplier += 0.15` per wave (+15% HP/ATK)

**Balance target:**
- Player should gain ~1 level per 2 waves early game
- Each level (3 points) should offset ~1.5 waves of enemy scaling
- By wave 10: enemies ~2.5x stronger, player should be level 5-6 (~15-18 stat points)

**Recommended adjustments:**
- Reduce enemy scaling to +10% per wave (0.10 multiplier)
- Or increase XP per kill to 15-20 to match current scaling

---

## Implementation Phases

### Phase 1: Backend (Core Systems)
- [x] Design documentation
- [ ] Add XP/level/stat variables to `CombatManager`
- [ ] Implement `award_xp()` and `_check_level_up()` methods
- [ ] Connect XP award to `Unit.died` signal
- [ ] Add full heal on level-up
- [ ] Implement `allocate_stat()` method with validation

### Phase 2: Combat Integration
- [ ] Pass `combat_manager` reference to all units
- [ ] Modify `Unit.get_total_attack()` to include player ATK bonus
- [ ] Modify `Unit.take_damage()` to apply player DEF mitigation
- [ ] Update VIT to recalculate `max_player_hp` on allocation
- [ ] Test damage calculations with debug prints

### Phase 3: UI Implementation
- [ ] Create stat allocation panel scene (`scenes/ui/stat_panel.tscn`)
- [ ] Script stat panel with +/- buttons and preview
- [ ] Add stat button to main UI with glowing state
- [ ] Create level-up notification banner/popup
- [ ] Connect signals and test UI flow

### Phase 4: Balance & Polish
- [ ] Add debug mode for rapid XP gain (testing)
- [ ] Playtest levels 1-5, tune XP curve
- [ ] Playtest waves 1-10, tune stat effectiveness vs. enemy scaling
- [ ] Add visual feedback (damage numbers, mitigation indicators)
- [ ] Add sound effects (level-up, stat allocation, XP gain)

---

## Future Enhancements

### XP System
- Enemy cards have custom `xp_reward` field (rare enemies = more XP)
- XP bonus for overkill damage
- XP bonus for combo kills (multiple enemies in one turn)
- Prestige system (reset levels for permanent bonuses)

### Stat System
- More stats: SPEED (attack first), CRIT (chance for 2x damage), ARMOR_PIERCE
- Diminishing returns: exponential cost (e.g., ATK 0-10 costs 1 pt/level, 10-20 costs 2 pts/level)
- Stat presets: "Offensive", "Defensive", "Balanced" quick-allocate buttons
- Respec option: costs gold or special currency to reset stats

### UI/UX
- Stat comparison tooltips (hover to see "before/after" damage)
- Stat history graph (track allocation over time)
- Recommended builds (based on playstyle or cards in deck)
- Animated stat increases (number ticks up with particles)

---

## Testing Checklist

### Core Functionality
- [ ] Enemy death awards XP correctly
- [ ] XP accumulates and level-up triggers at threshold
- [ ] Full heal occurs on level-up
- [ ] Stat points increment correctly (+3 per level)
- [ ] Stat allocation changes `player_atk/def/vit` values
- [ ] ATK bonus applies to all player units in combat
- [ ] DEF mitigation reduces damage correctly (verify math)
- [ ] VIT increases max HP and restores HP on allocation
- [ ] Unspent points persist across waves

### Edge Cases
- [ ] Level up during COMBAT phase (mid-combat)
- [ ] Level up during ADVANCE phase (between combats)
- [ ] Multiple levels gained in one wave (rapid XP)
- [ ] Allocate 0 points (cancel without spending)
- [ ] Try to allocate more points than available (validation)
- [ ] VIT allocation when player HP is full (no overheal)
- [ ] VIT allocation when player HP is low (grants HP bonus)

### Balance Validation
- [ ] Level 1→2 takes ~2 waves (20 kills)
- [ ] By wave 5, player is level 3-4
- [ ] ATK bonus noticeably increases damage output
- [ ] DEF bonus noticeably improves unit survivability
- [ ] VIT bonus allows surviving extra overflow hits
- [ ] Enemy scaling doesn't outpace player progression

---

## Technical Notes

### Performance Considerations
- XP checks after every unit death (frequent calls)
  - Keep `_check_level_up()` lightweight (simple threshold comparison)
  - Avoid expensive operations in XP award path
- DEF formula uses float division (acceptable overhead per hit)
  - Cache reduction percentage if performance issues arise

### Save/Load Requirements (Future)
Persistent data to save:
```json
{
  "player_xp": 350,
  "player_level": 4,
  "player_atk": 7,
  "player_def": 5,
  "player_vit": 3,
  "unspent_stat_points": 1,
  "wave_number": 6
}
```

### Debugging Tools
Add to `CombatManager` for testing:
```gdscript
func _input(event):
    if OS.is_debug_build():
        if event.is_action_pressed("debug_add_xp"):
            award_xp(100)  # Instant level-up
        if event.is_action_pressed("debug_reset_stats"):
            player_atk = 0
            player_def = 0
            player_vit = 0
            unspent_stat_points = 0
```

---

## Summary

This XP & Stat Progression system provides:
- **Dynamic progression:** Level-ups happen organically through combat
- **Player agency:** Choose how to build character (ATK vs DEF vs VIT)
- **Balance solution:** Counters infinite enemy scaling with permanent growth
- **Immediate feedback:** Full heal on level-up feels rewarding
- **Flexible timing:** Allocate stats mid-combat or between waves

The system is designed to be simple (3 stats, clear formulas), tunable (many balance knobs), and extensible (easy to add more stats or XP sources later).
