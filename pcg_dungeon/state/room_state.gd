class_name RoomState
extends Resource

@export_group("Identity")
@export var uuid: String = ""
@export var depth: int = 0
@export var preset_id: String = "" 

@export_group("Placement")
## The absolute center of the room in the world
@export var global_position: Vector3 = Vector3.ZERO
## The Y-axis rotation in radians
@export var global_rotation: float = 0.0

@export_group("Connectivity")
## Stores exit data: { "SocketName": { "corridor_uuid": String, "type": String } }
@export var exits: Dictionary = {} 

@export_group("Gameplay State")
@export var is_visited: bool = false
@export var is_cleared: bool = false