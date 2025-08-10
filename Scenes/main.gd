extends Node2D



func _ready() -> void:
	Globals.mainScene = $MainView
	Globals.interfaceAudio = $Interface/AudioStreamPlayer2D
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
