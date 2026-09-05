extends Node2D

class_name GoodyBox

const CLEAR_BLOCKAGE_OBJECTIVE_ID = 200
@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var removeTimer :Timer = $RemoveAfter
@export var levelId: int = 0

var numberOfBits:float = 0.1

var destroyed :	bool= false

func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if not destroyed:
			if body is Dydimo:			
				destroy()
				body.launchInAir()
				# var launchUp = 1000 - body.yForce
				# body.yForce -= launchUp
				

func destroy():
	animationPlayer.play("Die")
	destroyed = true
	removeTimer.start()
	Globals.movePuffMachine(global_position, 0.05, 1)
	Globals.moveBitMachine(global_position,numberOfBits, 0.4)
	if levelId == CLEAR_BLOCKAGE_OBJECTIVE_ID:
		Globals.setObjectiveDone("clearPath")
	

func _on_remove_after_timeout() -> void:
	Globals.addToCullList(levelId)
	queue_free()		
