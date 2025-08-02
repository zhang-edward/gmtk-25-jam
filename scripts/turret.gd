class_name Turret
extends Node2D

@export var projectile_scene: PackedScene
@export var direction: TopScreen.EnemyShipDirection

var is_firing = false
var fire_timer: Timer

func toggle_fire(toggle_state):
	is_firing = toggle_state
	if is_firing:
		fire_laser()
	else:
		if fire_timer != null:
			fire_timer.queue_free()

func fire_laser():
	if fire_timer != null:
		fire_timer.queue_free()
	var target_ship = get_target()
	if target_ship != null:
		var projectile = projectile_scene.instantiate() as Projectile
		add_child(projectile)
		projectile.fire_towards(target_ship.global_position)
		projectile.on_hit.connect(damage_target)
		fire_timer = Timer.new()
		fire_timer.wait_time = 1
		fire_timer.autostart = true
		fire_timer.one_shot = true
		fire_timer.timeout.connect(fire_laser)
		add_child(fire_timer)

func damage_target():
	var target_ship = get_target()
	target_ship.take_damage(40)

func get_target() -> EnemyShip:
	var spaceship = get_parent() as Spaceship
	var top_screen_ref = spaceship.top_screen_ref
	if top_screen_ref.ships_to_direction.has(direction):
		var target_ship = top_screen_ref.ships_to_direction[direction]
		return target_ship if is_instance_valid(target_ship) else null
	return null
