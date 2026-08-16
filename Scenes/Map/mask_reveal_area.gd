extends Area2D

class_name MaskRevealArea

@export var isOn : bool = false
@export var maskNumber : int = 1

func _on_body_entered(body:Node2D) -> void:
	if not isOn:
		return 
	if body is Dydimo:
		var levelMaskDetails:Dictionary = Globals.getUpMaskRevealsForLevel()
		var thisMasksDetail = levelMaskDetails.get(maskNumber)
		if thisMasksDetail is Array:
			if len(thisMasksDetail) ==2 :
				if thisMasksDetail[0]:
					thisMasksDetail[1] = true

