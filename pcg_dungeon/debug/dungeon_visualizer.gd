extends Node2D

# Visual debug tool for dungeon layout
# Shows rooms as boxes and connections as lines
# Features: zoom, pan, color-coded rooms, grid background

@export var dungeon_manager: DungeonManager
@export var room_size: float = 30.0 # Base size of room boxes (visual representation)
@export var world_to_pixel_scale: float = 3.0 # 3D world units to pixel ratio (1 world unit = 3 pixels at zoom 1.0)
@export var show_grid: bool = true
@export var show_depth: bool = true
@export var show_exit_directions: bool = true

# Camera controls
var camera_offset: Vector2 = Vector2.ZERO
var zoom_level: float = 1.0
var is_panning: bool = false
var pan_start_pos: Vector2 = Vector2.ZERO

# Current room tracking (set by visualizer_ui)
var current_room_uuid: String = ""

# Constants
const ZOOM_MIN: float = 0.3
const ZOOM_MAX: float = 5.0
const ZOOM_STEP: float = 1.15
const PAN_SPEED: float = 5.0

# Color scheme
const COLOR_STARTING_ROOM: Color = Color(0.2, 1.0, 0.3, 1.0) # Bright green
const COLOR_CURRENT_ROOM: Color = Color(1.0, 0.9, 0.2, 1.0) # Yellow highlight
const COLOR_ROOM: Color = Color(0.3, 0.5, 0.9, 1.0) # Blue
const COLOR_CORRIDOR: Color = Color(0.7, 0.4, 0.9, 1.0) # Purple
const COLOR_CONNECTION: Color = Color(0.9, 0.9, 0.3, 0.8) # Yellow line
const COLOR_EXIT_CONNECTED: Color = Color(0.3, 1.0, 0.4, 1.0) # Bright green
const COLOR_EXIT_UNCONNECTED: Color = Color(1.0, 0.3, 0.2, 1.0) # Red
const COLOR_GRID: Color = Color(0.2, 0.2, 0.25, 0.3) # Dark gray
const COLOR_LABEL: Color = Color(1.0, 1.0, 1.0, 0.9) # White

func _ready():
	if dungeon_manager == null:
		push_error("DungeonManager not assigned to DebugVisualizer")
		return

func _input(event: InputEvent) -> void:
	# Zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_level = clamp(zoom_level * ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_level = clamp(zoom_level / ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_pos = event.position
			else:
				is_panning = false
	
	# Pan with middle mouse drag
	if event is InputEventMouseMotion and is_panning:
		camera_offset += event.relative
		queue_redraw()

func _process(delta: float) -> void:
	# Keyboard pan controls (WASD or Arrow Keys)
	var pan_input: Vector2 = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		pan_input.y += 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		pan_input.y -= 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		pan_input.x += 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		pan_input.x -= 1
	
	if pan_input != Vector2.ZERO:
		camera_offset += pan_input.normalized() * PAN_SPEED * 100.0 * delta / zoom_level
		queue_redraw()

func _draw():
	if dungeon_manager == null or dungeon_manager.dungeon_state == null:
		return
	
	var state = dungeon_manager.dungeon_state
	
	# Draw grid background
	if show_grid:
		_draw_grid()
	
	# Draw connections first (behind rooms)
	for room in state.rooms:
		for exit in room.exits:
			if not exit.connected_room_uuid.is_empty():
				var target_room = _get_room_by_uuid(exit.connected_room_uuid)
				if target_room != null:
					var from_pos = _world_to_screen(room.global_position)
					var to_pos = _world_to_screen(target_room.global_position)
					
					# Draw gradient line
					draw_line(from_pos, to_pos, COLOR_CONNECTION, 2.0 * zoom_level)
					
					# Draw direction arrow
					if show_exit_directions:
						_draw_arrow(from_pos, to_pos, COLOR_CONNECTION)
	
	# Draw rooms
	for room in state.rooms:
		_draw_room(room, state)

func _draw_grid():
	var viewport_size = get_viewport_rect().size
	var grid_spacing: float = 50.0 * zoom_level
	var center = viewport_size / 2 + camera_offset
	
	# Calculate grid bounds
	var start_x = fmod(center.x, grid_spacing) - grid_spacing
	var start_y = fmod(center.y, grid_spacing) - grid_spacing
	
	# Draw vertical lines
	var x = start_x
	while x < viewport_size.x + grid_spacing:
		draw_line(Vector2(x, 0), Vector2(x, viewport_size.y), COLOR_GRID, 1.0)
		x += grid_spacing
	
	# Draw horizontal lines
	var y = start_y
	while y < viewport_size.y + grid_spacing:
		draw_line(Vector2(0, y), Vector2(viewport_size.x, y), COLOR_GRID, 1.0)
		y += grid_spacing

