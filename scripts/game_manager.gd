class_name GameManager
extends Node2D

@onready var ship_manager = $ShipManager as ShipManager
@onready var top_screen = $TopScreen as TopScreen

@onready var spawn_asteroid_w_button = $SpawnAsteroidW as Button
@onready var spawn_asteroid_e_button = $SpawnAsteroidE as Button

func _ready() -> void:
	var callable1 = Callable(top_screen, "generate_asteroid_from_dir").bind(TopScreen.AsteroidDirection.E)
	var callable2 = Callable(top_screen, "generate_asteroid_from_dir").bind(TopScreen.AsteroidDirection.W)

	spawn_asteroid_e_button.pressed.connect(callable1)
	spawn_asteroid_w_button.pressed.connect(callable2)