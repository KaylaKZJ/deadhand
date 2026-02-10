# Lemonade Stand Game - AI Coding Instructions

## Project Overview
A Godot 4.5 game combining daytime lemonade sales with nighttime zombie defense. Players manage recipes, serve customers, and defend their stand through a level-based progression system.

## Architecture & Core Patterns

### Centralized State Management
- **GameManager** (`scripts/game_manager.gd`) is the single source of truth for ALL game state
  - Access via `GameManager.get_instance(self)` from any node in the scene tree
  - Emits signals for state changes: `money_changed`, `phase_changed`, `stand_hp_changed`, etc.
  - Manages: money, inventory, reputation, weapons, levels, recipe configuration
  - Example: `game_manager.add_money(50)` updates state and notifies all listeners

### Phase-Based Gameplay
Four phases controlled by `PhaseController`:
1. **PREP_DAY** - Shop UI for buying ingredients/setting recipe
2. **DAYTIME** - Customer spawning and lemonade sales (60s)
3. **PREP_NIGHT** - Shop UI for buying weapons/upgrades
4. **NIGHTTIME** - Zombie combat (60s)

**Critical**: Phase visibility is managed by `PhaseController._on_phase_changed()`, which shows/hides entire scene trees. Never manually toggle scene visibility.

### Autoload Singletons
Configured in `project.godot` under `[autoload]`:
- **GameConfig** - Constants only (STARTING_MONEY, DAY_DURATION, etc.)
- **GameHelpers** - Static utilities (format_money, random_chance, lerp_color, play_one_shot_2d)
- **SFXConfig** - Sound effect preloads (SFX_COIN_PICKUP, SFX_WEAPON_FIRE, etc.)
- **GameStats** - Game statistics tracking
- **WeaponAbilityHandler** - Weapon special ability processing

### Resource-Driven Configuration
Data lives in `.tres` files in `resources/`:
- `CustomerTraits` - Customer appearance, price preferences, level availability
- `WeaponTrait` - Weapon stats, costs, unlock conditions
- `ZombieTrait` - HP, speed, damage, sprites
- `LevelConfig` - Win conditions, ideal recipes, visual layers per level

**Pattern**: Scripts reference traits, GameManager auto-loads all `.tres` files from `resources/` folders on startup

### Signal-Driven Communication
Preferred over direct method calls:
```gdscript
# GameManager emits
signal money_changed(new_amount: int)
signal phase_changed(new_phase: GamePhase)

# UIController/others connect
game_manager.money_changed.connect(_on_money_changed)
```

## GDScript Conventions

### Node References
```gdscript
# Prefer get_node_or_null for optional nodes
@onready var hp_label: Label = get_node_or_null("../UI/RHS2/HPContainer/HPLabel")

# GameManager access pattern (works from anywhere in scene tree)
@onready var game_manager: GameManager = GameManager.get_instance(self)
```

### Class Naming
- Use `class_name` for reusable types: `class_name GameManager`, `class_name WeaponTrait`
- Resources always extend `Resource` with `class_name`
- Scene scripts extend their node type: `extends CharacterBody2D`

### Documentation Style
Multi-line doc comments at top of files/classes:
```gdscript
## GameManager - Central State Controller
## Manages all persistent game state across day/night cycles
## Attached to the Game root node
```

## Key Systems

### Recipe Quality System
- GameManager calculates recipe quality vs. level's ideal recipe (from `LevelConfig`)
- Perfect recipes (95%+ match) increase reputation by 0.02
- Poor recipes decrease reputation by 0.03
- See `GameManager.calculate_recipe_quality()` and `generate_recipe_feedback()`

### Weapon/Ammo System
- Weapons stored in `GameManager.weapons` dictionary (auto-populated from `resources/weapons/`)
- Five weapon slots (slot 1 always "lemon")
- Ammo tracked per weapon in `GameManager.weapon_ammo`
- Player fires via `Player.shoot_weapon()` → spawns Weapon scene with WeaponTrait

### Level Progression
- Levels defined in `resources/levels/level_X.tres`
- Win conditions: reach target reputation AND cash
- Track stats: `GameManager.increment_level_stat("days_survived", 1)`
- Complete via `GameManager.check_level_completion()`

### Spawn Management
- **CustomerSpawn** (daytime): Spawns customers at random intervals, reputation affects frequency
- **ZombieSpawner** (nighttime): Caps max alive, reputation affects spawn rate difficulty
- Both use `@export var traits: Array[Resource]` configured in scene inspector

## Common Operations

### Adding Money
```gdscript
game_manager.add_money(amount)  # Emits money_changed signal
```

### Changing Phases
```gdscript
game_manager.set_phase(GameManager.GamePhase.NIGHTTIME)  # PhaseController handles visibility
```

### Spawning Entities
```gdscript
var customer_instance = CustomerScene.instantiate()
customer_instance.traits = selected_customer_trait
customer_instance.position = spawn_position
add_child(customer_instance)
customer_instance.reached_stand.connect(_on_customer_reached)
```

### Accessing Current Level Config
```gdscript
var level_config = game_manager.get_current_level_config()
if level_config:
    var ideal_lemons = level_config.ideal_recipe_lemons
```

## Development Workflow

### Running the Game
Open in Godot Editor 4.5, press F5. Main scene: `res://scenes/AAAGame.tscn`

