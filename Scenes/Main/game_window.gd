extends Node2D

func _ready() -> void:
	#Globals.mainCamera = $Spaceman/Camera2D
	Globals.gameWindow = self
	restart()

func restart() -> void:
	pass

# func _process(delta: float) -> void:
# 	pass
