extends Node

# Signal to tell other nodes (like the UI) that the state changed
signal game_paused(is_paused: bool)

var is_paused: bool = false:
    set(value):
        is_paused = value
        # 1. Actually pause the engine physics/process
        get_tree().paused = is_paused 
        
        # 2. Handle Mouse State
        if is_paused:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            
        # 3. Notify the rest of the game
        game_paused.emit(is_paused)

func _ready() -> void:
    # Ensure this node never pauses, otherwise it can't unpause!
    process_mode = Node.PROCESS_MODE_ALWAYS

# Call this when a playable level loads
func start_gameplay() -> void:
    is_paused = false

func _unhandled_input(event: InputEvent) -> void:
    # "ui_cancel" is bound to the Escape key by default
    if event.is_action_pressed("ui_cancel"):
        # Toggle the boolean, which triggers the setter logic above
        is_paused = !is_paused