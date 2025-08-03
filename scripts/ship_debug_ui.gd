class_name ShipDebugUI
extends Label

@export var ship_manager: ShipManager

func _ready() -> void:
	ship_manager.ship_status_changed.connect(update_debug_text)
	if not ship_manager:
		text = "Ship Manager not found!"
	update_debug_text()

func update_debug_text() -> void:
	print("Updating debug text")
	var debug_text = ""
	
	for i in range(ship_manager.shield_powered.size()):
		debug_text += "Shield %d: %s\n" % [i + 1, "ON" if ship_manager.shield_powered[i] else "OFF"]
	
	for i in range(ship_manager.turret_powered.size()):
		debug_text += "Turret %d: %s\n" % [i + 1, "ON" if ship_manager.turret_powered[i] else "OFF"]
	
	print("Debug text updated: ", debug_text)
	text = debug_text
