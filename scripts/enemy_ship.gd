class_name EnemyShip
extends Node2D

@export var projectile_scene: PackedScene
@export var textures: Array[Texture2D]
@export var laser_animation: SpriteFrames
@export var explosion_animation: SpriteFrames
@export var explosion_sound: AudioStream

@onready var sprite = $Sprite2D as Sprite2D
@onready var turret_sprite = %TurretSprite as Sprite2D
@onready var health_bar = $Healthbar as ProgressBar

var firing_timer
var top_screen: TopScreen
var direction: TopScreen.EnemyShipDirection

var _turret_target_rotation: float = 0.0

var effect_scene: PackedScene = preload("res://core/effect.tscn")

func _ready() -> void:
	hide()
	health_bar.value = 100

func _process(_delta: float) -> void:
	turret_sprite.rotation = lerp_angle(turret_sprite.rotation, _turret_target_rotation, 0.2)

func spawn_from_direction(_direction: TopScreen.EnemyShipDirection):
	sprite.texture = textures.pick_random()

	direction = _direction
	var top_left_pos = top_screen.top_left_pos
	var start_pos
	var end_pos
	match _direction:
		TopScreen.EnemyShipDirection.NW:
			start_pos = Vector2(top_left_pos.x, top_left_pos.y) + Vector2(randf_range(0, -20), randf_range(0, -20))
			end_pos = Vector2(start_pos.x + 50, start_pos.y + 30)
		TopScreen.EnemyShipDirection.NE:
			start_pos = Vector2(top_left_pos.x + TopScreen.VIEWPORT_WIDTH, top_left_pos.y) + Vector2(randf_range(0, 20), randf_range(0, -20))
			end_pos = Vector2(start_pos.x - 50, top_left_pos.y + 30)
		TopScreen.EnemyShipDirection.SW:
			start_pos = Vector2(top_left_pos.x, top_left_pos.y + TopScreen.VIEWPORT_HEIGHT) + Vector2(randf_range(0, -20), randf_range(0, 20))
			end_pos = Vector2(start_pos.x + 50, start_pos.y - 30)
		TopScreen.EnemyShipDirection.SE:
			start_pos = Vector2(top_left_pos.x + TopScreen.VIEWPORT_WIDTH, top_left_pos.y + TopScreen.VIEWPORT_HEIGHT) + Vector2(randf_range(0, 20), randf_range(0, 20))
			end_pos = Vector2(start_pos.x - 50, start_pos.y - 30)
	global_position = start_pos
	show()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", end_pos, 5)
	tween.finished.connect(fire_laser)

	_bob_tween()

func fire_laser():
	if firing_timer != null:
		firing_timer.queue_free()
	var projectile = projectile_scene.instantiate() as Projectile
	projectile.get_node("Sprite2D").frames = laser_animation
	top_screen.add_child(projectile)
	(projectile.area_2d as Area2D).set_collision_mask_value(5, false)
	projectile.global_position = Vector2(global_position.x, global_position.y)
	projectile.fire_towards(top_screen.spaceship.global_position)
	firing_timer = Timer.new()
	firing_timer.autostart = true
	firing_timer.wait_time = randi_range(10, 15) / 10.0
	firing_timer.one_shot = true
	firing_timer.timeout.connect(fire_laser)
	add_child(firing_timer)
	_turret_target_rotation = turret_sprite.global_position.angle_to_point(top_screen.spaceship.global_position)
	$AudioStreamPlayer2D.play()

func take_damage(amt: int):
	health_bar.value -= amt
	if health_bar.value == 0:
		top_screen.ships_to_direction.erase(direction)

		var effect = effect_scene.instantiate()
		effect.sprite_frames = explosion_animation
		get_parent().add_child(effect)
		effect.position = position
		effect.play()
		CameraControl.instance.shake_camera(1.0, 0.1)

		top_screen.effects_audio_player.stream = explosion_sound
		top_screen.effects_audio_player.play()

		queue_free()


func _bob_tween():
	var initial_position = sprite.position
	# Parallel bobbing tweens for X and Y
	var tween_x = create_tween()
	tween_x.set_ease(Tween.EASE_IN_OUT)
	tween_x.set_trans(Tween.TRANS_QUAD)
	tween_x.set_loops()
	tween_x.tween_method(func(x): sprite.position.x = initial_position.x + x, -3.0, 3.0, 1.0)
	tween_x.tween_method(func(x): sprite.position.x = initial_position.x + x, 3.0, -3.0, 1.0)
	
	var tween_y = create_tween()
	tween_y.set_ease(Tween.EASE_IN_OUT)
	tween_y.set_trans(Tween.TRANS_QUAD)
	tween_y.set_loops()
	tween_y.tween_method(func(y): sprite.position.y = initial_position.y + y, 1.1, -1.1, 0.7)
	tween_y.tween_method(func(y): sprite.position.y = initial_position.y + y, -1.1, 1.1, 0.7)
