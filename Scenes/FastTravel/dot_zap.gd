extends Node2D

class_name DotZap

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var staticBody2D :StaticBody2D = $StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass

func open()->void:
	animationPlayer.play("open")
	staticBody2D.set_collision_layer_value(1, false)
