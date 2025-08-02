class_name Asteroid
extends Node2D

@onready var sprite = $Sprite2D as Sprite2D
@onready var top_screen = get_node("/root/TopScreen") as TopScreen

func _ready() -> void:
	hide()

func spawn_from_direction(dir: TopScreen.AsteroidDirection):
	var spaceship_pos = top_screen.spaceship_sprite.global_position
	var start_dir
	var end_pos
	match dir:
		TopScreen.AsteroidDirection.N:
			start_dir = Vector2(240, 0)
			end_pos = Vector2(spaceship_pos.x, spaceship_pos.y - 50)
		TopScreen.AsteroidDirection.S:
			start_dir = Vector2(240, 320)
			end_pos = Vector2(spaceship_pos.x, spaceship_pos.y + 50)
		TopScreen.AsteroidDirection.E:
			start_dir = Vector2(480, 160)
			end_pos = Vector2(spaceship_pos.x + 50, spaceship_pos.y)
		TopScreen.AsteroidDirection.W:
			start_dir = Vector2(0, 160)
			end_pos = Vector2(spaceship_pos.x - 50, spaceship_pos.y)
	sprite.global_position = start_dir
	show()
	var tween = create_tween()
	tween.tween_property(sprite, "global_position", end_pos, 4)
	var on_collide = func _on_collide():
		top_screen.handle_asteroid_collision()
		queue_free()
	tween.finished.connect(on_collide)

