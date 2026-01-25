extends Control

@onready var generator: DungeonGenerator = $DungeonGenerator

func _ready() -> void:
	var start_room := RoomState.new()
	start_room.uuid = "start"
	start_room.global_position = Vector3.ZERO
	generator.dungeon_graph["rooms"]["start"] = start_room
	generator.register_room_occupancy("start", Vector3.ZERO, Vector3(8,4,8))
	
	_test_massive_generation(start_room, 8)

func _test_massive_generation(current_room: RoomState, depth: int) -> void:
	if depth <= 0: return
	
	# Simulate 1 to 3 exits
	var exit_count = randi_range(1, 3)
	var possible_dirs = [Vector3.FORWARD, Vector3.LEFT, Vector3.RIGHT]
	possible_dirs.shuffle()
	
	for i in range(exit_count):
		var dir = possible_dirs[i]
		var mock_exit = Marker3D.new()
		mock_exit.name = "Exit_" + str(current_room.uuid) + "_" + str(i)
		add_child(mock_exit)
		
		# Rotate mock exit based on direction
		var angle = 0
		if dir == Vector3.LEFT: angle = PI/2
		elif dir == Vector3.RIGHT: angle = -PI/2
		
		mock_exit.global_rotation.y = current_room.global_rotation + angle
		mock_exit.global_position = current_room.global_position + (dir.rotated(Vector3.UP, current_room.global_rotation) * 5.0)
		
		generator.generate_next_step(current_room, mock_exit)
		
		if current_room.exits.has(mock_exit.name):
			var exit_data = current_room.exits[mock_exit.name]
			var corr = generator.dungeon_graph["corridors"][exit_data["corridor_uuid"]]
			var next_room = generator.dungeon_graph["rooms"][corr.room_b_uuid]
			
			mock_exit.queue_free()
			await get_tree().process_frame
			_test_massive_generation(next_room, depth - 1)
		else:
			mock_exit.queue_free()
	
	queue_redraw()

func _draw() -> void:
	var center := Vector2(get_viewport().size.x / 2.0, get_viewport().size.y * 0.9)
	var zoom := 3.0
	
	for c_id in generator.dungeon_graph["corridors"]:
		var c = generator.dungeon_graph["corridors"][c_id]
		var r_a = generator.dungeon_graph["rooms"][c.room_a_uuid]
		var r_b = generator.dungeon_graph["rooms"][c.room_b_uuid]
		var p1 = center + Vector2(r_a.global_position.x, r_a.global_position.z) * zoom
		var p2 = center + Vector2(r_b.global_position.x, r_b.global_position.z) * zoom
		
		draw_line(p1, p2, Color.GREEN, 1.5)

	for r_id in generator.dungeon_graph["rooms"]:
		var r = generator.dungeon_graph["rooms"][r_id]
		var p = center + Vector2(r.global_position.x, r.global_position.z) * zoom
		draw_circle(p, 3.0, Color.WHITE)
		draw_string(ThemeDB.fallback_font, p + Vector2(5, -5), str(r.depth), HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
