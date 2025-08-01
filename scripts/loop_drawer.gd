extends Node2D
class_name LoopDrawer

const CLOSE_LOOP_DISTANCE: float = 30.0
const MIN_DISTANCE_BETWEEN_POINTS: float = 2.0

var completed_lines: Array[Line2D] = []

@onready var current_line: Line2D = $CurrentLine

var _drawing: bool = false
var _can_close_loop: bool = false
var _current_line_length: float = 0.0

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
	current_line.clear_points()
	current_line.add_point(pos)

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
		var line = current_line.duplicate()
		add_child(line)
		completed_lines.append(line)

		if _can_close_loop:
			line.add_point(current_line.points[0]) # Close the loop by connecting last point to first
	
	current_line.clear_points()
	_can_close_loop = false


func clear_all_lines():
	for line in completed_lines:
		line.queue_free()
	completed_lines.clear()
	current_line.clear_points()
