extends Node2D

class_name RubbishBit

@onready var timer :Timer = $Timer
@onready var sprite2D :Sprite2D = $Sprite2D


enum RUBBISH_TYPE {
	PAPER1,
	PAPER2,
	PAPER3,
	COG1,
	COG2,
	COG3,
	BALL1,
	BALL2,
	BALL3,
	CAN1,
	CAN2,
	CAN3,
	SPRING1,
	SPRING2,
	SPRING3,
	PACKAGE1,
	PACKAGE2,
	PACKAGE3,
	BOARD1,
	BOARD2,
	BOARD3,
	WIRE1,
	WIRE2,
	WIRE3,
	CUBE,
	RANDOM
}

@export var type := RUBBISH_TYPE.RANDOM

var falling :bool = false

var fallingVector :Vector2 = Vector2.ZERO
var rotationSpeed :float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == RUBBISH_TYPE.RANDOM:
		type = int(Globals.get_rand_between(0, RUBBISH_TYPE.size() - 2)	)
	sprite2D.frame = type
	
func kickRubbish() -> void:
	falling = true
	rotationSpeed = Globals.get_rand_between(10, 30)
	fallingVector = Vector2(Globals.get_rand_between(-500, 500), Globals.get_rand_between(-500, -600))
	timer.start()
	visible = true

func kickRubbishFrom(newPosition: Vector2) -> void:
	falling = true
	type = int(Globals.get_rand_between(0, RUBBISH_TYPE.size() - 2)	)
	sprite2D.frame = type
	rotationSpeed = Globals.get_rand_between(10, 30)
	fallingVector = Vector2(Globals.get_rand_between(-1000, 1000), Globals.get_rand_between(-1000, -500))
	timer.start()
	visible = true
	global_position = newPosition

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if falling:
		global_position.y = global_position.y + fallingVector.y * delta
		global_position.x = global_position.x + fallingVector.x * delta
		rotation += rotationSpeed * delta
		fallingVector.y = fallingVector.y + Globals.GRAVITY * delta


func _on_timer_timeout() -> void:
	falling = false
	visible = false
