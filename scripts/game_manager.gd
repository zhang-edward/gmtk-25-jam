extends Node2D

@export var guy_scene: PackedScene
@export var city_scene: PackedScene
@export var map_size: Rect2 = Rect2(-400, -300, 800, 600)
@export var min_distance: float = 80.0
@export var guy_ratio: float = 0.6

@onready var loop_drawer = $LoopDrawer

var _guys: Array[PhysicsBody2D] = []
var _cities: Array[PhysicsBody2D] = []

func _ready():
	spawn_entities()
	loop_drawer.loop_closed.connect(calculate_score)

func spawn_entities():
	# Use Poisson disk sampling to distribute guys and cities evenly
	var distributed_points: Array[Vector2] = PoissonDiskSampling.distribute_points(map_size, min_distance)

	for i in range(distributed_points.size()):
		if i < int(distributed_points.size() * guy_ratio):
			# Spawn guys
			var guy_instance = guy_scene.instantiate() as PhysicsBody2D
			guy_instance.position = distributed_points[i]
			add_child(guy_instance)
			guy_instance.mouse_entered.connect(func(): loop_drawer.on_mouse_entered_guy(guy_instance))
			_guys.append(guy_instance)
		else:
			# Spawn cities
			var city_instance = city_scene.instantiate() as PhysicsBody2D
			city_instance.position = distributed_points[i]
			add_child(city_instance)
			city_instance.mouse_entered.connect(func(): loop_drawer.on_mouse_entered_city(city_instance))
			_cities.append(city_instance)

func _on_clear_button_pressed():
	loop_drawer.clear_all_lines()

func calculate_score(cities: Array[PhysicsBody2D]):
	var score: int = 0
	for city in cities:
		score += 1

	print("Score: ", score, "/", _cities.size())
