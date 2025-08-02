class_name Projectile
extends Node2D

signal on_hit

func fire_towards(target: Vector2):
	var direction = target - global_position
	rotation = direction.angle()
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, 0.5)
	tween.finished.connect(on_hit_target)

func on_hit_target():
	on_hit.emit()
	queue_free()
	
