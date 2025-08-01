class_name Spaceship
extends Node2D

@onready var sprite = $ShipSprite as Sprite2D
@onready var nw_shield = $NWShield as Shield
@onready var sw_shield = $SWShield as Shield
@onready var ne_shield = $NEShield as Shield
@onready var se_shield = $SEShield as Shield

@onready var nw_turret = $NWTurret as Turret
@onready var sw_turret = $SWTurret as Turret
@onready var ne_turret = $NETurret as Turret
@onready var se_turret = $SETurret as Turret

@export var top_screen_ref: TopScreen

var shield_to_area_map = [null, null, null, null]
var turret_to_area_map = [null, null, null, null]

func _ready() -> void:
	shield_to_area_map[ShipManager.ShipPartDirection.NE] = ne_shield
	shield_to_area_map[ShipManager.ShipPartDirection.NW] = nw_shield
	shield_to_area_map[ShipManager.ShipPartDirection.SE] = se_shield
	shield_to_area_map[ShipManager.ShipPartDirection.SW] = sw_shield
	for shield in shield_to_area_map:
		shield.deactivate()

	turret_to_area_map[ShipManager.ShipPartDirection.NE] = ne_turret
	turret_to_area_map[ShipManager.ShipPartDirection.NW] = nw_turret
	turret_to_area_map[ShipManager.ShipPartDirection.SE] = se_turret
	turret_to_area_map[ShipManager.ShipPartDirection.SW] = sw_turret

func set_shield_state(shield_activation_arr):
	for i in range(0, shield_activation_arr.size()):
		if shield_activation_arr[i]:
			shield_to_area_map[i].activate()
		else:
			shield_to_area_map[i].deactivate()

func set_turret_firing_state(turret_activation_arr):
	for i in range(0, turret_activation_arr.size()):
		var turret = turret_to_area_map[i] as Turret
		turret.toggle_fire(turret_activation_arr[i])

func take_damage(damage: int):
	top_screen_ref.healthbar.value -= damage
