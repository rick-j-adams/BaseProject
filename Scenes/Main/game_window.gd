extends Node2D

@onready var level :Node2D = $Level

func _ready() -> void:
	#Globals.mainCamera = $Spaceman/Camera2D
	Globals.gameWindow = self
	restart()

func restart() -> void:
	Globals.loadRestartLevel()



# func _process(delta: float) -> void:
# 	pass
