extends Node2D

var yesFunction  := func() -> void:
	pass
	
var  noFunction := func() -> void:
	pass


func _ready() -> void:
	add_to_group("PopUps")

func _process(delta: float) -> void:
	pass


func _on_yes_button_pressed() -> void:
	Globals.playInterfaceAudio($YesButton.global_position, "yesSound")
	

func _on_yes_button_released() -> void:
	yesFunction.call()
	queue_free()


func _on_no_button_pressed() -> void:
	Globals.playInterfaceAudio($YesButton.global_position, "noSound")

func _on_no_button_released() -> void:
	noFunction.call()
	queue_free()
