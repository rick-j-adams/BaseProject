extends Node2D

@onready var spareparts :SpareParts = $Spareparts
@onready var timer :Timer = $Timer
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer


func _on_timer_timeout() -> void:
	if spareparts.destroyed:
		animationPlayer.play("Deposit")
		# var startPosition = global_position
		# startPosition.y=startPosition.y+Globals.get_rand_between(-20, 20)
		# spareparts.drop(global_position)

	timer.wait_time = Globals.get_rand_between(6, 26)
	timer.start()
	
func dropSparePart():
	var startPosition = global_position
	startPosition.y=startPosition.y+Globals.get_rand_between(-20, 20)
	spareparts.drop(startPosition)
