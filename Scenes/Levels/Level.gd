extends Node2D


@onready var entryPoints :Node2D = $EntryPoints

func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			body.explode()

func getLevelLimts () -> Array:
	var left:float= 0 
	var top :float= 0 
	var right:float = 0 
	var bottom:float =0
	for node in entryPoints.get_children():
		if node.global_position.x < left :
			left=node.global_position.x
		if node.global_position.x > right :
			right=node.global_position.x
		if node.global_position.y < top :
			top=node.global_position.y
		if node.global_position.y > bottom :
			bottom=node.global_position.y
	return [left,top,right,bottom ]


func findEntryPointsPosition(entryPointsName:String) -> Vector2:
	for node in entryPoints.get_children():
		if node.name == entryPointsName:
			return node.global_position
	return Vector2(0.0,0.0)
