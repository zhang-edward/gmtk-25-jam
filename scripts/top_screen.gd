class_name TopScreen
extends Node2D

enum EnemyShipDirection { NW, NE, SW, SE }
enum AsteroidDirection { N, S, E, W }

@onready var spaceship_sprite = $Spaceship as Sprite2D
@onready var healthbar = $Healthbar as ProgressBar
@export var spawn_interval_sec := 5
@export var enemy_ship_scene: PackedScene
@export var asteroid_scene: PackedScene

var ships_to_direction = {}

func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = spawn_interval_sec
	timer.autostart = true
	timer.timeout.connect(generate_random_event)
	add_child(timer)
	healthbar.value = 100

func generate_random_event():
	var rand_num = randi_range(0, 1)
	if rand_num == 0:
		generate_enemy_ship()
	else:
		generate_asteroid()

func generate_enemy_ship():
	var directions_to_spawn = EnemyShipDirection.values().filter(func (dir): return !ships_to_direction.has(dir))
	if !directions_to_spawn.is_empty():
		var rand_direction = directions_to_spawn.pick_random()
		ships_to_direction[rand_direction] = []
		var enemy_ship = enemy_ship_scene.instantiate() as EnemyShip
		add_child(enemy_ship)
		enemy_ship.spawn_from_direction(rand_direction)
		ships_to_direction[rand_direction].append(enemy_ship)

func generate_asteroid():
	var rand_direction = AsteroidDirection.values().pick_random()
	var asteroid = asteroid_scene.instantiate() as Asteroid
	add_child(asteroid)
	asteroid.spawn_from_direction(rand_direction)

func handle_asteroid_collision():
	pass

func handle_enemy_laser_hit():
	pass
