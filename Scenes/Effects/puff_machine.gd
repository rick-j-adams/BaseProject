extends Node2D

class_name PuffMachine

@export var timeBetweenPuffs : float = 0.05
@export var duration : int = 8

@onready var coolDownTimer : Timer= $CoolDown
@onready var durationTimer : Timer= $Duration

var isOn : bool = false

func createPuffMMachine(setPosition: Vector2, setCooldown: float, setDuration: float) -> void:
	isOn=true
	global_position = setPosition
	coolDownTimer.wait_time = setCooldown
	durationTimer.wait_time = setDuration	
	coolDownTimer.start()
	durationTimer.start()	

func _on_duration_timeout() -> void:
	isOn=false

func _on_cool_down_timeout() -> void:
	if isOn:
		Globals.createPuff(global_position)



	