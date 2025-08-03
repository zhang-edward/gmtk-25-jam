extends Button

func _ready() -> void:
	pressed.connect(_on_restart_button_pressed)

func _on_restart_button_pressed() -> void:
	PlayerVariables.score = 0
	get_tree().change_scene_to_file("res://scenes/main.tscn")
