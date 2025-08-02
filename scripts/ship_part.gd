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

func highlight(color: Color) -> void:
	modulate = color