extends Node2D

func _ready() -> void:
	Globals.mainCamera = $Spaceman/Camera2D
	restart()

func restart() -> void:
	pass

func _process(delta: float) -> void:
	pass
