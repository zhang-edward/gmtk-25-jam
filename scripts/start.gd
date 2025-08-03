class_name Start
extends Node2D

@onready var button = $CanvasLayer/Button as Button

func _ready() -> void:
	button.pressed.connect(go_to_game)

func go_to_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
