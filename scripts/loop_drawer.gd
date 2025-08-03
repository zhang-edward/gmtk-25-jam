extends Node2D
class_name LoopDrawer

signal loop_closed(ship_parts: Array[PhysicsBody2D])

const CLOSE_LOOP_DISTANCE: float = 30.0
const MIN_DISTANCE_BETWEEN_POINTS: float = 4.0

var can_close_loop: bool = false
var drawing: bool = false

@onready var current_line: Line2D = $CurrentLine
@onready var plug_sprite: Sprite2D = $PlugSprite

var _completed_line: Line2D
var _ship_parts: Array[ShipPart] = []
var _wire_end_texture: Texture2D = preload("res://sprites/wire_hole.png")

func _ready():
	plug_sprite.visible = false

func _input(event):
	var mouse_pos = get_global_mouse_position()
	if event is InputEventMouseMotion and drawing:
		_add_point_to_line(mouse_pos)

func _process(_delta):
	if _ship_parts.size() > ShipManager.MAX_POWERED_PARTS:
		for ship_part in _ship_parts:
			ship_part.modulate = Color(1, 0, 0, 1) # Red highlight for too many parts
	elif can_close_loop:
		current_line.modulate = Color(1, 1, 0, 1)
	else:
		current_line.modulate = Color(1, 1, 1, 1)

	plug_sprite.position = get_global_mouse_position()

func start_drawing(pos: Vector2):
	drawing = true
	reset_current_line()
	current_line.add_point(pos)
	if _completed_line != null:
		_completed_line.modulate = Color(1, 1, 1, 0.5)
	
	plug_sprite.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	var wire_end = Sprite2D.new()
	wire_end.texture = _wire_end_texture
	wire_end.position = pos
	wire_end.z_index = 1
	wire_end.name = "WireStart"
	current_line.add_child(wire_end)

func _add_point_to_line(pos: Vector2):
	if current_line.points.size() > 0:
		var last_point = current_line.points[-1]

		# Only add point if it's far enough from the last one (reduces noise)
		if last_point.distance_to(pos) > MIN_DISTANCE_BETWEEN_POINTS:
			current_line.add_point(pos)
			queue_redraw()
			plug_sprite.rotation = (pos - last_point).angle()

func stop_drawing():
	if not drawing:
		return
	drawing = false

	loop_closed.emit(_ship_parts)

	can_close_loop = false
	plug_sprite.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func reset_current_line():
	current_line.clear_points()
	plug_sprite.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if current_line.has_node("WireStart"):
		current_line.get_node("WireStart").queue_free()

	for ship_part in _ship_parts:
		ship_part.set_highlight(false)
	_ship_parts.clear()


func on_mouse_entered_ship_part(ship_part: ShipPart):
	if not drawing or ship_part in _ship_parts:
		return
	ship_part.set_highlight(true)
	_ship_parts.append(ship_part)

func confirm_loop():
	# Erase previous completed line
	if _completed_line:
		_completed_line.queue_free()

	_completed_line = current_line.duplicate()
	add_child(_completed_line)
	reset_current_line()

	var wire_end = Sprite2D.new()
	wire_end.texture = _wire_end_texture
	wire_end.position = _completed_line.points[-1]
	wire_end.z_index = 1
	_completed_line.add_child(wire_end)

func erase_all_lines():
	if _completed_line:
		_completed_line.queue_free()
	reset_current_line()
