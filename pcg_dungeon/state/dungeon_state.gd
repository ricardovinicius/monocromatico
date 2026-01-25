class_name DungeonState
extends Resource

@export_group("Identity")
@export var uuid: String = ""
@export var preset_id: String = ""
@export var seed: String = ""

@export_group("Presets")
# Mapping of preset IDs to their data
@export var rooms_presets: Dictionary = {}
@export var corridors_presets: Dictionary = {}

@export_group("Structure")
@export var rooms: Array[RoomState] = []
@export var corridors: Array[CorridorState] = []

@export_group("Gameplay State")
# TODO: Adjust according to your game's needs
@export var is_cleared: bool = false
@export var player_starting_room_uuid: String = ""
@export var boss_room_uuid: String = ""
@export var treasure_room_uuids: Array[String] = []
