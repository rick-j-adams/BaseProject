extends CharacterBody2D

# @onready var animationTree: AnimationTree = $AnimationTree

@onready var sprite : Sprite2D = $Sprite2D
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var rayFront :RayCast2D = $RayCast2DFront
@onready var rayBack :RayCast2D = $RayCast2DBack

enum STATES {BIRTH, IDLE, WALKING, RUNNING, PREJUMP, JUMPING, FALLING}
var state : STATES = STATES.BIRTH

var currentAnimation : String = "Birth"
var wasOnFloor : bool = true

# var currentSpeed : float = 0
var acceleration : float = 1000.0
var breakForce : float = 2000.0
var maxSpeed : float = 800.0	
var maxJumpChargeTime : float = 0.2
var jumpPower : float = -1000.0

var lastYForce : float = 0.0

var yForce : float = 0.0
var xForce : float = 0.0
var currentJumpForce : float = 0.0
var springing : bool = false

func _ready() -> void:
	add_to_group("actor")
	animationPlayer.play(currentAnimation)
	state= STATES.BIRTH
	# animationTree.active = true

func doAnimation(onFloor: bool):
	match state:
		STATES.BIRTH:
			currentAnimation = "Birth"
			if animationPlayer.is_playing() == false:
				changeState(STATES.IDLE)
			
		STATES.IDLE:
			if animationPlayer.is_playing() == false:
				if currentAnimation=="Walk":
					currentAnimation = "WalkStop"
				else:
					currentAnimation = "Default"
		STATES.WALKING:
			if animationPlayer.is_playing() == false:

				if onFloor:
					if currentAnimation == "WalkStart":
						currentAnimation = "Walk"
					else:				
						currentAnimation = "Walk"
		STATES.RUNNING:
			currentAnimation = "Run"
		STATES.JUMPING:
			currentAnimation = "Jump"
		STATES.FALLING:
			print("Falling")
			# if isOnFloor():
			# 	print("Landed")
			# 	if currentAnimation == "Falling":
			# 			currentAnimation = "Land"
			# 	elif animationPlayer.is_playing() == false:
			# 		if currentAnimation == "Land":
			# 			changeState(STATES.IDLE)
			# 			currentAnimation = "Default"
			# else:
			# 	currentAnimation = "Falling"
	# print("currentAnimation = " + currentAnimation)	
	if currentAnimation ==	"Falling" or currentAnimation =="Rising":
		if onFloor:
			currentAnimation = "Land"
			
			
	animationPlayer.play(currentAnimation)

func changeState(newState: STATES):
	#print("curstate:"+str(state)+"::"+"new state:"+str(newState) )
	if state == newState:
		return
	if state == STATES.BIRTH and newState == STATES.IDLE:
		currentAnimation="Default"
	if isOnFloor():
		if state == STATES.IDLE and newState == STATES.WALKING:
			currentAnimation="WalkStart"
		if state == STATES.WALKING and newState == STATES.IDLE:
			currentAnimation="WalkStop"	
		if state == STATES.IDLE and newState == STATES.PREJUMP:
			currentAnimation="Spring"
			currentJumpForce = 0.0
		if state == STATES.WALKING and newState == STATES.PREJUMP:
			currentAnimation="Spring"
			currentJumpForce = 0.0
		if state == STATES.PREJUMP and newState == STATES.JUMPING:
			currentAnimation="Falling"
			
			 
		
	else:
		if state == STATES.PREJUMP and newState == STATES.FALLING:
			currentAnimation="Falling"
		if state == STATES.JUMPING and newState == STATES.FALLING:
			currentAnimation="Falling"
		if state == STATES.WALKING and newState == STATES.FALLING:
			currentAnimation="Rising"
		if state == STATES.IDLE and newState == STATES.FALLING:
			currentAnimation="Rising"
		if state == STATES.JUMPING and newState == STATES.PREJUMP:
			currentAnimation="Rising"

	state = newState

func calcAcceleration(delta: float, direction: float, currentSpeed: float, onFloor: bool):

	if xForce < 0 and direction > 0:
		decelerate(delta, sign(xForce), currentSpeed)
	elif xForce > 0 and direction < 0:
		decelerate(delta, sign(xForce), currentSpeed)
	else:
		var localAcceleration: float = acceleration
		if not onFloor:
			localAcceleration = localAcceleration / 2
		var appliedAcceleration: float = ((maxSpeed - currentSpeed)/ maxSpeed) * localAcceleration
		if not onFloor:
			appliedAcceleration = appliedAcceleration / 2
	
		xForce = xForce +( delta * appliedAcceleration * direction)
	

