extends Node2D

class_name BitPayMachine

@export var timeBetween : float = 0.1
@export var duration : float = 1.0

@onready var coolDownTimer : Timer= $CoolDownPay
@onready var durationTimer : Timer= $DurationPay

var isOn : bool = false

var destination : Vector2 = Vector2.ZERO

func createBitPayMachine(setPosition: Vector2, setDestination: Vector2, amountToPay: float) -> void:
	isOn=true
	global_position = setPosition
	destination = setDestination
	coolDownTimer.wait_time = 0.2
	durationTimer.wait_time = amountToPay * 0.2	
	coolDownTimer.start()
	durationTimer.start()	


func _on_duration_pay_timeout() -> void:
	isOn=false
	coolDownTimer.stop()
	durationTimer.stop()

func _on_cool_down_pay_timeout() -> void:
	if isOn:
		Globals.createBitPay(global_position, destination)
