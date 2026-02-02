extends VBoxContainer

# Script de controle para testar o dungeon visualmente
# Anexe este script a um VBoxContainer com botões de controle

@export var dungeon_manager: DungeonManager
@export var visualizer: Node2D # Reference to DungeonVisualizer
var current_room_index: int = 0

func _on_initialize_pressed():
	# Botão "Initialize Dungeon" - Cria um dungeon novo
	var dungeon_data: DungeonData = _create_test_data()
	dungeon_manager._init_dungeon(dungeon_data)
	current_room_index = 0
	_update_visualizer_current_room()
	print("=== Dungeon inicializado! ===")
	print("Salas: %d" % dungeon_manager.dungeon_state.rooms.size())
	if visualizer and visualizer.has_method("reset_view"):
		visualizer.reset_view()

func _on_expand_pressed():
	# Botão "Expand Current Room" - Expande a sala atual
	if dungeon_manager.dungeon_state.rooms.is_empty():
		print("Nenhuma sala para expandir!")
		return
	
	var room: RoomState = dungeon_manager.dungeon_state.rooms[current_room_index]
	print("=== Expandindo sala %d: %s ===" % [current_room_index, room.uuid.substr(0, 8)])
	dungeon_manager.expand_room(room.uuid)
	print("Total de salas agora: %d" % dungeon_manager.dungeon_state.rooms.size())

func _on_next_room_pressed():
	# Botão "Go to Next Room" - Avança para próxima sala
	if dungeon_manager.dungeon_state.rooms.is_empty():
		print("Nenhuma sala disponível!")
		return
	
	current_room_index += 1
	if current_room_index >= dungeon_manager.dungeon_state.rooms.size():
		current_room_index = 0
	
	var room: RoomState = dungeon_manager.dungeon_state.rooms[current_room_index]
	_update_visualizer_current_room()
	
	print(">>> Sala atual: %d/%d - %s (depth: %d)" % [
		current_room_index + 1,
		dungeon_manager.dungeon_state.rooms.size(),
		room.preset_id,
		room.depth
	])

# Função auxiliar - cria dados de teste
func _create_test_data() -> DungeonData:
	var dungeon_data: DungeonData = DungeonData.new()
	dungeon_data.description = "Test dungeon"
	dungeon_data._seed = 45678
	
	# Criar preset de corredor
	var corridor: RoomData = RoomData.new()
	corridor.preset_id = "corridor"
	corridor.description = "Corredor"
	corridor.type = Types.TargetType.CORRIDOR
	
	var exit1: ExitData = ExitData.new()
	exit1.exit_name = "North"
	# North exit: position at -Z, facing -Z (forward/outward)
	exit1.local_transform = Transform3D(Basis.IDENTITY, Vector3(0, 0, -5))
	exit1.target_type = Types.TargetType.ROOM
	corridor.exits.append(exit1)
	
	var exit2: ExitData = ExitData.new()
	exit2.exit_name = "South"
	# South exit: position at +Z, facing +Z (backward/outward)
	# Rotate 180° so forward (-Z) points to +Z
	# Changed to ROOM to prevent infinite corridor chains
	var south_basis: Basis = Basis(Vector3.UP, PI)
	exit2.local_transform = Transform3D(south_basis, Vector3(0, 0, 5))
	exit2.target_type = Types.TargetType.ROOM # Changed from CORRIDOR to ROOM
	corridor.exits.append(exit2)
	
	# Criar preset de sala
	var room: RoomData = RoomData.new()
	room.preset_id = "room_square"
	room.description = "Sala Quadrada"
	room.type = Types.TargetType.ROOM
	
	var exit3: ExitData = ExitData.new()
	exit3.exit_name = "North"
	# North exit: position at -Z, facing -Z (forward/outward)
	exit3.local_transform = Transform3D(Basis.IDENTITY, Vector3(0, 0, -10))
	exit3.target_type = Types.TargetType.CORRIDOR
	room.exits.append(exit3)
	
	var exit4: ExitData = ExitData.new()
	exit4.exit_name = "East"
	# East exit: position at +X, facing +X (right/outward)
	# Rotate -90° (or +270°) so forward (-Z) points to +X
	var east_basis: Basis = Basis(Vector3.UP, -PI / 2.0)
	exit4.local_transform = Transform3D(east_basis, Vector3(10, 0, 0))
	exit4.target_type = Types.TargetType.ROOM
	room.exits.append(exit4)
	
	# Adicionar presets
	dungeon_data.rooms_presets.append(corridor)
	dungeon_data.rooms_presets.append(room)
	
	return dungeon_data

func _on_reset_view_pressed():
	# Botão "Reset View" - Reseta zoom e pan
	if visualizer and visualizer.has_method("reset_view"):
		visualizer.reset_view()
		print("[View] Reset zoom and pan")

func _update_visualizer_current_room():
	# Sync current room with visualizer for highlighting
	if visualizer == null or dungeon_manager.dungeon_state.rooms.is_empty():
		return
	
	if current_room_index < dungeon_manager.dungeon_state.rooms.size():
		var room: RoomState = dungeon_manager.dungeon_state.rooms[current_room_index]
		visualizer.current_room_uuid = room.uuid
