class_name RoomData
extends Resource

@export_group("Identity")
@export var preset_id: String = ""
@export var description: String = ""

@export_group("Scene")
@export var scene: PackedScene

@export_group("Sockets")
## @value {"North": ExitData, "South": ExitData, ...}
@export var exits: Dictionary = {}  # Mapping of exit names to ExitData resources
