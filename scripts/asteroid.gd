class_name Asteroid
extends Node2D

@onready var sprite = $Sprite2D as Sprite2D
var top_screen

func _ready() -> void:
	hide()

func spawn_from_direction(dir: TopScreen.AsteroidDirection):
	var spaceship_pos = top_screen.spaceship.global_position
	var top_left_pos = top_screen.top_left_pos
	var start_pos
	var end_pos
	match dir:
		TopScreen.AsteroidDirection.N:
			start_pos = Vector2(top_left_pos.x + TopScreen.VIEWPORT_WIDTH / 2.0, top_left_pos.y)
			end_pos = Vector2(spaceship_pos.x, spaceship_pos.y - 25)
		TopScreen.AsteroidDirection.S:
			start_pos = Vector2(top_left_pos.x + TopScreen.VIEWPORT_WIDTH / 2.0, top_left_pos.y + TopScreen.VIEWPORT_HEIGHT)
			end_pos = Vector2(spaceship_pos.x, spaceship_pos.y + 25)
		TopScreen.AsteroidDirection.E:
			start_pos = Vector2(top_left_pos.x, top_left_pos.y + TopScreen.VIEWPORT_HEIGHT / 2.0)
			end_pos = Vector2(spaceship_pos.x - 25, spaceship_pos.y)
		TopScreen.AsteroidDirection.W:
			start_pos = Vector2(top_left_pos.x + TopScreen.VIEWPORT_WIDTH, top_left_pos.y + TopScreen.VIEWPORT_HEIGHT / 2.0)
			end_pos = Vector2(spaceship_pos.x + 25, spaceship_pos.y)
	sprite.global_position = start_pos
	show()
	var tween = create_tween()
	tween.tween_property(sprite, "global_position", end_pos, 4)
	var on_collide = func _on_collide():
		top_screen.handle_asteroid_collision()
		queue_free()
	tween.finished.connect(on_collide)
