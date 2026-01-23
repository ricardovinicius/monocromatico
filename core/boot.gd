class_name Boot
extends Control

const MAIN_MENU_PATH: String = "res://ui/menus/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_game()

func _initialize_game() -> void:
	print("[Boot] Starting game initialization...")

	# 1. Load Settings (Volume, Graphics) - Placeholder for now
	# SettingsManager.load_settings() 

	# 2. Wait for a moment (or wait for async loading)
	# This effectively acts as your "Splash Screen" duration
	await get_tree().create_timer(1.0).timeout

	print("[Boot] Initialization complete. Switching to Main Menu.")
	_change_to_menu()

func _change_to_menu() -> void:
	var error: int = get_tree().change_scene_to_file(MAIN_MENU_PATH)
	if error != OK:
		push_error("[Boot] Failed to load Main Menu scene: %s" % MAIN_MENU_PATH)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
