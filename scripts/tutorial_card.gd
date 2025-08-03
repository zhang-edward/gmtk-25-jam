class_name TutorialCard
extends Control

@onready var next_button = $Button
@onready var back_button = $Button2

signal on_next
signal on_back

func _ready() -> void:
	next_button.pressed.connect(on_next_press)
	back_button.pressed.connect(on_back_press)

func on_next_press():
	on_next.emit()

func on_back_press():
	on_back.emit()

