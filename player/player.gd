class_name Player extends CharacterBody3D

# --- Configuration ---
@export_category("Movement")
@export var speed_walk: float = 5.0
@export var speed_run: float = 8.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 10.0   # How fast we reach max speed (Smoothing)
@export var deceleration: float = 12.0   # How fast we stop

@export_category("Camera")
@export var mouse_sensitivity: float = 0.003
@export var min_pitch: float = -89.0     # Look down limit
@export var max_pitch: float = 89.0      # Look up limit

# --- Components ---
# We get these nodes once to avoid using get_node() every frame
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

# --- State ---
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
    pass

func _unhandled_input(event: InputEvent) -> void:
    # Camera Rotation logic
    if event is InputEventMouseMotion:
        # Rotate Body Left/Right (Y-Axis)
        rotate_y(-event.relative.x * mouse_sensitivity)
        
        # Rotate Head Up/Down (X-Axis)
        # We rotate the HEAD, not the body, to avoid tipping over
        head.rotate_x(-event.relative.y * mouse_sensitivity)
        
        # Clamp the look angle so you can't somersault your head
        head.rotation.x = clamp(head.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _physics_process(delta: float) -> void:
    # 1. Apply Gravity
    if not is_on_floor():
        velocity.y -= gravity * delta

    # 2. Handle Jump
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    # 3. Get Input Direction
    # We use get_vector to automatically handle deadzones and diagonal normalization
    var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    
    # 4. Calculate Move Direction relative to where the Player is facing
    # transform.basis handles the local-to-global conversion
    var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    # 5. Handle Velocity (with Smoothing)
    var target_speed = speed_run if Input.is_action_pressed("sprint") else speed_walk
    
    if direction:
        # Accelerate towards target speed
        velocity.x = move_toward(velocity.x, direction.x * target_speed, acceleration * delta)
        velocity.z = move_toward(velocity.z, direction.z * target_speed, acceleration * delta)
    else:
        # Decelerate to zero
        velocity.x = move_toward(velocity.x, 0, deceleration * delta)
        velocity.z = move_toward(velocity.z, 0, deceleration * delta)

    # 6. Apply Movement
    move_and_slide()