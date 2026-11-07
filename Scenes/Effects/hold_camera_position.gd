extends Node2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Dydimo:
		Globals.mainCamera.peakUntilCanceled(global_position)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Dydimo:
		Globals.mainCamera.cancelPeak()
