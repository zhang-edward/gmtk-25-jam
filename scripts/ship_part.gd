class_name ShipPart
extends PhysicsBody2D

enum ShipPartType {
	SHIELD,
	TURRET,
	ENGINE,
	LIFE_SUPPORT
}

@export var ship_part_type: ShipPartType
@export var direction: ShipManager.ShipPartDirection

var highlighted: int = 0

func _process(_delta: float) -> void:
	if highlighted == 1:
		modulate = Color(1, 0, 0, 1) # Change color to red
	elif highlighted == 2:
		modulate = Color(0, 1, 0, 1) # Change color to green
	else:
		modulate = Color(1, 1, 1, 1) # Reset color