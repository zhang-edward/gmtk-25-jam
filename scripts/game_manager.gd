extends Node2D

@onready var loop_drawer = $LoopDrawer

func _ready():
	# Create some example objects that can be skewered
	pass

func _on_clear_button_pressed():
	loop_drawer.clear_all_lines()
