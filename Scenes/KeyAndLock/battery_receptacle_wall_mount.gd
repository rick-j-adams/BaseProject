extends Node2D

class_name  BatteryReceptacleWallMount

enum STATE {OPEN, OPENING, CLOSED, CLOSING}

var currentState:STATE = STATE.CLOSED

@onready var timer :Timer = $Timer
@onready var animationPlayer :AnimationPlayer = $AnimationPlayer

@export var hasBattery = false

var inArea:bool = false
@export var oid:int = 1

var lockAndKeySystem:LockAndKeySystem = null


func _ready() -> void:
	playIdle()
	if lockAndKeySystem !=null:
		if hasBattery:
			lockAndKeySystem.powerOnSystem()
		else:
			lockAndKeySystem.powerOffSystem()


func playIdle() ->void:
	if hasBattery:
		animationPlayer.play("IdleBatteryIn")
	else:
		animationPlayer.play("IdleBatteryOut")
	timer.stop()

func _on_area_2d_body_exited(body:Node2D) -> void:
	if body is Dydimo:	
		inArea=false
		timer.start()
		Globals.currentReceptacle=null

func _on_area_2d_body_entered(body:Node2D) -> void:
	if body is Dydimo:	
		currentState = STATE.OPENING
		timer.start()
		animationPlayer.play("Open")
		inArea=true
		Globals.currentReceptacle=self

func close() -> void:
	currentState = STATE.CLOSING
	timer.start()
	animationPlayer.play("Close")

func _on_timer_timeout() -> void:
	if currentState == STATE.OPENING:
		if inArea:
			timer.stop()
			Globals.uiCancel()
			Globals.currentMode=Globals.MODES.BATTERY_RECEPTACLE
		else:
			close()
	else:
		playIdle()

	
func setHasBattery(batteryState: bool) ->void:
	hasBattery=batteryState
	if lockAndKeySystem !=null :
		if hasBattery==true:
			lockAndKeySystem.powerOnSystem()
		else:
			lockAndKeySystem.powerOffSystem()
