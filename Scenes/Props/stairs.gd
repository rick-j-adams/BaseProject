@tool
extends StaticBody2D
class_name Stairs

enum TYPES { STEALPLATE, GRILL}

var textureMap = {
	TYPES.STEALPLATE : "res://Images/Backgrounds/stairs.png",
	TYPES.GRILL : "res://Images/Backgrounds/stairs2.png"
}

@export var type : TYPES = TYPES.STEALPLATE :
	set(value):
		type = value
		if type == TYPES.STEALPLATE:
			$Stairs.texture = load("res://Images/Backgrounds/stairs.png")
		elif type == TYPES.GRILL:
			$Stairs.texture = load("res://Images/Backgrounds/stairs2.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
