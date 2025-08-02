extends Node2D

@export var guy_scene: PackedScene
@export var city_scene: PackedScene
@export var map_size: Rect2 = Rect2(-400, -300, 800, 600)
@export var min_distance: float = 80.0
@export var guy_ratio: float = 0.6

@export var loop_drawer: LoopDrawer

func _ready():
	pass

func _on_clear_button_pressed():
	loop_drawer.clear_all_lines()

func calculate_score(cities: Array[PhysicsBody2D]):
	var score: int = 0
	for city in cities:
		score += 1

	print("Score: ", score, "/", cities.size())
