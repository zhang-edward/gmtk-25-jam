class_name TopScreen
extends Node2D

enum EnemyShipDirection {NW, NE, SW, SE}
enum AsteroidDirection {N, S, E, W}
enum Difficulty {
	VERY_EASY,
	EASY,
	NORMAL,
	HARD,
	VERY_HARD
}

@onready var spaceship = $Spaceship as Spaceship
@onready var healthbar = $Healthbar as ProgressBar
@onready var space_particles_fg = $SpaceParticlesFG as SpaceParticles
@onready var space_particles_bg = $SpaceParticlesBG as SpaceParticles
@onready var effects_audio_player = $EffectsAudioPlayer as AudioStreamPlayer2D
@onready var score_label = $Score as RichTextLabel

@export var spawn_interval_sec := 10
@export var enemy_ship_scene: PackedScene
@export var asteroid_scene: PackedScene
@export var ship_manager: ShipManager

var ships_to_direction = {}
var top_left_pos
static var VIEWPORT_WIDTH = 240
static var VIEWPORT_HEIGHT = 160

var black_hole_distance := 1000.0
var score := 0
var difficulty := Difficulty.VERY_EASY
var spawn_timer: Timer

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval_sec
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(generate_random_event)
	add_child(spawn_timer)
	healthbar.value = 100
	top_left_pos = Vector2(position.x, position.y)
	ship_manager.ship_status_changed.connect(on_ship_status_changed)
	ship_manager.ship_repaired.connect(on_ship_repaired)

func generate_random_event():
	print("spawn timer: ", spawn_timer.wait_time)
	var num_events = 1
	if score < 6000:
		num_events = 1
	elif score < 12000:
		num_events = randi_range(1, 2)
	elif score < 24000:
		num_events = randi_range(1, 3)
	else:
		num_events = randi_range(2, 4)

	print("========== generating events: ", num_events)

	for i in range(num_events):
		generate_event()

func generate_event():
	var rand_num = randi_range(0, 1)
	if rand_num == 0:
		generate_enemy_ship()
	elif rand_num == 1:
		generate_asteroid()

func generate_enemy_ship():
	var directions_to_spawn = EnemyShipDirection.values().filter(func(dir): return !ships_to_direction.has(dir))
	if !directions_to_spawn.is_empty():
		var rand_direction = directions_to_spawn.pick_random()
		var enemy_ship = enemy_ship_scene.instantiate() as EnemyShip
		enemy_ship.top_screen = self
		add_child(enemy_ship)
		enemy_ship.spawn_from_direction(rand_direction)
		ships_to_direction[rand_direction] = enemy_ship

func generate_asteroid():
	var rand_direction = AsteroidDirection.values().pick_random()
	var asteroid = asteroid_scene.instantiate() as Asteroid
	asteroid.top_screen = self
	add_child(asteroid)
	asteroid.spawn_from_direction(rand_direction)

func on_ship_status_changed():
	spaceship.set_shield_state(ship_manager.shield_powered)
	spaceship.set_turret_firing_state(ship_manager.turret_powered)

func generate_asteroid_from_dir(dir: AsteroidDirection):
	var asteroid = asteroid_scene.instantiate() as Asteroid
	asteroid.top_screen = self
	add_child(asteroid)
	asteroid.spawn_from_direction(dir)

func on_ship_repaired(num_repair_zones):
	var amt_healed = num_repair_zones * 10
	healthbar.value += amt_healed

func _process(delta):
	if ship_manager.engine_powered:
		black_hole_distance = min(black_hole_distance + delta * 25, 3000.0)
	else:
		black_hole_distance -= delta * 100

	score += delta * 100
	score_label.text = "Score: " + str(score)

	update_difficulty(delta)

	if black_hole_distance < 0:
		black_hole_distance = 0
		CameraControl.instance.shake_camera(3.0, 1)

		# Fade scene to black
		var fade = ColorRect.new()
		fade.color = Color.BLACK
		fade.size = get_viewport().size
		add_child(fade)
		fade.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(fade, "modulate:a", 1.0, 2.0)

		await tween.finished
		PlayerVariables.score = score
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

	space_particles_fg.engine_powered = ship_manager.engine_powered
	space_particles_bg.engine_powered = ship_manager.engine_powered

func update_difficulty(delta: float):
# 	if score <= 2500:
# 		spawn_timer.wait_time = 10
# 	elif score > 5000 and score <= 8000:
# 		spawn_timer.wait_time = 10
# 	elif score > 8000 and score <= 14000:
# 		spawn_timer.wait_time = 9
# 	elif score > 14000 and score <= 30000:
# 		spawn_timer.wait_time = 8
	if score > 40000:
		spawn_timer.wait_time -= 0.01 * delta
