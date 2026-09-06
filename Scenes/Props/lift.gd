extends Node2D

class_name Lift

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var downLightRPoint : RPoint = $DownLightRPoint
@onready var upLightRPoint : RPoint = $UpLightRPoint
@onready var timer : Timer = $Timer
@onready var rPointLiftCenter : RPoint = $RPointLiftCenter

@export var isOn : bool = false
@export var isBlocked : bool = false

@export var liftLevel :int = 3

var transitionToLevel : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globals.isObjectiveDone("fixClearBlockage"):
		isBlocked = false
	if isOn:
		animationPlayer.play("ON")
	else:
		animationPlayer.play("OFF")
	if isBlocked:
		animationPlayer.play("Blocked")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func requestLightUp() -> void:
	Globals.requestTempLight(upLightRPoint.global_position, TempLight.LightType.GREEN_FADE)

func requestLightDown() -> void:
	Globals.requestTempLight(downLightRPoint.global_position, TempLight.LightType.GREEN_FADE)

func playExitLift() -> void:
	animationPlayer.play("LeaveLift")

func playEnterLift() -> void:
	animationPlayer.play("EnterLift")
	


func startLiftTransitionTo(levelName: String, direction: int) -> void:
	transitionToLevel = levelName
	timer.start()
	if direction > liftLevel:
		animationPlayer.play("GoingUp")
	elif direction <liftLevel:
		animationPlayer.play("GoingDown")
	else:
		animationPlayer.play("ON")

func _on_area_2d_body_exited(body: Node2D) -> void:
	var parent = body.get_parent()
	if parent is GoodyBox:
		animationPlayer.play("CloseDoorOutSide")
		Globals.setObjectiveDone("fixClearBlockage")
	if body is Dydimo:
		body.liftInRange = false
		body.lift = null

func movetoCenter() -> void:
	if Globals.mainCharacter != null:
		Globals.mainCharacter.global_position = rPointLiftCenter.global_position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Dydimo:
		body.liftInRange = true
		body.lift = self
	else :
		var parent = body.get_parent()
		if parent is GoodyBox:
			animationPlayer.play("Blocked")


func _on_timer_timeout() -> void:
	timer.stop()
	Globals.transistionToLift(transitionToLevel)

	
