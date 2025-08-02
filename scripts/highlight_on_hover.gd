class_name HighlightOnHover
extends StaticBody2D

@onready var highlight_rect = $HighlightRect

func _ready():
	highlight_rect.visible = false
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	highlight_rect.visible = true
func _on_mouse_exited():
	highlight_rect.visible = false
