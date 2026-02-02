class_name DungeonState
extends Resource

@export_group("Identity")
@export var uuid: String = ""
@export var preset_id: String = ""
@export var _seed: int = 0

@export_group("Structure")
@export var rooms: Array[RoomState] = []

@export_group("Gameplay State")
# TODO: Adjust according to your game's needs
@export var is_cleared: bool = false
@export var player_starting_room_uuid: String = ""
@export var boss_room_uuid: String = ""
@export var treasure_room_uuids: Array[String] = []
