extends Node2D


func _ready() -> void:
	if not Globals.editMode:
		$EitMode.queue_free()
	
func _process(delta: float) -> void:
	pass
	
func playPulsing():
	$StartUpAnimationPlayer.play("PulsingEnergy")


func _on_touch_screen_button_pressed() -> void:
	Globals.playInterfaceAudio($Interface/StartGameTouchScreenButton.global_position, "noSound")

func _on_touch_screen_button_released() -> void:
	Globals.transitionTo("gameWindow")

func _on_edit_button_pressed() -> void:
	Globals.playInterfaceAudio($EitMode/EditButton.global_position, "yesSound")

func _on_edit_button_released() -> void:
	Globals.transitionTo("editorScene")
