class_name ShipManager
extends Node2D

const MAX_POWERED_PARTS: int = 3

signal ship_status_changed()

enum ShipPartDirection {
	NW = 0,
	NE = 1,
	SW = 2,
	SE = 3
}

var shield_powered: Array[bool] = [false, false, false, false]
var turret_powered: Array[bool] = [false, false, false, false]
var engine_powered: bool = false
var life_support_powered: bool = false

@onready var _loop_drawer: LoopDrawer = $LoopDrawer

var _ship_parts: Array[ShipPart] = []

func _ready() -> void:
	# Initialize ship parts
	for child in get_children():
		if child is not ShipPart:
			continue
		var ship_part = child as ShipPart

		_ship_parts.append(ship_part)

		# Connect loop drawer signals
		ship_part.mouse_entered.connect(func(): _loop_drawer.on_mouse_entered_ship_part(ship_part))
		print("Initialized ship part: ", ship_part.name)

	_loop_drawer.loop_closed.connect(on_loop_closed)

func on_loop_closed(powered_ship_parts: Array[ShipPart]) -> void:
	if powered_ship_parts.size() > MAX_POWERED_PARTS:
		_loop_drawer.cancel_loop()
		return
	else:
		_loop_drawer.confirm_loop()
		reset_all_power()
		for ship_part in powered_ship_parts:
			on_ship_part_powered(ship_part)
		ship_status_changed.emit()
			
func on_ship_part_powered(ship_part: ShipPart) -> void:
	if ship_part.ship_part_type == ShipPart.ShipPartType.SHIELD:
		print("Shield part powered: ", ship_part.direction)
		shield_powered[ship_part.direction] = true
	elif ship_part.ship_part_type == ShipPart.ShipPartType.TURRET:
		print("Turret part powered: ", ship_part.direction)
		turret_powered[ship_part.direction] = true
	elif ship_part.ship_part_type == ShipPart.ShipPartType.ENGINE:
		print("Engine part powered")
		engine_powered = true
	elif ship_part.ship_part_type == ShipPart.ShipPartType.LIFE_SUPPORT:
		print("Life support part powered")
		life_support_powered = true

func reset_all_power() -> void:
	engine_powered = false
	life_support_powered = false
	for i in range(shield_powered.size()):
		shield_powered[i] = false
	for i in range(turret_powered.size()):
		turret_powered[i] = false
	print("All systems powered off")
	ship_status_changed.emit()