extends StaticBody2D

class_name Cycloid


func sticktoSlope(dydimo: Dydimo) -> void:
	dydimo.floor_snap_length=32

func stickToNormal(dydimo: Dydimo) -> void:
	dydimo.floor_snap_length=10

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Dydimo:
		print("Cycloid: body entered")
		print(body.velocity	)
		sticktoSlope(body)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Dydimo:
		stickToNormal(body)
		
