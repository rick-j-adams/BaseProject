extends Node2D
class_name Switch


enum SWITCH_TYPE {SCANNER, PROX, PLATE, BUTTON, LEVER}
enum SWITCH_STATE {POWERED, UNPOWERED,POWEROFF, POWERON}

@export var switchType:SWITCH_TYPE = SWITCH_TYPE.SCANNER
@export var switchState:SWITCH_STATE = SWITCH_STATE.POWERED
@export var needsSecurity :bool= false

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var timer : Timer = $Timer
@onready var sprite2D : Sprite2D = $Sprite2D
@onready var topRPoint : RPoint = $RPoint


var lockAndKeySystem:LockAndKeySystem = null

var inArea:bool = false

func _ready() -> void:
	# if needsSecurity:
	# 	sprite2D.modulate = Color.RED
	if switchType == SWITCH_TYPE.SCANNER:
		sprite2D.texture=Globals.getTextureByName("scanner")
	elif switchType == SWITCH_TYPE.PROX:
		sprite2D.texture=Globals.getTextureByName("prox")
	timer.start()

func powerOn () ->void:
	if switchState == SWITCH_STATE.POWERED or switchState == SWITCH_STATE.POWERON:
		return
	switchState = SWITCH_STATE.POWERON
	animationPlayer.play("SwitchOn")
	timer.start()

func powerOff () ->void:
	if switchState == SWITCH_STATE.UNPOWERED or switchState == SWITCH_STATE.POWEROFF:
		return
	switchState = SWITCH_STATE.POWEROFF
	animationPlayer.play("SwitchOff")
	timer.start()

func doLighting() ->void:
	if switchState == SWITCH_STATE.POWERED and switchType == SWITCH_TYPE.SCANNER:
		Globals.requestTempLight(global_position, TempLight.LightType.LIGHTNING)
	if switchState == SWITCH_STATE.POWERED and switchType == SWITCH_TYPE.PROX:
		Globals.requestTempLight(global_position, TempLight.LightType.FLAME)

func _on_timer_timeout() -> void:
	if  switchState == SWITCH_STATE.POWERON:
		animationPlayer.play("IdleOn")
		switchState = SWITCH_STATE.POWERED
	if  switchState == SWITCH_STATE.POWEROFF:
		animationPlayer.play("IdleOff")	
		switchState = SWITCH_STATE.UNPOWERED

func signalToParent(switchOn:bool) -> void :
	if lockAndKeySystem != null:
		if switchOn:
			lockAndKeySystem.switchOn()
		else:
			lockAndKeySystem.switchOff()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if switchState != SWITCH_STATE.POWERED:
		return 
	if body is Dydimo:
		inArea=true
		if switchType == SWITCH_TYPE.SCANNER or switchType == SWITCH_TYPE.PLATE  or  switchType == SWITCH_TYPE.PROX :
			if not needsSecurity or (needsSecurity and Globals.isPickUpOn(PickUp.PickUpType.SECURITY)):
				signalToParent(true)



func _on_area_2d_body_exited(body: Node2D) -> void:
	if switchState != SWITCH_STATE.POWERED:
		return 
	if body is Dydimo:
		inArea=true
		if switchType == SWITCH_TYPE.SCANNER or switchType == SWITCH_TYPE.PLATE or  switchType == SWITCH_TYPE.PROX :
			if not needsSecurity or (needsSecurity and Globals.isPickUpOn(PickUp.PickUpType.SECURITY)):
				signalToParent(false)
