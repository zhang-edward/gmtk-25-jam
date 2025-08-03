class_name ShipPart
extends PhysicsBody2D

enum ShipPartType {
	SHIELD,
	TURRET,
	REPAIR_ZONE,
	ENGINE,
}

@export var ship_part_type: ShipPartType
@export var direction: ShipManager.ShipPartDirection

@onready var power_particles = $PowerParticles as CPUParticles2D

var _powered: bool = false
var _highlighted: bool = false

func _process(_delta: float) -> void:
	if _highlighted:
		modulate = Color(1, 1, 0, 1)
	elif _powered:
		modulate = Color(0, 1, 1, 1)
	else:
		modulate = Color(1, 1, 1, 1) # Default color

func set_highlight(on: bool) -> void:
	_highlighted = on

func set_powered(on: bool) -> void:
	_powered = on
	power_particles.emitting = on
