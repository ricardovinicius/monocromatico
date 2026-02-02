extends Node

# Simple test scene for lazy loading dungeon generation
# Attach this to a Node in your test scene

@onready var dungeon_manager: DungeonManager = DungeonManager.new()

func _ready():
	add_child(dungeon_manager)
	
	# Create test dungeon data
	var dungeon_data = _create_test_dungeon_data()
	
	# Initialize dungeon (creates only the starting room)
	print("\n=== INITIALIZING DUNGEON ===")
	dungeon_manager._init_dungeon(dungeon_data)
	
	print("\n=== INITIAL STATE ===")
	print_dungeon_state()
	
	# Simulate player entering the starting room
	print("\n=== EXPANDING STARTING ROOM ===")
	var starting_room_uuid = dungeon_manager.dungeon_state.player_starting_room_uuid
	dungeon_manager.expand_room(starting_room_uuid)
	
	print("\n=== STATE AFTER FIRST EXPANSION ===")
	print_dungeon_state()
	
	# Expand one of the newly generated rooms
	if dungeon_manager.dungeon_state.rooms.size() > 1:
		print("\n=== EXPANDING SECOND ROOM ===")
		var second_room = dungeon_manager.dungeon_state.rooms[1]
		dungeon_manager.expand_room(second_room.uuid)
		
		print("\n=== STATE AFTER SECOND EXPANSION ===")
		print_dungeon_state()

func _create_test_dungeon_data() -> DungeonData:
	var dungeon_data = DungeonData.new()
	dungeon_data.description = "Test dungeon for lazy loading"
	dungeon_data._seed = 12345
	
	# Create corridor preset
	var corridor = RoomData.new()
	corridor.preset_id = "corridor_straight"
	corridor.description = "Straight corridor"
	corridor.type = Types.TargetType.CORRIDOR
	
	# Add 2 exits to corridor (north and south)
	var exit_north = ExitData.new()
	exit_north.exit_name = "North"
	exit_north.local_transform = Transform3D(Basis.IDENTITY, Vector3(0, 0, -5))
	exit_north.target_type = Types.TargetType.ROOM
	corridor.exits.append(exit_north)
	
	var exit_south = ExitData.new()
	exit_south.exit_name = "South"
	exit_south.local_transform = Transform3D(Basis.IDENTITY, Vector3(0, 0, 5))
	exit_south.target_type = Types.TargetType.CORRIDOR
	corridor.exits.append(exit_south)
	
	# Create room preset
	var room = RoomData.new()
	room.preset_id = "room_square"
	room.description = "Square room"
	room.type = Types.TargetType.ROOM
	
	# Add 4 exits to room (north, south, east, west)
	var room_exit_north = ExitData.new()
	room_exit_north.exit_name = "North"
	room_exit_north.local_transform = Transform3D(Basis.IDENTITY, Vector3(0, 0, -10))
	room_exit_north.target_type = Types.TargetType.CORRIDOR
	room.exits.append(room_exit_north)
	
	var room_exit_south = ExitData.new()
	room_exit_south.exit_name = "South"
	room_exit_south.local_transform = Transform3D(Basis.IDENTITY, Vector3(0, 0, 10))
	room_exit_south.target_type = Types.TargetType.CORRIDOR
	room.exits.append(room_exit_south)
	
	var room_exit_east = ExitData.new()
	room_exit_east.exit_name = "East"
	room_exit_east.local_transform = Transform3D(Basis.IDENTITY, Vector3(10, 0, 0))
	room_exit_east.target_type = Types.TargetType.ROOM
	room.exits.append(room_exit_east)
	
	var room_exit_west = ExitData.new()
	room_exit_west.exit_name = "West"
	room_exit_west.local_transform = Transform3D(Basis.IDENTITY, Vector3(-10, 0, 0))
	room_exit_west.target_type = Types.TargetType.CORRIDOR
	room.exits.append(room_exit_west)
	
	# Add presets to dungeon data
	dungeon_data.rooms_presets.append(corridor)
	dungeon_data.rooms_presets.append(room)
	
	return dungeon_data

func print_dungeon_state():
	var state = dungeon_manager.dungeon_state
	print("Total rooms: %d" % state.rooms.size())
	print("Starting room: %s" % state.player_starting_room_uuid)
	print("\nRooms:")
	for room in state.rooms:
		print("  - [%s] %s at %s (depth: %d)" % [
			room.uuid.substr(0, 8),
			room.preset_id,
			room.global_position,
			room.depth
		])
		print("    Exits: %d" % room.exits.size())
		for exit in room.exits:
			var connected = "-> " + exit.connected_room_uuid.substr(0, 8) if not exit.connected_room_uuid.is_empty() else "(unconnected)"
			print("      - %s [%s] %s" % [exit.exit_name, Types.TargetType.keys()[exit.target_type], connected])
