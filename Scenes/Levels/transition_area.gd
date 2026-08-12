extends Area2D

class_name TransitionArea

enum TRANSITION_TYPES {HORIZONTAL, VERTICAL, BOTH}

@export var transisitionType :TRANSITION_TYPES = TRANSITION_TYPES.HORIZONTAL
@export var destinationLevel : String = "R001"
@export var destinationEntryPoint : String = "E1"


func _on_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			Globals.transitionToEntryPoint(transisitionType,  destinationLevel, destinationEntryPoint)
