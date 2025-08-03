class_name SpaceParticles
extends CPUParticles2D

var initial_velocity_min_param: float
var initial_velocity_max_param: float
var initial_speed_scale: float

var engine_powered: bool = false

func _ready() -> void:
	# Store the initial velocity for later use
	initial_velocity_min_param = initial_velocity_min
	initial_velocity_max_param = initial_velocity_max
	initial_speed_scale = speed_scale

func _process(delta: float) -> void:
	if engine_powered:
		# Increase the initial velocity parameters when the engine is powered
		speed_scale = min(initial_speed_scale, speed_scale + 1 * delta)
	else:
		# Decrease the initial velocity parameters when the engine is not powered
		speed_scale = max(0.5, speed_scale - 1 * delta)
