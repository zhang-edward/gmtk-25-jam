extends Node2D
class_name LoopDrawer

signal loop_closed(_cities: Array[PhysicsBody2D])

const CLOSE_LOOP_DISTANCE: float = 30.0
const MIN_DISTANCE_BETWEEN_POINTS: float = 2.0


@onready var current_line: Line2D = $CurrentLine

var _completed_line: Line2D
var _drawing: bool = false
var _can_close_loop: bool = false
var _current_line_length: float = 0.0

var _ship_parts: Array[ShipPart] = []

func _ready():
	pass

func _input(event):
	var mouse_pos = get_global_mouse_position()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if not _drawing:
				_start_drawing(mouse_pos)
			else:
				_stop_drawing()
	
	elif event is InputEventMouseMotion and _drawing:
		_add_point_to_line(mouse_pos)
		_can_close_loop = _current_line_length > CLOSE_LOOP_DISTANCE * 1.1 and current_line.points[0].distance_to(mouse_pos) < CLOSE_LOOP_DISTANCE

func _process(_delta):
	if _can_close_loop:
		current_line.modulate = Color(1, 0, 0, 1)
	else:
		current_line.modulate = Color(1, 1, 1, 1)

func _start_drawing(pos: Vector2):
	_drawing = true
	reset_current_line()
	current_line.add_point(pos)

	if _completed_line != null:
		_completed_line.modulate = Color(1, 1, 1, 0.5)

func _add_point_to_line(pos: Vector2):
	if current_line.points.size() > 0:
		var last_point = current_line.points[-1]

		# Only add point if it's far enough from the last one (reduces noise)
		if last_point.distance_to(pos) > MIN_DISTANCE_BETWEEN_POINTS:
			current_line.add_point(pos)
			queue_redraw()
			_current_line_length += last_point.distance_to(pos)

func _stop_drawing():
	if not _drawing:
		return
	_drawing = false
	_current_line_length = 0.0

	if current_line.points.size() > 1:
		if _can_close_loop:
			current_line.add_point(current_line.points[0]) # Close the loop by connecting last point to first
			loop_closed.emit(_ship_parts)
			# Erase previous completed line
			if _completed_line:
				_completed_line.queue_free()
			_completed_line = current_line.duplicate()
			add_child(_completed_line)
		else:
			print("Loop not closed, points are too far apart.")
			current_line.clear_points()
			_completed_line.modulate = Color(1, 1, 1, 1)
	
	_can_close_loop = false

func clear_all_lines():
	if _completed_line:
		_completed_line.queue_free()
	_completed_line = null
	reset_current_line()

func reset_current_line():
	for ship_part in _ship_parts:
		ship_part.highlighted = 0
	_ship_parts.clear()
	current_line.clear_points()

func on_mouse_entered_ship_part(ship_part: ShipPart):
	if not _drawing:
		return
	print("Ship part skewered: ", ship_part.name)
	ship_part.highlighted = 1
	_ship_parts.append(ship_part)
