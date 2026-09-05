extends Node2D

class_name  BatteryReceptacleWallMount

enum STATE {OPEN, OPENING, CLOSED, CLOSING}

var currentState:STATE = STATE.CLOSED

@onready var timer :Timer = $Timer
@onready var animationPlayer :AnimationPlayer = $AnimationPlayer

# @export var hasBattery = false
# not 100 used for lift objective
const LIFT_OBJECTIVE_ID = 100

var inArea:bool = false
@export var oid:int = 1
@export var alwaysOn:bool = false
@export var onAfterObjective:String = "none"

var lockAndKeySystem:LockAndKeySystem = null


func _ready() -> void:
	playIdle()
	if lockAndKeySystem !=null:
		if hasBattery():
			lockAndKeySystem.powerOnSystem()
		else:
			lockAndKeySystem.powerOffSystem()


func playIdle() ->void:
	if  hasBattery():
		animationPlayer.play("IdleBatteryIn")
	else:
		animationPlayer.play("IdleBatteryOut")
	timer.stop()

func _on_area_2d_body_exited(body:Node2D) -> void:
	if userCanNotOpen():
		return
	if body is Dydimo:	
		inArea=false
		timer.start()
		Globals.currentReceptacle=null
		body.inReceptacleRange = false

func _on_area_2d_body_entered(body:Node2D) -> void:
	if userCanNotOpen():
			return
	if body is Dydimo:	
		currentState = STATE.OPENING
		timer.start()
		animationPlayer.play("Open")
		inArea=true
		Globals.currentReceptacle=self
		body.inReceptacleRange = true

func userCanNotOpen() -> bool:
	if alwaysOn:
		return true
	if Globals.isObjectiveDone(onAfterObjective):
		return true
	return false

func close() -> void:
	currentState = STATE.CLOSING
	timer.start()
	animationPlayer.play("Close")

func _on_timer_timeout() -> void:
	if currentState == STATE.OPENING:
		if inArea:
			timer.stop()
			# Globals.uiCancel()
			# Globals.currentMode=Globals.MODES.BATTERY_RECEPTACLE
		else:
			close()
	else:
		playIdle()

	
func setHasBattery(batteryState: bool) ->void:
	# hasBattery=batteryState
	if lockAndKeySystem !=null :
		if hasBattery()==true:
			if oid == LIFT_OBJECTIVE_ID:
				Globals.setObjectiveDone("fixLift")
			
			lockAndKeySystem.powerOnSystem()
		else:
			if oid == LIFT_OBJECTIVE_ID:
				Globals.setObjectiveUnDone("fixLift")
			lockAndKeySystem.powerOffSystem()

func hasBattery() -> bool :
	if alwaysOn:
		return true
	if Globals.isObjectiveDone(onAfterObjective):
		return true
	for potentialItem in Globals.allResources.allPickUps.keys():
		var itemData = Globals.allResources.allPickUps.get(potentialItem)
		if itemData != null:
			if itemData.get("category") == "battery" and itemData.get("givenTo") == oid:
				return true
	return false
				

			# "category": "battery"
