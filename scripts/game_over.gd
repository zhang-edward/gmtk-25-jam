class_name GameOver
extends Node2D

@onready var label = $CanvasLayer/Control/Score as Label

func _ready() -> void:
	label.text = "Score: " + str(PlayerVariables.score)

