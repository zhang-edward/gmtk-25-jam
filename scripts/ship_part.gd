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

func highlight(on: bool) -> void:
	if on:
		modulate = Color(1, 1, 0, 1) # Yellow highlight
	else:
		modulate = Color(1, 1, 1, 1) # Default