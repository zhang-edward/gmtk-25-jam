class_name CameraControl
extends Camera2D

static var instance: CameraControl

var original_position: Vector2
var shake_tween: Tween

func _ready():
	if instance == null:
		instance = self
	else:
		print("Warning: Multiple instances of CameraControl detected. Using the first instance.")

	original_position = position

func shake_camera(intensity: float = 10.0, duration: float = 0.5):
	if shake_tween:
		shake_tween.kill()
	
	shake_tween = create_tween()
	
	shake_tween.tween_method(
		func(progress):
			var shake_strength = intensity * (1.0 - progress)
			position = original_position + Vector2(
				randf_range(-shake_strength, shake_strength),
				randf_range(-shake_strength, shake_strength)
			),
		0.0, 1.0, duration
	)
	
	shake_tween.tween_callback(func(): position = original_position)
