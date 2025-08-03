class_name Projectile
extends Node2D

@onready var area_2d = $Area2D
var fire_tween: Tween

func fire_towards(target: Vector2):
	var direction = target - global_position
	rotation = direction.angle()
	fire_tween = create_tween()
	fire_tween.tween_property(self, "global_position", target, 0.5)
	area_2d.area_entered.connect(on_area_entered)

func on_area_entered(other_area: Area2D):
	if other_area.get_parent() is Shield:
		var shield = other_area.get_parent() as Shield
		shield.take_damage(25)
		queue_free()
	elif other_area.get_parent() is Spaceship:
		var spaceship = other_area.get_parent() as Spaceship
		spaceship.take_damage(2)
		queue_free()
	elif other_area.get_parent() is EnemyShip:
		var enemy_ship = other_area.get_parent() as EnemyShip
		enemy_ship.take_damage(50)
		queue_free()