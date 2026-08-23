extends Node2D

class_name DotPostion

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass

func requestExplodeAt(at :Vector2) -> void:
	if not animationPlayer.is_playing():
		position = at
		animationPlayer.play("explode")
