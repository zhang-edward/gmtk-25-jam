class_name PowerShipPart
extends StaticBody2D

@onready var highlight_rect = $HighlightRect

var power_left: int = 0
var power_sprites: Array = []

func _ready():
	highlight_rect.visible = false
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	power_sprites.append($PowerIcon1)
	power_sprites.append($PowerIcon2)
	power_sprites.append($PowerIcon3)

func set_power(power: int):
	power_left = power
	update_power_sprites()

func update_power_sprites():
	for i in range(power_left):
		power_sprites[i].modulate = Color(1, 1, 0, 1)

	for i in range(power_left, power_sprites.size()):
		power_sprites[i].modulate = Color(0, 0, 0, 1)

func _on_mouse_entered():
	highlight_rect.visible = true

func _on_mouse_exited():
	highlight_rect.visible = false
