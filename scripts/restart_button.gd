extends Button

func _ready() -> void:
	pressed.connect(_on_restart_button_pressed)

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
