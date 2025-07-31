extends Node2D
class_name LoopDrawer

const CLOSE_LOOP_DISTANCE: float = 30.0
const MIN_DISTANCE_BETWEEN_POINTS: float = 5.0

var completed_lines: Array[Line2D] = []

@onready var current_line: Line2D = $CurrentLine

var _drawing: bool = false
var _can_close_loop: bool = false

func _ready():
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drawing(event.position)
			else:
				_stop_drawing()
	
	elif event is InputEventMouseMotion and _drawing:
		_add_point_to_line(event.position)
		_can_close_loop = current_line.points.size() > 2 and current_line.points[0].distance_to(event.position) < CLOSE_LOOP_DISTANCE

func _process(_delta):
	if _can_close_loop:
		current_line.modulate = Color(1, 0, 0, 0.5) # Highlight current line in red
	else:
		current_line.modulate = Color(1, 1, 1, 0.5) # Normal color

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

func _stop_drawing():
	if not _drawing:
		return
	_drawing = false
	
	if current_line.points.size() > 1:
		var line = current_line.duplicate()
		add_child(line)
		completed_lines.append(line)
		if _can_close_loop:
			line.add_point(current_line.points[0]) # Close the loop
	
	current_line.clear_points()
	_can_close_loop = false


func clear_all_lines():
	completed_lines.clear()
	current_line.clear_points()
