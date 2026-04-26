extends Node2D

@onready var actor :CharacterBody2D = $Actor
@onready var sprite :Sprite2D = $Actor/Sprite2D
@onready var rayFront :RayCast2D = $Actor/Sprite2D/RayCast2DFront
@onready var rayBack :RayCast2D = $Actor/Sprite2D/RayCast2DBack

enum STATES {BIRTH, IDLE, WALKING, RUNING, COYOTE, PREPJUMP, TAKEOFF, JUMPING, FALLING}

var state : STATES = STATES.IDLE
var velocity : Vector2 = Vector2.ZERO
var lastOneWasFloor := true

@export var playerControlled := false
@export var maxSpeed := 1000.0
@export var maxAcceleration := 1000.0
@export var jumpPower := -800.0
@export var friction := 300.0

var xForce :float= 0.0
var yForce :float= 0.0

var jumpChargeTime: float = 0.0

func _ready() -> void:
	add_to_group("actor")
	pass

func getDirectionOfTravel() -> float:
	if actor.velocity.x < 0:
		return -1
	if actor.velocity.x > 0:
		return 1
	return 0

func applyPlayerForces(_delta: float, _onFloor: bool, speed: float) -> void:
	xForce = 0.0
	var input_vector := Vector2.ZERO

	if playerControlled:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

		if input_vector.x != 0:
			if abs(speed) <= maxSpeed:
				var acceleration_value: float = maxAcceleration * (1 - (abs(speed) / maxSpeed))
				acceleration_value = clamp(acceleration_value, 0, maxAcceleration)
				if _onFloor:
					xForce += acceleration_value * input_vector.x
				else:
					xForce += (acceleration_value / 2) * input_vector.x

		# Apply friction to slow movement
		if abs(actor.velocity.x) > 0:
			var friction_force = sign(actor.velocity.x) * friction
			xForce -= friction_force

		if Input.is_action_just_pressed("ui_up"):
			if _onFloor:
				state = STATES.JUMPING
				jumpChargeTime = 0.0
		
		if Input.is_action_pressed("ui_up") and jumpChargeTime >= 0:
			jumpChargeTime += _delta
			jumpChargeTime = min(jumpChargeTime, 0.2)
			
		
		if Input.is_action_just_released("ui_up"):
			if jumpChargeTime > 0:
				var ratio = jumpChargeTime / 0.2
				actor.velocity.y = min(jumpPower * ratio, jumpPower * 0.5)
				jumpChargeTime = 0.0  

		#print(xForce)

func isOnFloor() -> bool:
	if rayFront.is_colliding() or rayBack.is_colliding():
		return true
	return false

func applyExternalForces(_delta: float, _onFloor: bool) -> void:
	yForce += 2000

func _process(delta: float) -> void:
	yForce = 0.0
	xForce = 0.0
	var onFloor := isOnFloor()
	var speed: float = abs(actor.velocity.x)

	applyExternalForces(delta, onFloor)
	applyPlayerForces(delta, onFloor, speed)

	# Apply forces to velocity
	actor.velocity.y += yForce * delta
	actor.velocity.x += xForce * delta
	actor.move_and_slide()

	lastOneWasFloor = onFloor

func rampPush() -> void:
	print("rampPush")
	var direction := getDirectionOfTravel()
	var speed: float = abs(actor.velocity.x)
	print("speed: ", speed)
	if speed >500:
		actor.velocity.x += direction * 1800

		actor.velocity.y = direction * -1800
	


func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.name=="Actor":
		rampPush()
