extends Node2D

class_name BitMachine

@export var timeBetween : float = 0.1
@export var duration : float = 1.0

@onready var coolDownTimer : Timer= $CoolDown
@onready var durationTimer : Timer= $Duration

var isOn : bool = false

func createBitMachine(setPosition: Vector2, setCooldown: float, setDuration: float) -> void:
	isOn=true
	global_position = setPosition
	coolDownTimer.wait_time = setCooldown
	durationTimer.wait_time = setDuration	
	coolDownTimer.start()
	durationTimer.start()	

func _on_duration_timeout() -> void:
	isOn=false
	coolDownTimer.stop()
	durationTimer.stop()	

func _on_cool_down_timeout() -> void:
	if isOn:
		Globals.createBit(global_position)
