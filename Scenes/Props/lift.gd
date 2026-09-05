extends Node2D

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var downLightRPoint : RPoint = $DownLightRPoint
@onready var upLightRPoint : RPoint = $UpLightRPoint

@export var isOn : bool = false
@export var isBlocked : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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


func _on_area_2d_body_exited(body: Node2D) -> void:
	var parent = body.get_parent()
	if parent is GoodyBox:
		animationPlayer.play("CloseDoorOutSide")
		Globals.setObjectiveDone("fixClearBlockage")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Dydimo:
		pass
		# animationPlayer.play("EnterLift")
		#animationPlayer.play("GoingDown")
	else :
		var parent = body.get_parent()
		if parent is GoodyBox:
			animationPlayer.play("Blocked")
		# animationPlayer.play("EnterLift")
	