func _draw_room(room: RoomState, state: DungeonState):
	var screen_pos = _world_to_screen(room.global_position)
	
	# Determine color based on type and state
	var color: Color = COLOR_ROOM
	var is_starting = (room.uuid == state.player_starting_room_uuid)
	var is_current = (room.uuid == current_room_uuid)
	
	if is_starting:
		color = COLOR_STARTING_ROOM
	elif room.preset_id.contains("corridor"):
		color = COLOR_CORRIDOR
	
	# Draw room box
	var scaled_size = room_size * zoom_level
	var rect = Rect2(screen_pos - Vector2(scaled_size / 2, scaled_size / 2), Vector2(scaled_size, scaled_size))
	
	# Fill with semi-transparent color
	draw_rect(rect, Color(color.r, color.g, color.b, 0.3), true)
	
	# Border - thicker if current room
	var border_width = 3.0 * zoom_level if is_current else 2.0 * zoom_level
	var border_color = COLOR_CURRENT_ROOM if is_current else color
	draw_rect(rect, border_color, false, border_width)
	
	# Draw room label (preset_id)
	var label_offset = Vector2(0, -scaled_size / 2 - 18 * zoom_level)
	var font_size = int(12 * clamp(zoom_level, 0.8, 2.0))
	draw_string(ThemeDB.fallback_font, screen_pos + label_offset, room.preset_id, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, COLOR_LABEL)
	
	# Draw depth indicator
	if show_depth:
		var depth_label = "D%d" % room.depth
		var depth_offset = Vector2(0, scaled_size / 2 + 8 * zoom_level)
		draw_string(ThemeDB.fallback_font, screen_pos + depth_offset, depth_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.8, 0.8, 0.8, 0.7))
	
	# Draw exits
	for exit in room.exits:
		_draw_exit(room, exit, scaled_size, screen_pos)

func _draw_exit(room: RoomState, exit: ExitState, _scaled_size: float, _room_screen_pos: Vector2) -> void:
	# Calculate exit's world position
	var exit_local_3d = exit.local_transform.origin
	var exit_world_3d = room.global_position + exit_local_3d.rotated(Vector3.UP, room.global_rotation)
	
	# Convert to screen position using the same world-to-screen transform as rooms
	var exit_pos = _world_to_screen(exit_world_3d)
	
	var exit_color = COLOR_EXIT_CONNECTED if not exit.connected_room_uuid.is_empty() else COLOR_EXIT_UNCONNECTED
	
	# Draw exit circle (larger at higher zoom)
	var circle_radius = 4.0 * clamp(zoom_level, 0.5, 1.5)
	draw_circle(exit_pos, circle_radius, exit_color)
	draw_circle(exit_pos, circle_radius, Color.WHITE, false, 1.5) # White outline
	
	# Draw exit name (only if zoomed in enough)
	if zoom_level > 0.7:
		var exit_label_offset = Vector2(0, -14 * zoom_level)
		var font_size = int(10 * clamp(zoom_level, 0.6, 1.5))
		draw_string(ThemeDB.fallback_font, exit_pos + exit_label_offset, exit.exit_name, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, COLOR_LABEL)

func _draw_arrow(from: Vector2, to: Vector2, color: Color):
	# Draw a small arrow pointing from -> to
	var direction = (to - from).normalized()
	var midpoint = (from + to) / 2
	var arrow_size = 8.0 * zoom_level
	
	# Calculate arrow points
	var arrow_angle = 2.5 # radians
	var left = midpoint - direction.rotated(arrow_angle) * arrow_size
	var right = midpoint - direction.rotated(-arrow_angle) * arrow_size
	
	# Draw arrow triangle
	draw_colored_polygon(PackedVector2Array([midpoint, left, right]), color)

func _world_to_screen(world_pos: Vector3) -> Vector2:
	# Convert 3D world position to 2D screen position with zoom and pan
	# Scale factor converts world units to pixels
	var center = get_viewport_rect().size / 2
	var world_2d = Vector2(world_pos.x, world_pos.z)
	return center + camera_offset + (world_2d * world_to_pixel_scale * zoom_level)

func _get_room_by_uuid(uuid: String) -> RoomState:
	if dungeon_manager == null or dungeon_manager.dungeon_state == null:
		return null
	
	for room in dungeon_manager.dungeon_state.rooms:
		if room.uuid == uuid:
			return room
	return null

func reset_view():
	"""Reset zoom and pan to default"""
	camera_offset = Vector2.ZERO
	zoom_level = 1.0
	queue_redraw()
