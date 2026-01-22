# Monocromatico - AI Agent Instructions

## Project Overview
This is a **3D game** built with **Godot 4.5** using the **Forward Plus** rendering method. The project is in early development stages with a minimal structure.

## Technology Stack
- **Engine**: Godot 4.5
- **Game Type**: 3D
- **Rendering**: Forward Plus renderer (optimized for 3D scenes with many dynamic lights)
- **Scripting**: GDScript only (`.gd` files)

## Project Structure
```
monocromatico/
├── .godot/              # Engine cache (never edit manually)
├── project.godot        # Main project configuration
├── icon.svg             # Project icon
└── [features to be created]
```

**Organization Philosophy**: **Feature-based**, not type-based. Group related scenes, scripts, and assets together by gameplay feature or system.

Example structure:
```
player/
├── player.tscn          # Player scene
├── player.gd            # Player controller script
├── player_camera.gd     # Camera behavior
└── models/              # Player-specific 3D models

enemy/
├── enemy_base.tscn
├── enemy_base.gd
└── variants/
    ├── fast_enemy.tscn
    └── tank_enemy.tscn
```

## Godot Community Naming Conventions

### File Names
- **Scenes**: `snake_case.tscn` (e.g., `player_character.tscn`, `enemy_spawner.tscn`)
- **Scripts**: `snake_case.gd` (e.g., `health_system.gd`, `weapon_handler.gd`)
- **Resources**: `snake_case.tres`
- **Shaders**: `snake_case.gdshader`

### Code Naming
- **Classes**: `PascalCase` (e.g., `class_name PlayerController`)
- **Variables**: `snake_case` (e.g., `var movement_speed`, `var is_grounded`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `const MAX_HEALTH = 100`)
- **Functions**: `snake_case` (e.g., `func apply_damage()`, `func _on_area_entered()`)
- **Signals**: `snake_case` (e.g., `signal health_changed`, `signal enemy_died`)
- **Private/internal**: Prefix with `_` (e.g., `var _internal_state`, `func _calculate_path()`)

### GDScript Patterns for 3D
When writing GDScript for this project:
- Extend 3D node types: `Node3D`, `CharacterBody3D`, `RigidBody3D`, `Area3D`, etc.
- Use `class_name` declarations for reusable components
- Follow signal-based architecture for component communication
- Use `@onready` for node references (evaluated after children are ready)
- Export variables with `@export` for inspector editing
- Type hints are strongly encouraged for clarity

Example:
```gdscript
class_name PlayerController
extends CharacterBody3D

@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@onready var camera: Camera3D = $Camera3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
    pass

func _physics_process(delta: float) -> void:
    # Godot 4 physics uses velocity property directly
    if not is_on_floor():
        velocity += get_gravity() * delta
    
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed
    else:
        velocity.x = move_toward(velocity.x, 0, move_speed)
        velocity.z = move_toward(velocity.z, 0, move_speed)
    
    move_and_slide()
```

## Development Workflow

### Running the Project
- Open project in Godot Editor: Double-click `project.godot`
- Run from editor: Press F5 or click "Play" button
- Run specific scene: Press F6

### File Creation
- **Always create scenes through Godot Editor** for proper node configuration
- Scripts can be created externally but should follow GDScript conventions
- Scene files (`.tscn`) are text-based but complex - prefer editor creation

### Version Control
- `.godot/` directory is ignored (auto-generated cache)
- Commit `.import` files alongside assets (required for Godot asset pipeline)

## Key Configuration

### project.godot
Main configuration lives in [project.godot](../project.godot). When suggesting changes:
- Use semicolon-based INI format
- Add new sections with `[section_name]`
- Most settings are better configured via Godot Editor UI

## As This Project Grows
When implementing new features:
1. Create scene files (`.tscn`) for visual components in Godot Editor
2. Attach GDScript files for behavior/logic
3. Use signals for cross-node communication
4. Keep scene hierarchy shallow and modular for reusability

## 3D-Specific Guidelines

### Common 3D Node Types
- **CharacterBody3D**: Player characters, NPCs (has built-in collision)
- **RigidBody3D**: Physics-driven objects (crates, ragdolls)
- **StaticBody3D**: Non-moving collision surfaces (walls, floors)
- **Area3D**: Trigger zones, detection areas
- **MeshInstance3D**: Visual 3D models
- **Camera3D**: Player/cinematic cameras
- **DirectionalLight3D/OmniLight3D/SpotLight3D**: Lighting (Forward Plus handles many lights well)

### Coordinate System
- Godot uses **Y-up** coordinate system
- Forward: -Z, Right: +X, Up: +Y
- Rotations use radians by default

## Current Status
This is a **greenfield project** - no existing scenes or scripts yet. When creating initial structure:
- Organize by feature/system (player, enemies, levels, ui, etc.)
- Create a main scene and set it via Project Settings > Application > Run > Main Scene
- Keep feature directories self-contained with their scenes, scripts, and assets
