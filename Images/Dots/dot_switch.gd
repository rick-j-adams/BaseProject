extends Node2D

@onready var sprite:Sprite2D = $Sprite2D 
@onready var audioStreamPlayer2D:AudioStreamPlayer2D = $AudioStreamPlayer2D 



var on:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body:Node2D) -> void:
	if not on and body is DotBot:
		on = true
		sprite.frame=1
		for node in get_children():
			if node is DotZap:
				node.open()
				audioStreamPlayer2D.play()
