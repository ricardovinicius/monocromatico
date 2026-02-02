class_name DungeonData
extends Resource

@export_group("Identity")
@export var description: String = ""

@export var _seed: int = 0

@export_group("Rooms")
@export var rooms_presets: Array[RoomData] = []
