extends Node2D

var crawl_text := "A Game by Rick and Eb Adams\n\n\nThis game was made with the Godot Engine\n\n\nGodot License: \n"+Engine.get_license_text()+"\n\n\n\n\n\n\n\n\n\n\n\nThank you for playing!"
 
func _ready() -> void:
	$crawl/LicenseLabel.text = crawl_text
 


func _on_back_button_released() -> void:
	Globals.transitionTo("mainMenu")
