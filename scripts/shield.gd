class_name Shield
extends Node2D

enum CurrShieldState {
	RECHARGE,
	CHARGING,
	ACTIVATED
}

@export var scale_override = Vector2(1, 1)
@onready var health_bar = $Healthbar as ProgressBar
@onready var sprite = $Sprite2D as Sprite2D
@onready var area_2d = $Area2D as Area2D

var curr_shield_state: CurrShieldState = CurrShieldState.CHARGING
var recharge_timer: Timer
var charge_timer: Timer

func _ready() -> void:
	scale = scale_override
	if scale.x < 0:
		health_bar.fill_mode = ProgressBar.FillMode.FILL_END_TO_BEGIN
	health_bar.value = 100
	charge_timer = Timer.new()
	charge_timer.autostart = true
	charge_timer.wait_time = 0.5
	charge_timer.timeout.connect(charge_shield)

func charge_shield():
	if curr_shield_state == CurrShieldState.CHARGING:
		health_bar.value += 25
	
func deactivate():
	hide()
	curr_shield_state = CurrShieldState.CHARGING
	area_2d.collision_layer = 0

func activate():
	if health_bar.value > 0:
		show()
		curr_shield_state = CurrShieldState.ACTIVATED
		area_2d.collision_layer = 1

func take_damage(damage: int):
	health_bar.value -= damage
	if health_bar.value == 0 and curr_shield_state != CurrShieldState.RECHARGE:
		# Forcibly de-activate due to recharge
		curr_shield_state = CurrShieldState.RECHARGE
		hide()
		area_2d.collision_layer = 0
		recharge_timer = Timer.new()
		recharge_timer.autostart = true
		recharge_timer.wait_time = 5
		recharge_timer.one_shot = true
		recharge_timer.timeout.connect(on_recharged)
		add_child(recharge_timer)
		hide()

func on_recharged():
	if recharge_timer != null and is_instance_valid(recharge_timer):
		recharge_timer.queue_free()
	area_2d.collision_layer = 1 # re-enable collision
	health_bar.value = 100
	if curr_shield_state == CurrShieldState.RECHARGE:
		activate()
