class_name Turret
extends Node2D

@export var projectile_scene: PackedScene
@export var direction: TopScreen.EnemyShipDirection
@export var shoot_sound: AudioStream
@export var laser_animation: SpriteFrames

@onready var sprite = $TurretSprite as Sprite2D

var is_firing = false
var fire_timer: Timer

var _turret_target_rotation: float = 0.0

func _ready() -> void:
	fire_timer = Timer.new()
	fire_timer.wait_time = 1
	fire_timer.timeout.connect(fire_laser)
	add_child(fire_timer)

func _process(_delta: float) -> void:
	sprite.rotation = lerp_angle(sprite.rotation, _turret_target_rotation, 0.2)

	if !is_firing:
		_turret_target_rotation = Vector2.RIGHT.angle()

func toggle_fire(toggle_state):
	is_firing = toggle_state
	if is_firing:
		fire_timer.start()
	else:
		fire_timer.stop()

func fire_laser():
	var target_ship = get_target()
	if target_ship != null:
		_turret_target_rotation = sprite.global_position.angle_to_point(target_ship.global_position)
		var projectile = projectile_scene.instantiate() as Projectile
		projectile.position = sprite.position + (Vector2.RIGHT.rotated(_turret_target_rotation) * 10)
		projectile.get_node("Sprite2D").frames = laser_animation
		add_child(projectile)
		# Prevent hitting own shields
		(projectile.area_2d as Area2D).set_collision_mask_value(1, false)
		(projectile.area_2d as Area2D).set_collision_mask_value(4, false)
		projectile.fire_towards(target_ship.global_position, 0.2)

		# Play shooting sound
		var audio_player = get_parent().get_node("AudioStreamPlayer2D") as AudioStreamPlayer2D
		audio_player.stream = shoot_sound
		audio_player.play()

func get_target() -> EnemyShip:
	var spaceship = get_parent() as Spaceship
	var top_screen_ref = spaceship.top_screen_ref
	if top_screen_ref != null and top_screen_ref.ships_to_direction.has(direction):
		var target_ship = top_screen_ref.ships_to_direction[direction]
		return target_ship if is_instance_valid(target_ship) else null
	return null
