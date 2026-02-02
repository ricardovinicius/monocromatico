# Guia de Teste: Sistema de Lazy Loading

## 🎯 Como Testar

### Opção 1: Teste por Console (Mais Rápido)

1. **Criar cena de teste:**
   - No Godot, crie uma nova cena com um `Node` raiz
   - Salve como `test_lazy_loading.tscn`

2. **Anexar o script:**
   - Selecione o Node raiz
   - Arraste `pcg_dungeon/debug/test_lazy_loading.gd` para ele
   - Rode a cena (F6)

3. **Ver output:**
   - Abra o console (Output)
   - Você verá a progressão da geração lazy

**Saída esperada:**
```
=== INITIALIZING DUNGEON ===
=== INITIAL STATE ===
Total rooms: 1
Starting room: dungeon-12345-...

=== EXPANDING STARTING ROOM ===
[Lazy Load] Generated room room-... from exit 'North' in room dungeon-...
[Lazy Load] Generated room room-... from exit 'South' in room dungeon-...

=== STATE AFTER FIRST EXPANSION ===
Total rooms: 3
...
```

---

### Opção 2: Teste Visual (Recomendado)

1. **Criar cena de teste visual:**
   - Crie nova cena 2D
   - Adicione um `Node2D` chamado "Visualizer"
   - Anexe `pcg_dungeon/debug/dungeon_visualizer.gd`

2. **Adicionar DungeonManager:**
   - Adicione um `Node` filho chamado "DungeonManager"
   - Anexe o script `DungeonManager` a ele
   - No Visualizer, arraste o DungeonManager para o export `dungeon_manager`

3. **Adicionar controles de teste:**
   - Adicione um `Control` > `VBoxContainer`
   - Adicione botões:
     - "Initialize Dungeon"
     - "Expand Current Room"
     - "Go to Next Room"

4. **Script de controle:**

```gdscript
extends VBoxContainer

@export var dungeon_manager: DungeonManager
var current_room_index: int = 0

func _on_initialize_pressed():
    var dungeon_data = _create_test_data()  # Use a função do test_lazy_loading.gd
    dungeon_manager._init_dungeon(dungeon_data)
    current_room_index = 0

func _on_expand_pressed():
    if dungeon_manager.dungeon_state.rooms.is_empty():
        return
    var room = dungeon_manager.dungeon_state.rooms[current_room_index]
    dungeon_manager.expand_room(room.uuid)

func _on_next_room_pressed():
    current_room_index += 1
    if current_room_index >= dungeon_manager.dungeon_state.rooms.size():
        current_room_index = 0
```

**O que você verá:**
- 🟢 Verde = Sala inicial
- 🔴 Vermelho = Salas normais
- 🔵 Azul = Corredores
- 🟡 Linhas amarelas = Conexões
- 🟢 Círculos verdes = Exits conectadas
- 🔴 Círculos vermelhos = Exits não conectadas

---

## 🧪 Fluxo de Teste Sugerido

### Teste Básico
1. Initialize Dungeon → 1 sala
2. Expand Current Room → 2-4 salas novas
3. Go to Next Room
4. Expand Current Room → Mais salas
5. Repetir até ter ~10 salas

### Teste de Validação
- Verificar se exits sempre têm conexão bidirecional
- Confirmar que não há salas duplicadas
- Checar se posições estão corretas (sem overlap)

---

## 🔍 Debug Tips

### Ver estado atual:
```gdscript
print(dungeon_manager.dungeon_state.rooms.size())  # Quantas salas
```

### Ver exits de uma sala:
```gdscript
var room = dungeon_manager.dungeon_state.rooms[0]
for exit in room.exits:
    print("%s -> %s" % [exit.exit_name, exit.connected_room_uuid])
```

### Forçar expansão de todas as salas:
```gdscript
func expand_all_rooms():
    var rooms_to_expand = dungeon_manager.dungeon_state.rooms.duplicate()
    for room in rooms_to_expand:
        dungeon_manager.expand_room(room.uuid)
```

---

## ⚡ Próximas Melhorias

1. **Detecção de colisão:** Evitar overlap de salas
2. **Limites de geração:** Max depth, max rooms
3. **Controle de densidade:** Probabilidade de gerar salas
4. **Salas especiais:** Boss, treasure baseado em depth
5. **Persistência:** Salvar/carregar estado gerado
