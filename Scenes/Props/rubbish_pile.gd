extends Node2D

class_name RubbishPile

@onready var pile :Node2D = $Pile
@onready var timer :Timer = $Timer

var done :bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if done:
		return
	done = true
	if body is Dydimo:
		done = true
		Globals.playAudioAt(global_position, "rubbish")
		timer.start()
		for rubbish in pile.get_children():
			if rubbish is RubbishBit:
				rubbish.kickRubbish()
	


func _on_timer_timeout() -> void:
	queue_free()