func decelerate(delta: float, direction: float, currentSpeed: float , onFloor: bool = true):
	var appliedRatio: float = 1 - ( currentSpeed / maxSpeed )
	if appliedRatio > 1.0:
		appliedRatio = 1.0
	var appliedBreakForce: float = breakForce
	if not onFloor:
		appliedBreakForce = appliedBreakForce / 2

	var appliedDeceleration: float =  appliedBreakForce * appliedRatio
	if onFloor:
		appliedDeceleration = appliedDeceleration * 2
	
	xForce = xForce - (delta * appliedDeceleration * direction)

	if direction <0 and sign(xForce) > 0:
		xForce = 0
	elif direction > 0 and sign(xForce) < 0:
		xForce = 0



func _process(delta: float) -> void:
	var currentSpeed: float = absf(xForce)
	var isNowOnFloor:bool = isOnFloor()
	if Input.is_action_pressed("ui_right"):	
		changeState(STATES.WALKING)
		$Sprite2D.flip_h = false
		calcAcceleration(delta, 1,currentSpeed, isNowOnFloor)
	elif Input.is_action_pressed("ui_left"):
		changeState(STATES.WALKING)
		$Sprite2D.flip_h = true
		calcAcceleration(delta, -1,currentSpeed, isNowOnFloor)
	else:
		decelerate(delta, sign(xForce), currentSpeed, isNowOnFloor)
		#changeState(STATES.IDLE)
	
	if Input.is_action_just_pressed("ui_up"):	
		if isNowOnFloor:
			changeState(STATES.PREJUMP)
			springing = true
			print("Start Jump Charge")			
	if Input.is_action_just_released("ui_up"):
		doJump(isNowOnFloor)

	if springing:
		if currentJumpForce>=jumpPower:
				var changedJumpForce: float = (jumpPower / maxJumpChargeTime) * delta
				currentJumpForce = currentJumpForce + (changedJumpForce)
				print("currentJumpForce: " + str(currentJumpForce))
		# else:
		# 	doJump(isNowOnFloor)
		# print("currentJumpForce: " + str(currentJumpForce))
	# if wasOnFloor and not isNowOnFloor:
	# 	changeState(STATES.FALLING)
	# wasOnFloor= isNowOnFloor
	doForces(delta)
	doAnimation(isNowOnFloor)
	doRotate(delta)
	move_and_slide()
	xForce = velocity.x
	yForce = velocity.y

	if lastYForce - yForce < -30 and not isNowOnFloor:
		changeState(STATES.FALLING)
	if state == STATES.FALLING and isNowOnFloor:
		changeState(STATES.IDLE)
	# print("yForce: " + str(yForce) + " lastYForce: " + str(lastYForce))
	lastYForce = yForce

func doJump(isNowOnFloor: bool):
	print("Jump with force: " + str(currentJumpForce))
	if isNowOnFloor:
		springing = false
		yForce=currentJumpForce
		currentJumpForce=0.0
		changeState(STATES.JUMPING)

func doForces(delta: float):
	yForce=yForce+Globals.GRAVITY *delta

	# if rotation_degrees>10:		
	# 	xForce = xForce + (Globals.GRAVITY * delta * 0.1)
	# if rotation_degrees<-10:
	# 	xForce = xForce - (Globals.GRAVITY * delta * 0.1)

	velocity.y = yForce 
	velocity.x = xForce 

func doRotate(delta: float):
	if rayFront.is_colliding() and not rayBack.is_colliding():
		rotation_degrees=rotation_degrees-90.0*delta
		# xForce = xForce - (Globals.GRAVITY * delta * 0.1)
	if not rayFront.is_colliding() and  rayBack.is_colliding():
		rotation_degrees=rotation_degrees+90.0*delta
		# xForce = xForce + (Globals.GRAVITY * delta * 0.1)
	if (rayFront.is_colliding() and  rayBack.is_colliding()) or (not rayFront.is_colliding() and not rayBack.is_colliding()):
		if rotation_degrees> 0: 
			rotation_degrees=rotation_degrees-90.0*delta
		if rotation_degrees< 0: 
			rotation_degrees=rotation_degrees+90.0*delta
	

func isOnFloor() -> bool:
	if rayFront.is_colliding() or rayBack.is_colliding():
		return true
	return false



	
