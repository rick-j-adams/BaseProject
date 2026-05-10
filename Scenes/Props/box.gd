extends Node2D




@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var removeTimer :Timer = $RemoveAfter


var destroyed :	bool= false

func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if not destroyed:
			if body is Dydimo:			
				destroy()
				body.yForce -= 1000
				

func destroy():
	animationPlayer.play("Die")
	destroyed = true
	removeTimer.start()
	Globals.movePuffMachine(global_position, 0.05, 1)
	Globals.moveBitMachine(global_position, 0.1, 0.4)

func _on_remove_after_timeout() -> void:
	queue_free()		