### Debugging
- Enable flags in `GameConfig`: `DEBUG_MODE`, `DEBUG_ZOMBIE_TRACKING`, `DEBUG_PHASE_TRANSITIONS`
- Check console for `push_error()` and `print()` statements (scripts use `[ClassName]` prefixes)

### Adding New Levels
1. Duplicate `resources/levels/level_1.tres` → `level_X.tres`
2. Configure win conditions, ideal recipe, visual textures
3. Update customer/zombie `.tres` files' `levels` array to include new level number
4. GameManager auto-discovers on startup

### Adding New Weapons/Customers/Zombies
1. Create `.tres` file in appropriate `resources/` subfolder
2. Assign `id`, `display_name`, stats, sprite
3. Set `levels` array for availability
4. GameManager loads automatically - no code changes needed

## Common Pitfalls

- **Don't bypass GameManager**: Always use `game_manager.add_money()`, never `game_manager.money += 50`
- **Node path brittleness**: Use `get_node_or_null()` liberally, check for null before accessing
- **Signal connections**: Always connect in `_ready()` AFTER checking if nodes exist
- **Phase cleanup**: ZombieSpawner/CustomerSpawn must stop spawning on phase change (see `PhaseController._cleanup_*_entities()`)
- **Resource loading**: Never hardcode paths, use `preload()` for scenes: `var scene = preload("res://scenes/Customer.tscn")`

## Code Organization & Best Practices

### Single Responsibility Principle
Each script should have ONE clear purpose:
- **Good**: `customer_spawn.gd` only spawns customers, `customer.gd` only handles customer behavior
- **Bad**: Don't add weapon firing logic to `customer.gd` or UI updates to `zombie.gd`
- **When to split**: If a class does more than its name implies, create a new file
  - Example: `PhaseController` manages visibility, `PhaseTimer` manages timing—separate concerns

### Constants Go in GameConfig
All magic numbers and game-wide constants belong in `scripts/game_config.gd`:
```gdscript
# ✅ DO THIS - Add to GameConfig
const MAX_ZOMBIES_ALIVE: int = 10
const COIN_DROP_CHANCE: float = 0.3

# ❌ DON'T DO THIS - Hardcoded in scripts
var max_zombies = 10  # What if we need this elsewhere?
if randf() < 0.3:  # Magic number with no context
```
- Group related constants with comments: `# ============ ECONOMY ============`
- Use SCREAMING_SNAKE_CASE for constants
- Include units in name when helpful: `ZOMBIE_SPAWN_Y`, `DAY_DURATION`

### Utility Functions Go in GameHelpers
Reusable logic that doesn't fit a specific class belongs in `scripts/game_helpers.gd`:
```gdscript
# ✅ DO THIS - Add static helper
static func calculate_spawn_interval(reputation: float) -> float:
    return lerp(MAX_INTERVAL, MIN_INTERVAL, reputation)

# ❌ DON'T DO THIS - Duplicate in multiple files
# (Same calculation copy-pasted in customer_spawn.gd AND zombie_spawner.gd)
```
- All functions must be `static` (stateless utilities only)
- Group by category: Formatting, Math, Random, Color, Node Finding
- Include doc comments with usage examples

### When to Create New Files
Create a new script file when:
1. **New entity type**: New `.tres` resource type needs a companion script (`ZombieTrait` → `zombie_traits.gd`)
2. **New scene with behavior**: New `.tscn` needs logic (`Coin.tscn` → `coin.gd`)
3. **Separation of concerns**: Existing file exceeds 500 lines or does multiple things
4. **Reusable component**: Logic will be used by multiple scenes (make it a `class_name`)

**Naming conventions:**
- Scene scripts: `snake_case.gd` matching scene name (`Customer.tscn` → `customer.gd`)
- Resource scripts: `snake_case_traits.gd` or `snake_case_config.gd`
- Always include `class_name` for reusable types: `class_name Zombie`, `class_name WeaponTrait`

### Keep Scripts Focused
**File size guidelines:**
- Most scripts: 100-300 lines
- Complex managers (GameManager): up to 1000 lines acceptable if logically grouped
- If a file has 10+ methods unrelated to its core purpose → refactor

**Example refactoring:**
```gdscript
# ❌ BAD - zombie.gd doing UI work
func update_health_bar():
    health_bar.value = current_hp

# ✅ GOOD - zombie.gd emits signal, UI script handles display
signal health_changed(new_hp: int)
emit_signal("health_changed", current_hp)
```

### Code Organization Within Files
Follow this structure in all `.gd` files:
1. `extends` and `class_name` declarations
2. Multi-line doc comment (`##`)
3. Constants (if any local to this class)
4. `@export` variables (inspector-configurable)
5. Public variables
6. Private variables (prefix with `_` if desired)
7. `@onready` node references
8. Signals
9. Lifecycle methods (`_init`, `_ready`, `_process`, `_physics_process`)
10. Public methods (grouped logically with comment headers)
11. Private methods (prefix with `_`)
12. Signal handler methods (`_on_*`)

See `scripts/game_manager.gd` for a well-organized example with clear section headers.

## File Organization
- `readmes/` - All architecture and implementation docs (.md)
- `scripts/` - All GDScript files (.gd)
- `scenes/` - All .tscn scene files
- `resources/` - All .tres resource files (organized by type)
- `PixelArt/` - Art assets (.png, .aseprite)
- `fonts/` - Font files (.ttf)
- `Themes/` - UI theme resources

