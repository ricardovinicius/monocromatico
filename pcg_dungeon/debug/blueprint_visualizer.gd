extends Control

@onready var generator: DungeonGenerator = $DungeonGenerator
const ROOM_REAL_SIZE = 20.0 # Your room is 20m wide
const ROOM_PX = 40.0 # Visual size in pixels

func _ready() -> void:
	var start := RoomState.new()
	start.uuid = "start"; start.global_position = Vector3.ZERO
	generator.dungeon_graph["rooms"]["start"] = start
	generator._grid_registry[Vector3i.ZERO] = "start"
	_run_generation_test(start, 5)

func _run_generation_test(room: RoomState, depth_limit: int) -> void:
	if depth_limit <= 0: return
	
	# Mocking 3 potential directions
	var dirs = [Vector3.FORWARD, Vector3.LEFT, Vector3.RIGHT]
	
	for dir in dirs:
		var mock_socket = Marker3D.new()
		add_child(mock_socket)
		
		var angle = 0
		if dir == Vector3.LEFT: angle = PI/2
		elif dir == Vector3.RIGHT: angle = -PI/2
		
		mock_socket.global_rotation.y = room.global_rotation + angle
		
		# FIX: Place marker at the PHYSICAL EDGE of the room (10m from center)
		var edge_offset = dir.rotated(Vector3.UP, room.global_rotation) * (ROOM_REAL_SIZE)
		mock_socket.global_position = room.global_position + edge_offset 
		mock_socket.name = "Socket_" + str(room.uuid) + "_" + str(dir)
		
		var next = generator.generate_next_step(room, mock_socket)
		mock_socket.queue_free()
		
		if next:
			await get_tree().process_frame
			_run_generation_test(next, depth_limit - 1)
	queue_redraw()

func _draw() -> void:
	var offset := Vector2(get_viewport().size.x / 2.0, get_viewport().size.y * 0.9)
	var zoom := 2.0 # Pixels per meter
	var room_visual_size = 20.0 * zoom

	for c_id in generator.dungeon_graph["corridors"]:
		var c: CorridorState = generator.dungeon_graph["corridors"][c_id]
		var room_a_exit = generator.dungeon_graph["rooms"][c.room_a_uuid].exits[c.exit_socket_a]
		var room_b_exit = generator.dungeon_graph["rooms"][c.room_b_uuid].exits[c.entry_socket_b]
		var room_a_pos = generator.dungeon_graph["rooms"][c.room_a_uuid].global_position
		var room_b_pos = generator.dungeon_graph["rooms"][c.room_b_uuid].global_position
		
		var door_pos_start = offset + Vector2(room_a_pos.x + room_a_exit.x, room_a_pos.z + room_a_exit.z) * zoom
		var door_pos_end = offset + Vector2(room_b_pos.x + room_b_exit.x, room_b_pos.z + room_b_exit.z) * zoom

		draw_line(door_pos_start, door_pos_end, Color.YELLOW, 2.0)

	for r_id in generator.dungeon_graph["rooms"]:
		var r = generator.dungeon_graph["rooms"][r_id]
		var p = offset + Vector2(r.global_position.x, r.global_position.z) * zoom
		var rect = Rect2(p - Vector2(room_visual_size/2, room_visual_size/2), Vector2(room_visual_size, room_visual_size))
		
		draw_rect(rect, Color(0.1, 0.4, 0.7, 0.5), true)
		draw_rect(rect, Color.WHITE, false, 1.0)
