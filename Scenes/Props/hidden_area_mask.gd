extends Node2D


@onready var sprite :Sprite2D = $Sprite2D

var goodyBoxes = []

func _on_area_2d_body_exited(body: Node2D) -> void:
	
	if body is Dydimo:	
		sprite.visible=true	
	

func removeAllGoodyBoxes()->void:
	for gb in goodyBoxes:
		if gb != null:
			gb.destroy()
	goodyBoxes.clear()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Dydimo:	
		sprite.visible=false	
		removeAllGoodyBoxes()
	if body is CharacterBody2D:	
		var parent = body.get_parent()
		if parent!=null:
			if parent is GoodyBox:
				parent.numberOfBits=0.5
				goodyBoxes.append(parent)
