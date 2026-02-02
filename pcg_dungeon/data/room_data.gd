class_name RoomData
extends Resource

@export_group("Identity")
@export var preset_id: String = ""
@export var description: String = ""
@export var type: Types.TargetType = Types.TargetType.CORRIDOR

@export_group("Scene")
@export var scene: PackedScene

@export_group("Exits")
@export var exits: Array[ExitData] = [] # Mapping of exit names to ExitData resources
