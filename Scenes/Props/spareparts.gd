extends CharacterBody2D

class_name SpareParts

enum PartsType {
	HEAD,
	BODY,
	LEFT_ARM,
	RIGHT_ARM,
	TRACKS
}

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var area2D :Area2D = $Area2D
@onready var sprite2D :Sprite2D = $Sprite2D

@export var destroyed :	bool= false
@export var partsType : PartsType = PartsType.HEAD
@export var showOnStart : bool = true

var converyerCount : int = 0

var maxSpeed : float =1600.0

func _ready() -> void:
	add_to_group("spareparts")
	if not showOnStart:
		destroy()
	else:
		reset()

func _process(delta: float) -> void:
	if not destroyed:
		velocity.y=velocity.y+Globals.GRAVITY *delta

		move_and_slide()
		if velocity.y == 0:
			animationPlayer.stop()
		
func playSpinAnimation():
	if partsType == PartsType.HEAD:
		animationPlayer.play("Spin1")
	elif partsType == PartsType.BODY:
		animationPlayer.play("Spin2")
	elif partsType == PartsType.LEFT_ARM:
		animationPlayer.play("Spin3")
	elif partsType == PartsType.RIGHT_ARM:
		animationPlayer.play("Spin4")
	elif partsType == PartsType.TRACKS:
		animationPlayer.play("Spin5")		

func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if not destroyed:
			if body is Dydimo:		
				body.yForce -= 1000	
				destroy()

func reset():
	playSpinAnimation()
	velocity = Vector2.ZERO
	destroyed = false
	sprite2D.visible = true
	# set_collision_layer_value(1, true)
	area2D.set_collision_layer_value(1, true)

func flingUp(startFrom: Vector2):
	global_position = startFrom
	velocity.x = Globals.get_rand_between(-maxSpeed, maxSpeed)
	velocity.y = Globals.get_rand_between(-maxSpeed, -200)
	reset()

func drop(startFrom: Vector2):
	global_position = startFrom	
	partsType = Globals.get_random_four()
	reset()


func destroy():
	# print("destroyed")
	destroyed = true
	sprite2D.visible = false
	# set_collision_layer_value(1, false)
	area2D.set_collision_layer_value(1, false)
	Globals.movePuffMachine(global_position, 0.05, 1)
	Globals.moveBitMachine(global_position, 0.1, 0.1)
