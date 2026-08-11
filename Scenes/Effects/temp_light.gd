extends Node2D

class_name TempLight

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var timer :Timer = $Timer
@onready var pointLight :PointLight2D = $PointLight2D

enum LightType {
	WHITE_EXPLODE,
	RED_EXPLODE,
	LIGHTNING,
	FLAME
}

var lightType : int = LightType.WHITE_EXPLODE
var isOn : bool = false

func _ready() -> void:
	visible=false
	isOn=false

func setUpLight(lightType:LightType, lightPosition:Vector2) -> void:
	if isOn:
		return
	lightType = lightType
	global_position = lightPosition
	isOn = true
	runAnimation(lightType)
	

func runAnimation(type:LightType) -> void:
	var waitTime : float = 0.2
	var animationName : String = "Explode"	
	pointLight.color = Color.WHITE
	if type == LightType.RED_EXPLODE:
		pointLight.color = Color.RED
		
	elif type == LightType.LIGHTNING:
		pointLight.color = Color.AQUA
		animationName = "FlickerShort"
		waitTime = 0.2
	elif type == LightType.FLAME:
		animationName = "Flicker"
		pointLight.color = Color.RED
		waitTime = 0.1
	visible = true	
	timer.wait_time=waitTime
	timer.start()
	animationPlayer.play(animationName)

func _on_timer_timeout() -> void:
	isOn=false
	visible=false
