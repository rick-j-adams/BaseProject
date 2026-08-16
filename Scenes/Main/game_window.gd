extends Node2D

@onready var level :Node2D = $Level
@onready var animationPlayer :AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	#Globals.mainCamera = $Spaceman/Camera2D
	Globals.gameWindow = self
	restart()

func restart() -> void:
	Globals.loadRestartLevel()


func playFadeOut():
	animationPlayer.play("FadeOut")

func playFadeIn():
	animationPlayer.play("FadeIn")

# func _process(delta: float) -> void:
# 	pass
