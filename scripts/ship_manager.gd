class_name ShipManager
extends Node2D

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

# ==== Debug functions for testing
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				toggle_engine_power()
			KEY_2:
				toggle_life_support_power()
			KEY_3:
				toggle_next_shield_power()
			KEY_4:
				toggle_next_turret_power()
			KEY_R:
				reset_all_power()

func toggle_engine_power() -> void:
	engine_powered = !engine_powered
	print("Engine power: ", engine_powered)
	ship_status_changed.emit()

func toggle_life_support_power() -> void:
	life_support_powered = !life_support_powered
	print("Life support power: ", life_support_powered)
	ship_status_changed.emit()

func toggle_next_shield_power() -> void:
	if shield_powered.size() > 0:
		for i in range(shield_powered.size()):
			if not shield_powered[i]:
				shield_powered[i] = true
				print("Shield ", i + 1, " powered on")
				return
		# If all are powered, turn off the first one
		shield_powered[0] = false
		print("Shield 1 powered off")
	ship_status_changed.emit()

func toggle_next_turret_power() -> void:
	if turret_powered.size() > 0:
		for i in range(turret_powered.size()):
			if not turret_powered[i]:
				turret_powered[i] = true
				print("Turret ", i + 1, " powered on")
				return
		# If all are powered, turn off the first one
		turret_powered[0] = false
		print("Turret 1 powered off")
	ship_status_changed.emit()

func reset_all_power() -> void:
	engine_powered = false
	life_support_powered = false
	for i in range(shield_powered.size()):
		shield_powered[i] = false
	for i in range(turret_powered.size()):
		turret_powered[i] = false
	print("All systems powered off")
	ship_status_changed.emit()
