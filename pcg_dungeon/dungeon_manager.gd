class_name DungeonManager
extends Node

var dungeon_data: DungeonState = DungeonState.new()

func _ready():
    pass  # Replace with function body.

func init_dungeon() -> DungeonState:
    # Initialize dungeon data
    # TODO: Improve the resource management and loading system
    dungeon_data.uuid = "dungeon_" + str(Time.get_unix_time_from_system()) # TODO: Use a better UUID generator
    dungeon_data.preset_id = "default_dungeon"
    dungeon_data.seed = "seed_" + str(Time.get_unix_time_from_system())
    dungeon_data.rooms_presets = {
        "small_room": preload("res://pcg_dungeon/presets/rooms/small_room.tscn"),
        "medium_room": preload("res://pcg_dungeon/presets/rooms/medium_room.tscn"),
        "large_room": preload("res://pcg_dungeon/presets/rooms/large_room.tscn")
    }

    # Create starting room
    var start_room: RoomState = RoomState.new()
    start_room.uuid = "room_" + str(rand_from_seed(dungeon_data.seed.hash()))

    var preset_index: int = rand_from_seed(dungeon_data.seed.hash())[0] % dungeon_data.rooms_presets.size()
    start_room.preset_id = dungeon_data.rooms_presets.keys()[preset_index]

    dungeon_data.rooms.append(start_room)
    
    return dungeon_data


func generate_next(current_room_state: RoomState, exit_name: String) -> void:
    # Generate the next part of the dungeon, based on the current room and exit used.
    var current_room_data: RoomData = dungeon_data.rooms_presets.get(current_room_state.preset_id)

    var current_exit_data: ExitData = current_room_data.exits.get(exit_name)
    var current_exit_global_transform: Transform3D = current_room_state.global_transform * current_exit_data.local_transform

    var new_room: RoomState = RoomState.new()
    new_room.uuid = "room_" + str(rand_from_seed(current_room_state.uuid.hash() + dungeon_data.seed.hash())[0])
    
    # TODO: This is just a placeholder logic for selecting a preset
    # In a real implementation, you would consider the exit used and other factors.
    # TODO: Refactor preset selection logic to a separate function
    var preset_index: int = rand_from_seed(dungeon_data.seed.hash())[0] % dungeon_data.rooms_presets.size()
    new_room.preset_id = dungeon_data.rooms_presets.keys()[preset_index]
    new_room.depth = current_room_state.depth + current_exit_data.depth_increment

    var corridor: CorridorState = CorridorState.new()
    corridor.uuid = "corridor_" + str(rand_from_seed(new_room.uuid.hash() + current_room_state.uuid.hash())[0])
    var corridor_preset_index: int = rand_from_seed(dungeon_data.seed.hash() + 1)[0] % dungeon_data.corridors_presets.size()
    corridor.preset_id = dungeon_data.corridors_presets.keys()[corridor_preset_index]
    corridor.room_a_uuid = current_room_state.uuid
    corridor.room_b_uuid = new_room.uuid

    # Position the new room based on the exit used
    var new_room_data: RoomData = dungeon_data.rooms_presets.get(new_room.preset_id)
    var new_room_entry_index: int = rand_from_seed(new_room.uuid.hash())[0] % new_room_data.exits.size()
    var new_room_entry_exit: ExitData = new_room_data.exits.values()[new_room_entry_index]
    var new_room_entry_global_transform: Transform3D = new_room_entry_exit.local_transform.affine_inverse() 
    new_room.global_transform = current_exit_global_transform * new_room_entry_global_transform
    dungeon_data.rooms.append(new_room)

    # Update exits connectivity
    current_room_state.exits[exit_name] = {
        "corridor_uuid": corridor.uuid,
        "type": "connected"
    }
    new_room.exits[new_room_entry_exit.exit_name] = {
        "corridor_uuid": corridor.uuid,
        "type": "connected"
    }
    corridor.socket_room_a = exit_name
    corridor.socket_room_b = new_room_entry_exit.exit_name

    dungeon_data.corridors.append(corridor)
    

