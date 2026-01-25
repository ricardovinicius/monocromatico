class_name CorridorState
extends Resource

# This code defines the state of a corridor connecting two rooms in a procedurally generated dungeon.
# The generation of corridors is deterministic based on the UUIDs of the rooms they connect.
# And this happens when the player moves from one room to another.
# e.g when the player enter into Room A, the system generates Corridor AB to connect Room A to Room B.

# ==========================================
# 1. Edge Identity
# ==========================================
@export_group("Identity")
## The deterministic UUID hash of (Room A UUID + Room B UUID)
@export var uuid: String = ""
## The specific deterministic seed for this hallway
@export var corridor_seed: int = 0
## Path to the 3D PackedScene (e.g., "res://pcg_dungeon/prefabs/corridors/winding_tunnel.tscn")
@export var preset_id: String = ""

# ==========================================
# 2. Graph Connections
# ==========================================
@export_group("Connections")
## The UUID of the room the player is leaving
@export var room_a_uuid: String = ""
## The UUID of the room the player is entering
@export var room_b_uuid: String = ""

# ==========================================
# 3. Vectorial Displacement (The Math)
# ==========================================
@export_group("Geometry")
## The exact 3D displacement vector from Room A's exit to Room B's entrance
@export var output_displacement: Vector3 = Vector3.ZERO