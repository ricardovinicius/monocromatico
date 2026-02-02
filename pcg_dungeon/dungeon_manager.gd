class_name DungeonManager
extends Node

var dungeon_state: DungeonState = DungeonState.new()
var dungeon_data: DungeonData

func _ready():
	pass # Replace with function body.

func expand_room(room_uuid: String) -> void:
	## Expand a room by generating new rooms for all unconnected exits (lazy loading)
	##
	## This method is called when a player enters a room. It checks all exits
	## and generates new rooms for any that aren't already connected.
	##
	## @param room_uuid: The UUID of the room to expand
	var room: RoomState = _get_room_by_uuid(room_uuid)
	if room == null:
		push_error("Cannot expand room: Room with UUID %s not found" % room_uuid)
		return
	
	# Find the corresponding RoomData preset
	var room_preset: RoomData = _get_room_preset_by_id(room.preset_id)
	if room_preset == null:
		push_error("Cannot expand room: Preset %s not found" % room.preset_id)
		return
	
	# Iterate through all exits in the room
	print("  [Expand] Room has %d exits" % room.exits.size())
	for i in range(room.exits.size()):
		var exit: ExitState = room.exits[i]
		
		print("  [Expand] Checking exit '%s': connected=%s" % [exit.exit_name, not exit.connected_room_uuid.is_empty()])
		
		# Skip if already connected
		if not exit.connected_room_uuid.is_empty():
			continue
		
		# Generate next room (exit already contains all necessary transform data)
		var new_room: RoomState = _generate_next(room, exit)
		if new_room != null:
			dungeon_state.rooms.append(new_room)
			print("[Lazy Load] Generated room %s from exit '%s' in room %s" % [new_room.uuid, exit.exit_name, room_uuid])

func _get_room_by_uuid(uuid: String) -> RoomState:
	## Find a room in the dungeon by its UUID
	##
	## @param uuid: The UUID to search for
	## @return: The RoomState if found, null otherwise
	for room in dungeon_state.rooms:
		if room.uuid == uuid:
			return room
	return null

func _get_room_preset_by_id(preset_id: String) -> RoomData:
	## Find a room preset by its ID
	##
	## @param preset_id: The preset ID to search for
	## @return: The RoomData if found, null otherwise
	if dungeon_data == null:
		return null
	
	for preset in dungeon_data.rooms_presets:
		if preset.preset_id == preset_id:
			return preset
	return null

func _init_dungeon(dungeon_data: DungeonData):
	## Initialize the dungeon with the given dungeon data
	##
	## Creates a new DungeonState with the given dungeon data
	##
	## @param dungeon_data: The dungeon data to initialize the dungeon with
	## @return: The dungeon state
	##
	## @throws: Exception if the dungeon data is invalid
	# Setup
	self.dungeon_data = dungeon_data

	dungeon_state.uuid = Utils.generate_uuid("dungeon", dungeon_data._seed)
	dungeon_state._seed = dungeon_data._seed
	
	
	# Generate starting room (always use ROOM type)
	var starting_room_preset: RoomData = _get_preset_by_type(Types.TargetType.ROOM)
	if starting_room_preset == null:
		push_error("No ROOM type presets available for starting room!")
		return
	
	var starting_room: RoomState = _create_room_from_preset(starting_room_preset, Vector3.ZERO, 0.0, 0)
	dungeon_state.rooms.append(starting_room)
	dungeon_state.player_starting_room_uuid = starting_room.uuid

func _create_room_from_preset(preset: RoomData, position: Vector3, rotation: float, depth: int) -> RoomState:
	## Create a new RoomState from a RoomData preset
	##
	## Creates a new RoomState with the given room data preset.
	##
	## @param preset: The room data preset to create the room from
	## @param position: The global position of the room in the world
	## @param rotation: The global Y-axis rotation in radians
	## @param depth: The depth of the room in the dungeon
	## @return: The room state
	##
	## @throws: Exception if the preset is invalid
	# TODO: Implement room creation
	var room: RoomState = RoomState.new()
	# Generate unique UUID using position and depth to ensure uniqueness
	var room_seed: int = dungeon_data._seed + int(position.x * 1000) + int(position.z * 1000) + depth
	room.uuid = Utils.generate_uuid("room", room_seed)
	room.preset_id = preset.preset_id
	room.depth = depth
	room.global_position = position
	room.global_rotation = rotation
	room.is_visited = false
	room.is_cleared = false
	
	for i in range(preset.exits.size()):
		var e: ExitData = preset.exits[i]
		var exit: ExitState = ExitState.new()
		# Generate unique exit UUID using room seed + exit index
		exit.uuid = Utils.generate_uuid("exit", room_seed + i)
		exit.exit_name = e.exit_name
		exit.local_transform = e.local_transform
		exit.target_type = e.target_type
		room.exits.append(exit)

	return room

func _get_preset_by_type(target_type: Types.TargetType) -> RoomData:
	## Get a random room preset matching the specified type
	##
	## Filters available room presets by type and returns a random match.
	##
	## @param target_type: The target type to filter by
	## @return: A random room preset of the specified type, or a random fallback if none found
	var filtered: Array[RoomData] = dungeon_data.rooms_presets.filter(
		func(r: RoomData) -> bool: return r.type == target_type
	)
	
	if filtered.is_empty():
		push_warning("No presets found for type: %s. Using random fallback." % str(target_type))
		if dungeon_data.rooms_presets.is_empty():
			push_error("No room presets available in dungeon_data!")
			return null
		return dungeon_data.rooms_presets.pick_random()
	
	return filtered.pick_random()

