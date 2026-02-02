class_name ExitState
extends Resource

@export var uuid: String = ""
@export var exit_name: String = "North"
@export var local_transform: Transform3D = Transform3D.IDENTITY
@export var target_type: Types.TargetType = Types.TargetType.CORRIDOR
@export var is_open: bool = true
@export var connected_room_uuid: String = ""