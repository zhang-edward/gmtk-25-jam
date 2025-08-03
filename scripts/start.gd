class_name Start
extends Node2D

@onready var start = $CanvasLayer/Button as Button
@onready var how_to_play = $CanvasLayer/Button2 as Button

func _ready() -> void:
	start.pressed.connect(go_to_game)
	how_to_play.pressed.connect(go_to_tutorial)

func go_to_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func go_to_tutorial():
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")