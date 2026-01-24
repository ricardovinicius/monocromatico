class_name MainMenu extends Control

const LEVEL_PATH: String = "res://levels/sandbox.tscn"

@onready var start_button: Button = $StartButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
	print("[UI] Start Button Pressed. Changing to Level Scene.")

	GameManager.start_gameplay()

	var error: int = get_tree().change_scene_to_file(LEVEL_PATH)
	if error != OK:
		push_error("[UI] Failed to load Level scene: %s" % LEVEL_PATH)
