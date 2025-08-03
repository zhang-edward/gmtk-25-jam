class_name Asteroid
extends Node2D

@export var textures: Array[Texture2D]
@onready var sprite = $Sprite2D as Sprite2D
@onready var area_2d = $Area2D as Area2D
var top_screen: TopScreen
var tween_pos: Tween
var curr_direction

func _ready() -> void:
	hide()
	area_2d.area_entered.connect(on_area_entered)

func spawn_from_direction(dir: TopScreen.AsteroidDirection):
	sprite.texture = textures.pick_random()
	curr_direction = dir
	var spaceship_pos = top_screen.spaceship.global_position
	var top_left_pos = top_screen.top_left_pos
	var start_pos
	var end_pos
	match dir:
		TopScreen.AsteroidDirection.N:
			start_pos = Vector2(top_left_pos.x + TopScreen.VIEWPORT_WIDTH / 2.0, top_left_pos.y) + Vector2(randf_range(-50, 50), -20)
			end_pos = Vector2(spaceship_pos.x, spaceship_pos.y - 25)
		TopScreen.AsteroidDirection.S:
			start_pos = Vector2(top_left_pos.x + TopScreen.VIEWPORT_WIDTH / 2.0, top_left_pos.y + TopScreen.VIEWPORT_HEIGHT) + Vector2(randf_range(-20, 20), 20)
			end_pos = Vector2(spaceship_pos.x, spaceship_pos.y + 25)
		TopScreen.AsteroidDirection.E:
			start_pos = Vector2(top_left_pos.x + TopScreen.VIEWPORT_WIDTH, top_left_pos.y + TopScreen.VIEWPORT_HEIGHT / 2.0) + Vector2(20, randf_range(-20, 20))
			end_pos = Vector2(spaceship_pos.x + 25, spaceship_pos.y)
		TopScreen.AsteroidDirection.W:
			start_pos = Vector2(top_left_pos.x, top_left_pos.y + TopScreen.VIEWPORT_HEIGHT / 2.0) + Vector2(-20, randf_range(-20, 20))
			end_pos = Vector2(spaceship_pos.x - 25, spaceship_pos.y)
	global_position = start_pos
	show()
	tween_pos = create_tween()
	tween_pos.tween_property(self, "global_position", end_pos, randi_range(10, 20))
	
	var rotation_tween = create_tween()
	rotation_tween.set_loops()
	var rotation_speed = randf_range(0.5, 3.0)
	rotation_tween.tween_method(func(angle): sprite.rotation = angle, 0.0, TAU, rotation_speed)

	
func on_area_entered(other_area: Area2D):
	if other_area.get_parent() is Shield:
		if are_required_shields_activated():
			print("Asteroid deflected!")
			queue_free()
	elif other_area.get_parent() is Spaceship:
		var spaceship = other_area.get_parent() as Spaceship
		spaceship.take_damage(25)
		queue_free()

func are_required_shields_activated():
	var shield_arr = top_screen.ship_manager.shield_powered
	match curr_direction:
		TopScreen.AsteroidDirection.N:
			return shield_arr[ShipManager.ShipPartDirection.NE] and shield_arr[ShipManager.ShipPartDirection.NW]
		TopScreen.AsteroidDirection.S:
			return shield_arr[ShipManager.ShipPartDirection.SE] and shield_arr[ShipManager.ShipPartDirection.SW]
		TopScreen.AsteroidDirection.W:
			return shield_arr[ShipManager.ShipPartDirection.NW] and shield_arr[ShipManager.ShipPartDirection.SW]
		TopScreen.AsteroidDirection.E:
			return shield_arr[ShipManager.ShipPartDirection.NE] and shield_arr[ShipManager.ShipPartDirection.SE]
