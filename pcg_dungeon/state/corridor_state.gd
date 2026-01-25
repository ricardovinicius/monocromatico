class_name CorridorState
extends Resource

@export_group("Identity")
@export var uuid: String = ""
@export var preset_id: String = "default_hallway"

@export_group("Graph Connections")
@export var room_a_uuid: String = ""
@export var room_b_uuid: String = ""

# ==========================================
# 2. Logical Socket Mapping
# ==========================================
@export_group("Sockets")
## The name of the Marker3D in Room A 
@export var socket_room_a: String = ""
## The name of the Marker3D in Room B 
@export var socket_room_b: String = ""