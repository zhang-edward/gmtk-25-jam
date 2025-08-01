extends Node2D

@export var guy_scene: PackedScene
@export var city_scene: PackedScene
@export var map_size: Rect2 = Rect2(-400, -300, 800, 600)
@export var min_distance: float = 80.0
@export var guy_ratio: float = 0.6

@onready var loop_drawer = $LoopDrawer

func _ready():
	# Create some example objects that can be skewered
	spawn_entities()

func spawn_entities():
	# Use Poisson disk sampling to distribute guys and cities evenly
	var distributed_points: Array[Vector2] = PoissonDiskSampling.distribute_points(map_size, min_distance)

	for i in range(distributed_points.size()):
		if i < int(distributed_points.size() * guy_ratio):
			# Spawn guys
			var guy_instance = guy_scene.instantiate()
			guy_instance.position = distributed_points[i]
			add_child(guy_instance)
		else:
			# Spawn cities
			if city_scene:
				var city_instance = city_scene.instantiate()
				city_instance.position = distributed_points[i]
				add_child(city_instance)

func _on_clear_button_pressed():
	loop_drawer.clear_all_lines()
