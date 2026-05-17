extends StaticBody2D

@export var isOn := true

func _on_area_2d_body_exited(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			if isOn and  Globals.getBoolGamePropery("magnet"):
				body.magnetCounter = body.magnetCounter - 1
				if body.magnetCounter <=0:
					body.magnetCounter = 0
					body.magOff()

func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			if isOn and Globals.getBoolGamePropery("magnet"):
				body.magnetCounter = body.magnetCounter + 1	
				if body.magnetCounter == 1:
					body.magOn()
