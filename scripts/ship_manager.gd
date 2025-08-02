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

@onready var _loop_drawer: LoopDrawer = $LoopDrawer
@onready var _power: StaticBody2D = %Power

var _ship_parts: Array[ShipPart] = []
var _mouse_inside_power: bool = false

func _ready() -> void:
	# Initialize ship parts
	for child in get_children():
		if child is not ShipPart:
			continue
		var ship_part = child as ShipPart

		_ship_parts.append(ship_part)

		# Connect ship part signal to loop drawer
		ship_part.mouse_entered.connect(func(): _loop_drawer.on_mouse_entered_ship_part(ship_part))
		print("Initialized ship part: ", ship_part.name)

	_loop_drawer.loop_closed.connect(on_loop_closed)

	# Connect power signals
	_power.input_pickable = true
	_power.mouse_entered.connect(mouse_entered_power_area)
	_power.mouse_exited.connect(mouse_exited_power_area)

func _input(event):
	var mouse_pos = get_global_mouse_position()
	if event is InputEventMouseButton:
		# Only handle input if mouse is inside the power area
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed && _mouse_inside_power:
					_loop_drawer.start_drawing(mouse_pos)
			elif event.is_released():
				_loop_drawer.stop_drawing()
				
func _process(_delta: float) -> void:
	# Highlight ship parts based on their powered state
	for ship_part in _ship_parts:
		if ship_part.ship_part_type == ShipPart.ShipPartType.SHIELD and shield_powered[ship_part.direction] or \
		   ship_part.ship_part_type == ShipPart.ShipPartType.TURRET and turret_powered[ship_part.direction]:
			ship_part.set_powered(true)
		else:
			ship_part.set_powered(false)

func on_loop_closed(powered_ship_parts: Array[ShipPart]) -> void:
	if powered_ship_parts.size() > MAX_POWERED_PARTS || !_mouse_inside_power:
		_loop_drawer.reset_current_line()
		return
	else:
		reset_all_power()
		for ship_part in powered_ship_parts:
			on_ship_part_powered(ship_part)
		ship_status_changed.emit()
		_loop_drawer.confirm_loop()
			
func on_ship_part_powered(ship_part: ShipPart) -> void:
	if ship_part.ship_part_type == ShipPart.ShipPartType.SHIELD:
		print("Shield part powered: ", ship_part.direction)
		shield_powered[ship_part.direction] = true
	elif ship_part.ship_part_type == ShipPart.ShipPartType.TURRET:
		print("Turret part powered: ", ship_part.direction)
		turret_powered[ship_part.direction] = true

func reset_all_power() -> void:
	for i in range(shield_powered.size()):
		shield_powered[i] = false
	for i in range(turret_powered.size()):
		turret_powered[i] = false
	print("All systems powered off")
	ship_status_changed.emit()

func mouse_entered_power_area() -> void:
	_mouse_inside_power = true
	if _loop_drawer.drawing:
		_loop_drawer.can_close_loop = true

func mouse_exited_power_area() -> void:
	_mouse_inside_power = false
