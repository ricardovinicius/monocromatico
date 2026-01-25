class_name DungeonGenerator
extends Node

const GRID_SIZE = 10.0 # Standard spacing between room centers

@export var master_seed: String = "monocromatico_default"

## Virtual Grid Registry for overlap prevention
var _grid_registry: Dictionary = {} 
var dungeon_graph: Dictionary = {"rooms": {}, "corridors": {}}
var _room_count: int = 0

func _ready() -> void:
	seed(master_seed.hash())

## Main entry point for generating the next piece of the graph
func generate_next_step(from_room: RoomState, exit_socket: Marker3D) -> void:
	# 1. Directional Depth Logic
	var socket_forward = -exit_socket.global_transform.basis.z
	var depth_mod = 0
	
	# North (-Z) increases depth, South (+Z) decreases depth
	if socket_forward.z < -0.5: depth_mod = 1
	elif socket_forward.z > 0.5: depth_mod = -1
	
	var target_depth = from_room.depth + depth_mod
	
	# 2. Vector Projection for Positioning
	var next_position = exit_socket.global_position + (socket_forward * (GRID_SIZE / 2.0))
	# Position the center of the next room another half-grid away
	next_position += socket_forward * (GRID_SIZE / 2.0)

	# 3. Constraint: No rooms with Z > 0 (behind the start)
	if next_position.z > 0.1:
		print("[PCG] Aborted: Out of bounds (Z > 0)")
		return

	# 4. Constraint: Overlap Prevention
	var room_size := Vector3(8, 4, 8)
	if not is_space_available(next_position, room_size):
		print("[PCG] Aborted: Space Occupied at ", next_position)
		return

	# 5. Room Setup
	_room_count += 1
	var next_room := RoomState.new()
	next_room.uuid = "room_" + str(_room_count) + "_d" + str(randi())
	next_room.depth = target_depth
	next_room.global_position = next_position
	# Perpendicular alignment: The room faces the same way as the exit
	next_room.global_rotation = exit_socket.global_rotation.y
	
	# 6. Data Persistence
	register_room_occupancy(next_room.uuid, next_position, room_size)
	
	var corridor := CorridorState.new()
	corridor.uuid = _generate_edge_hash(from_room.uuid, next_room.uuid)
	corridor.room_a_uuid = from_room.uuid
	corridor.room_b_uuid = next_room.uuid
	corridor.output_displacement = next_position
	
	dungeon_graph["rooms"][next_room.uuid] = next_room
	dungeon_graph["corridors"][corridor.uuid] = corridor
	from_room.exits[exit_socket.name] = {"corridor_uuid": corridor.uuid}
	
	print("[PCG] Created %s at %s (Depth: %d)" % [next_room.uuid, str(next_position), target_depth])

## Hashed Edge System for bidirectional consistency
func _generate_edge_hash(id_a: String, id_b: String) -> String:
	var ids := [id_a, id_b]
	ids.sort()
	return "corr_" + str((ids[0] + ids[1]).hash())

func is_space_available(pos: Vector3, size: Vector3) -> bool:
	var grid_pos = Vector3i(round(pos.x/GRID_SIZE), 0, round(pos.z/GRID_SIZE))
	return not _grid_registry.has(grid_pos)

func register_room_occupancy(uuid: String, pos: Vector3, size: Vector3) -> void:
	var grid_pos = Vector3i(round(pos.x/GRID_SIZE), 0, round(pos.z/GRID_SIZE))
	_grid_registry[grid_pos] = uuid