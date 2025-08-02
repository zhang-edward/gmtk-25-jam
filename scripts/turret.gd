class_name Turret
extends Node2D

@export var projectile_scene: PackedScene
@export var direction: TopScreen.EnemyShipDirection

var is_firing = false
var fire_timer: Timer

func _ready() -> void:
	fire_timer = Timer.new()
	fire_timer.wait_time = 1
	fire_timer.timeout.connect(fire_laser)
	add_child(fire_timer)

func toggle_fire(toggle_state):
	is_firing = toggle_state
	if is_firing:
		fire_timer.start()
	else:
		fire_timer.stop()

func fire_laser():
	var target_ship = get_target()
	if target_ship != null:
		var projectile = projectile_scene.instantiate() as Projectile
		add_child(projectile)
		# Prevent hitting own shields
		(projectile.area_2d as Area2D).set_collision_mask_value(1, false)
		(projectile.area_2d as Area2D).set_collision_mask_value(4, false)
		projectile.fire_towards(target_ship.global_position)

func get_target() -> EnemyShip:
	var spaceship = get_parent() as Spaceship
	var top_screen_ref = spaceship.top_screen_ref
	if top_screen_ref != null and top_screen_ref.ships_to_direction.has(direction):
		var target_ship = top_screen_ref.ships_to_direction[direction]
		return target_ship if is_instance_valid(target_ship) else null
	return null
