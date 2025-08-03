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

@export var ship_engine_stop_sound: AudioStream
@export var ship_engine_start_sound: AudioStream

var shield_to_area_map = [null, null, null, null]
var turret_to_area_map = [null, null, null, null]

func _ready() -> void:
	var initial_position = position
	
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

	top_screen_ref.ship_manager.ship_status_changed.connect(on_ship_status_changed)

	# Parallel bobbing tweens for X and Y
	var tween_x = create_tween()
	tween_x.set_ease(Tween.EASE_IN_OUT)
	tween_x.set_trans(Tween.TRANS_QUAD)
	tween_x.set_loops()
	tween_x.tween_method(func(x): position.x = initial_position.x + x, -6.0, 6.0, 2.5)
	tween_x.tween_method(func(x): position.x = initial_position.x + x, 6.0, -6.0, 2.5)
	
	var tween_y = create_tween()
	tween_y.set_ease(Tween.EASE_IN_OUT)
	tween_y.set_trans(Tween.TRANS_QUAD)
	tween_y.set_loops()
	tween_y.tween_method(func(y): position.y = initial_position.y + y, 2.0, -2.0, 3.0)
	tween_y.tween_method(func(y): position.y = initial_position.y + y, -2.0, 2.0, 3.0)


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
	if top_screen_ref.healthbar.value == 0:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _process(_delta: float) -> void:
	$FlameParticles.emitting = top_screen_ref.ship_manager.engine_powered
	$FlameParticles2.emitting = top_screen_ref.ship_manager.engine_powered

func on_ship_status_changed():
	# Update engine sound based on the ship's engine state
	var engine_powered = top_screen_ref.ship_manager.engine_powered
	if engine_powered and not $ShipEngineAudioPlayer.playing:
		print("Starting engine sound")
		$ShipAudioPlayer.stream = ship_engine_start_sound
		$ShipAudioPlayer.play()
	elif not engine_powered and $ShipEngineAudioPlayer.playing:
		print("Stopping engine sound")
		$ShipAudioPlayer.stream = ship_engine_stop_sound
		$ShipAudioPlayer.play()

	$ShipEngineAudioPlayer.playing = top_screen_ref.ship_manager.engine_powered
