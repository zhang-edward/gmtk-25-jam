class_name ShipManager
extends Node2D

const MAX_POWERED_PARTS: int = 3

signal ship_status_changed()
signal ship_repaired()

enum ShipPartDirection {
	NW = 0,
	NE = 1,
	SW = 2,
	SE = 3
}

var shield_powered: Array[bool] = [false, false, false, false]
var turret_powered: Array[bool] = [false, false, false, false]
var repair_zones_powered = []
var engine_powered: bool = false

@onready var all_repair_zones = [
	$RepairZone,
	$RepairZone2,
	$RepairZone3,
	$RepairZone4,
	$RepairZone5,
	$RepairZone6,
	$RepairZone7,
	$RepairZone8
]
@onready var _loop_drawer: LoopDrawer = $LoopDrawer
@onready var _power: StaticBody2D = %Power
@export var top_screen: TopScreen

var _ship_parts: Array[ShipPart] = []
var _mouse_inside_power: bool = false
var gen_repair_zone_timer: Timer
var repair_expiry_timer: Timer
var repair_zone_cooldown: Timer

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

	# Create random repair zones
	init_gen_repair_zone_timer()

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
		   ship_part.ship_part_type == ShipPart.ShipPartType.TURRET and turret_powered[ship_part.direction] or \
			 ship_part.ship_part_type == ShipPart.ShipPartType.REPAIR_ZONE and repair_zones_powered.has(ship_part) or \
			 ship_part.ship_part_type == ShipPart.ShipPartType.ENGINE and engine_powered:
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
		if repair_zones_powered.size() == 3:
			handle_self_repair()
		else:
			ship_status_changed.emit()
			_loop_drawer.confirm_loop()
			
func on_ship_part_powered(ship_part: ShipPart) -> void:
	if ship_part.ship_part_type == ShipPart.ShipPartType.SHIELD:
		print("Shield part powered: ", ship_part.direction)
		shield_powered[ship_part.direction] = true
	elif ship_part.ship_part_type == ShipPart.ShipPartType.TURRET:
		print("Turret part powered: ", ship_part.direction)
		turret_powered[ship_part.direction] = true
	elif ship_part.ship_part_type == ShipPart.ShipPartType.REPAIR_ZONE:
		print("Repair Zone powered!")
		repair_zones_powered.append(ship_part)
	elif ship_part.ship_part_type == ShipPart.ShipPartType.ENGINE:
		print("Engine powered!")
		engine_powered = true

func handle_self_repair():
	_loop_drawer.erase_all_lines()
	ship_repaired.emit()
	if repair_expiry_timer != null:
		repair_expiry_timer.stop()
	expire_repair_zones()

func reset_all_power() -> void:
	repair_zones_powered = []
	for i in range(shield_powered.size()):
		shield_powered[i] = false
	for i in range(turret_powered.size()):
		turret_powered[i] = false
	engine_powered = false
	ship_status_changed.emit()

func mouse_entered_power_area() -> void:
	_mouse_inside_power = true
	if _loop_drawer.drawing:
		_loop_drawer.can_close_loop = true

func mouse_exited_power_area() -> void:
	_mouse_inside_power = false

func init_random_repair_zones():
	if top_screen.healthbar.value < top_screen.healthbar.max_value:
		print("Generating repair zones...")
		var repair_zones_to_select = all_repair_zones
		repair_zones_to_select.shuffle()
		for i in range(0, 3):
			repair_zones_to_select[i].show()
		# Repair zones last for limited time
		if repair_expiry_timer != null and is_instance_valid(repair_expiry_timer):
			repair_expiry_timer.queue_free()
		repair_expiry_timer = Timer.new()
		repair_expiry_timer.autostart = true
		repair_expiry_timer.wait_time = 7
		repair_expiry_timer.one_shot = true
		repair_expiry_timer.timeout.connect(expire_repair_zones)
		add_child(repair_expiry_timer)
	else:
		print("Full HP, checking again in 5-8s")
		init_gen_repair_zone_timer()

func expire_repair_zones():
	print("Repair zones expired!")
	repair_zones_powered = []
	for zone in all_repair_zones:
		zone.hide()
	init_gen_repair_zone_timer()

func init_gen_repair_zone_timer():
	if gen_repair_zone_timer != null and is_instance_valid(gen_repair_zone_timer):
		gen_repair_zone_timer.queue_free()
	gen_repair_zone_timer = Timer.new()
	gen_repair_zone_timer.wait_time = randi_range(5, 8)
	gen_repair_zone_timer.autostart = true
	gen_repair_zone_timer.one_shot = true
	gen_repair_zone_timer.timeout.connect(init_random_repair_zones)
	add_child(gen_repair_zone_timer)
