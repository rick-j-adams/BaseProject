@tool

extends StaticBody2D

class_name Rampon

enum TYPES { STEALPLATE, GRILL}

var textureMap = {
	TYPES.STEALPLATE : "res://Images/Backgrounds/cycloid2.png",
	TYPES.GRILL : "res://Images/Backgrounds/cycloid2.png"
}


@export var type : TYPES = TYPES.STEALPLATE :
	set(value):
		type = value
		if type == TYPES.STEALPLATE:
			$Sprite2D.texture = load("res://Images/Backgrounds/rampon.png")
		elif type == TYPES.GRILL:
			$Sprite2D.texture = load("res://Images/Backgrounds/rampon2.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