func _generate_next(from_room: RoomState, from_exit: ExitState) -> RoomState:
	## Generate the next room in the dungeon
	##
	## Creates a new RoomState by picking any exit from the new room preset
	## and aligning it with the origin exit (facing opposite directions).
	##
	## @param from_room: The room state to generate the next room from
	## @param from_exit: The exit state to generate the next room from
	## @return: The next room state, or null if generation fails
	# Select the next room preset based on exit type
	var next_room_preset: RoomData = _get_preset_by_type(from_exit.target_type)
	
	if next_room_preset == null:
		push_error("Failed to get room preset for exit type: %s" % str(from_exit.target_type))
		return null
	
	if next_room_preset.exits.is_empty():
		push_error("Room preset '%s' has no exits!" % next_room_preset.preset_id)
		return null
	
	# STEP 1: Calculate origin exit's world position and direction
	var exit_local_pos: Vector3 = from_exit.local_transform.origin
	var exit_world_pos: Vector3 = from_room.global_position + exit_local_pos.rotated(Vector3.UP, from_room.global_rotation)
	
	# Extract exit's forward direction (basis.z points backward in Godot, so negate it)
	var exit_local_forward: Vector3 = - from_exit.local_transform.basis.z
	var exit_world_forward: Vector3 = exit_local_forward.rotated(Vector3.UP, from_room.global_rotation)
	
	# STEP 2: Pick any exit from the new room preset (we'll rotate the room to align it)
	# For now, pick the first exit - later we can make this random or rule-based
	var return_exit_data: ExitData = next_room_preset.exits.pick_random() # // TODO: This MUST be based on the seed
	
	# STEP 3: Calculate rotation to align return exit opposite to origin exit
	# The return exit should face the opposite direction of the origin exit
	var return_local_forward: Vector3 = - return_exit_data.local_transform.basis.z
	
	# Get angles in world space
	var origin_exit_angle: float = atan2(exit_world_forward.x, exit_world_forward.z)
	var return_exit_local_angle: float = atan2(return_local_forward.x, return_local_forward.z)
	
	# New room rotation = make return exit face opposite (180°) to origin exit
	var new_room_rotation: float = origin_exit_angle + PI - return_exit_local_angle
	
	# STEP 4: Calculate position so the return exit aligns with origin exit
	# The return exit in the new room should be at the same world position as the origin exit
	var return_exit_local_pos: Vector3 = return_exit_data.local_transform.origin
	var return_exit_offset: Vector3 = return_exit_local_pos.rotated(Vector3.UP, new_room_rotation)
	var new_room_position: Vector3 = exit_world_pos - return_exit_offset
	
	# COLLISION CHECK: Verify if the new room would overlap with existing rooms
	if _check_room_overlap(new_room_position):
		print("  [Gen] BLOCKED: Room would overlap at position %s - exit remains closed" % new_room_position)
		return null # Don't generate room, exit stays unconnected
	
	# Debug output
	print("  [Gen] From room '%s' at %s (rot: %.2f rad)" % [from_room.preset_id, from_room.global_position, from_room.global_rotation])
	print("  [Gen] Origin exit '%s' world pos: %s, forward: %s (angle: %.2f)" % [from_exit.exit_name, exit_world_pos, exit_world_forward, origin_exit_angle])
	print("  [Gen] Return exit '%s' (local forward: %s, angle: %.2f)" % [return_exit_data.exit_name, return_local_forward, return_exit_local_angle])
	print("  [Gen] New room '%s' at: %s (rot: %.2f rad)" % [next_room_preset.preset_id, new_room_position, new_room_rotation])
	
	# STEP 5: Create the room
	var next_room: RoomState = _create_room_from_preset(next_room_preset, new_room_position, new_room_rotation, from_room.depth + 1)
	
	# STEP 6: Connect the exits
	_connect_exits(from_room, from_exit, next_room, return_exit_data.exit_name)
	
	return next_room

func _connect_exits(from_room: RoomState, from_exit: ExitState, to_room: RoomState, return_exit_name: String) -> void:
	## Connect the exits between two rooms bidirectionally
	##
	## Updates the exit in from_room to point to to_room and connects
	## the specified return exit in to_room back to from_room.
	##
	## @param from_room: The originating room
	## @param from_exit: The exit in from_room that leads to to_room
	## @param to_room: The destination room
	## @param return_exit_name: The name of the exit in to_room to use as return path
	# Connect the origin exit to the new room
	from_exit.connected_room_uuid = to_room.uuid
	from_exit.is_open = true
	
	# Find and connect the specific return exit by name
	var found_return_exit: bool = false
	for exit in to_room.exits:
		if exit.exit_name == return_exit_name:
			exit.connected_room_uuid = from_room.uuid
			exit.is_open = true
			found_return_exit = true
			print("  [Connect] Connected '%s'.'%s' <-> '%s'.'%s'" % [from_room.preset_id, from_exit.exit_name, to_room.preset_id, exit.exit_name])
			break
	
	if not found_return_exit:
		push_warning("Could not find return exit '%s' in room '%s'" % [return_exit_name, to_room.preset_id])

func _check_room_overlap(new_position: Vector3, min_distance: float = 15.0) -> bool:
	## Check if a room at new_position would overlap with existing rooms
	##
	## Uses a simple distance check - if any existing room is too close,
	## we consider it an overlap.
	##
	## @param new_position: The world position of the potential new room
	## @param min_distance: Minimum distance between room centers (default: 15 units)
	## @return: true if overlap detected, false otherwise
	for room in dungeon_state.rooms:
		var distance = new_position.distance_to(room.global_position)
		if distance < min_distance:
			return true # Too close, would overlap
	
	return false # No overlap detected
