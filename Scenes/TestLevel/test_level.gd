extends Node2D


func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		body.rampPush() 

	Globals.transitionTo("gameWindow")	