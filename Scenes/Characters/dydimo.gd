extends CharacterBody2D

class_name Dydimo
# @onready var animationTree: AnimationTree = $AnimationTree

@onready var sprite : Sprite2D = $Sprite2D
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var rayFront :RayCast2D = $RayCast2DFront
@onready var rayBack :RayCast2D = $RayCast2DBack
@onready var rayFacing :RayCast2D = $RayCast2DFacing
@onready var rayFacingBack :RayCast2D = $RayCast2DFacingBack
@onready var camera :Camera2D = $Camera2D
@onready var underside :RPoint = $RPoint


@onready var teleportRightRay :RayCast2D = $RayCast2DTeleportRight
@onready var teleportLeftRay :RayCast2D = $RayCast2DTeleportLeft

@export var zap : bool = false
@export var bigZap : bool = false
@export var doubleJump : bool = false #done
@export var jetPack : bool = false #done
@export var wallRide : bool = false # done - for now
@export var telePorter : bool = false
@export var healthPack : bool = false
@export var bigHealthPack : bool = false
@export var chute : bool = false
@export var magnet : bool = false
@export var security : bool = false
@export var speedBoost : bool = false #done

enum STATES {BIRTH, IDLE, WALKING, RUNNING, PREJUMP, JUMPING, FALLING, BLOWING}
var state : STATES = STATES.BIRTH

var currentAnimation : String = "Birth"
var lastAnimation : String = ""
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
var interaction : bool = false
var currentIdleTime : float = 0.0
var nextIdleTime : float = 5.0
var jumpCounter : int = 0

#Camera
var shakeDecay := 5.0
var shakeOfferSet := Vector2(10, 10)
var shakeStrength := 0.0

var buildableArea : Node2D = null
var blowUp : bool = false
var lastBlowUp : bool = false

var bitCounter : int = 0	

func _ready() -> void:
	add_to_group("actor")
	animationPlayer.play(currentAnimation)
	Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "BirthSpark")
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
					if blowUp:
						if currentAnimation != "Parashootfloat":
							currentAnimation = "ParashootOpen"
						else:
							currentAnimation = "Parashootfloat"
					else:
						currentAnimation = "Default"
		STATES.WALKING:
			if animationPlayer.is_playing() == false:
				if onFloor:
					if currentAnimation == "WalkStart":
						currentAnimation = "Walk"
					else:				
						currentAnimation = "Walk"
				else:
					if blowUp:
						if currentAnimation != "Parashootfloat":
							currentAnimation = "ParashootOpen"
						else:
							currentAnimation = "Parashootfloat"
					elif jetPack:
						currentAnimation = "Falling"
					else:
						currentAnimation = "Rising"
		STATES.RUNNING:
			currentAnimation = "Run"
		STATES.JUMPING:
			currentAnimation = "Jump"
		STATES.BLOWING:
			if animationPlayer.is_playing() == false:
				if currentAnimation == "ParashootOpen":
					currentAnimation = "Parashootfloat"
					
		STATES.FALLING:
			if onFloor:
				if currentAnimation == "Falling" or currentAnimation == "Rising":
						currentAnimation = "Land"
						shakeStrength = 0.3

						if lastYForce > 1000:
							shakeStrength = 0.5
							Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "LandSpark")

						if lastYForce > 1200:
							shakeStrength = 0.8
							Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "LandSpark")
						if lastYForce > 1400:
							shakeStrength = 1.0
							Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "LandSpark")
				elif animationPlayer.is_playing() == false:
					if currentAnimation == "Land":
						changeState(STATES.IDLE)
						currentAnimation = "Default"
	
	if blowUp and (currentAnimation == "ParashootOpen"):
		if animationPlayer.is_playing() == false:
			currentAnimation = "Parashootfloat"
	if not blowUp and (currentAnimation == "ParashootOpen" or currentAnimation == "Parashootfloat"):
		currentAnimation = "ParashootClose"
	if currentAnimation == "Falling" or currentAnimation == "Rising":
		if not blowUp and onFloor:
			currentAnimation = "Land"
	
	if currentAnimation != lastAnimation or not animationPlayer.is_playing():
		animationPlayer.play(currentAnimation)
		lastAnimation = currentAnimation

func changeState(newState: STATES):
	#print("curstate:"+str(state)+"::"+"new state:"+str(newState) )
	if state == newState:
		return
	if state == STATES.BIRTH and newState == STATES.IDLE:
		currentAnimation="Default"
	if isOnFloor():
		if newState == STATES.WALKING:
			currentIdleTime = 0.0
		if state == STATES.IDLE and newState == STATES.WALKING:
			currentAnimation="WalkStart"

		if state == STATES.WALKING and newState == STATES.IDLE:
			currentAnimation="WalkStop"	
			Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "StopSpark")

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
			if jetPack:
				currentAnimation="Falling"
			else:
				currentAnimation="Rising"
		if state == STATES.IDLE and newState == STATES.FALLING:
			currentAnimation="Rising"
		if state == STATES.JUMPING and newState == STATES.PREJUMP:
			currentAnimation="Falling"
		if state == STATES.FALLING and newState == STATES.PREJUMP:
			currentAnimation="Falling"
		if state == STATES.WALKING and newState == STATES.PREJUMP:
			currentAnimation="Falling"
		if state == STATES.JUMPING and newState == STATES.JUMPING:
			currentAnimation="Falling"
		if state == STATES.FALLING and newState == STATES.JUMPING:
			currentAnimation="Falling"
		if state == STATES.WALKING and newState == STATES.JUMPING:
			currentAnimation="Falling"

	if (state == STATES.IDLE  or state == STATES.PREJUMP or state == STATES.JUMPING  or state == STATES.FALLING  ) and newState == STATES.BLOWING:
		currentAnimation = "ParashootOpen"
	state = newState

func calcAcceleration(delta: float, direction: float, currentSpeed: float, onFloor: bool):

	if xForce < 0 and direction > 0:
		decelerate(delta, sign(xForce), currentSpeed)
	elif xForce > 0 and direction < 0:
		decelerate(delta, sign(xForce), currentSpeed)
	else:
		var localAcceleration: float = acceleration
		var localMaxSpeed: float = maxSpeed
		if speedBoost:
			localAcceleration = localAcceleration * 1.5
			localMaxSpeed = localMaxSpeed * 1.5
		if not onFloor:
			localAcceleration = localAcceleration / 2
		var appliedAcceleration: float = ((localMaxSpeed - currentSpeed)/ localMaxSpeed) * localAcceleration
		if not onFloor:
			appliedAcceleration = appliedAcceleration / 2
		#print("isOnWall: " + str(isOnWall()) + " appliedAcceleration: " + str(appliedAcceleration) + " currentSpeed: " + str(currentSpeed))
		if onFloor and wallRide and (rotation_degrees > 45 or rotation_degrees < -45):
			yForce = yForce - 10
			if yForce > -200:
				yForce = yForce - 200

			print("Wall Ride Acceleration: " + str(yForce))
			xForce = xForce +( delta * appliedAcceleration * direction)
		else:	
			xForce = xForce +( delta * appliedAcceleration * direction)
	

func decelerate(delta: float, direction: float, currentSpeed: float , onFloor: bool = true):
	if onFloor and currentSpeed > 0:	
		Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "StartSpark")
		#Globals.createPuff(underside.global_position)

	var localMaxSpeed: float = maxSpeed
	if speedBoost:
		localMaxSpeed = localMaxSpeed * 1.5
	var appliedRatio: float = 1 - ( currentSpeed / localMaxSpeed )
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

func changeDirection(flip: bool):
	$Sprite2D.flip_h = flip	
	

func nextToWall() -> bool:
	if rayFacing.is_colliding() or rayFacingBack.is_colliding():
		return true
	return false

func _process(delta: float) -> void:
	var currentSpeed: float = absf(xForce)
	var isNowOnFloor:bool = isOnFloor()
	interaction=false
	if Input.is_action_pressed("ui_right"):	
		changeState(STATES.WALKING)
		changeDirection(false)
		#$Sprite2D.flip_h = false
		calcAcceleration(delta, 1,currentSpeed, isNowOnFloor)
		interaction=true
		# if isOnWall() and wallRide and rotation_degrees > 45:
		# 	print("Wall Ride Activated R")
		# 	floor_max_angle = 100
		# else:
		# 	floor_max_angle = 50
		

	elif Input.is_action_pressed("ui_left"):
		changeState(STATES.WALKING)
		#$Sprite2D.flip_h = true
		changeDirection(true)
		calcAcceleration(delta, -1,currentSpeed, isNowOnFloor)
		interaction=true
		# if isOnWall() and wallRide and rotation_degrees < -45:
		# 	print("Wall Ride Activated L")
		# 	floor_max_angle = 100
		# else:
		# 	floor_max_angle = 50
	else:
		decelerate(delta, sign(xForce), currentSpeed, isNowOnFloor)
		#changeState(STATES.IDLE)
	
	if Input.is_action_just_pressed("ui_up"):	
		if isNowOnFloor or (doubleJump and jumpCounter<2) or (jetPack):
			changeState(STATES.PREJUMP)
			springing = true
			interaction=true
			
	
	if Input.is_action_just_released("ui_up"):
		doJump(isNowOnFloor)
		interaction=true

	if Input.is_action_just_released("ui_down"):
		if buildableArea !=null:
			buildableArea.repair()
		#for testing purposes
		var bitPosition: Vector2 = global_position
		bitPosition.y = bitPosition.y - 128
		Globals.createBit(bitPosition)
		
		#wallRide = !wallRide
		#doTeleport()
		#print("Teleport: " + str(telePorter))
	#Globals.createPuff(global_position)
	if nextToWall() and wallRide and (rotation_degrees < -45 or rotation_degrees > 45):	
		floor_max_angle = 100
	else:
		floor_max_angle = 50

	if not interaction and wallRide:
		#print("Wall Ride deActivated")
		floor_max_angle = 50

	if springing:
		if currentJumpForce>=jumpPower:
				var changedJumpForce: float = (jumpPower / maxJumpChargeTime) * delta
				currentJumpForce = currentJumpForce + (changedJumpForce)
	#print(global_position)
	doBlowUp(delta)
	doForces(delta)
	doAnimation(isNowOnFloor)
	doRotate(delta)
	move_and_slide()
	doCameraShake(delta)
	xForce = velocity.x
	yForce = velocity.y

	if lastYForce - yForce < -30 and not isNowOnFloor:
		changeState(STATES.FALLING)
	if state == STATES.FALLING and isNowOnFloor:
		changeState(STATES.IDLE)
	if isNowOnFloor:
		jumpCounter=0
	if not interaction and isNowOnFloor:	
		doIdle(delta)

	# print("yForce: " + str(yForce) + " lastYForce: " + str(lastYForce))
	lastYForce = yForce
	lastBlowUp = blowUp

func doBlowUp(delta: float):
	if blowUp and not lastBlowUp:
		changeState(STATES.BLOWING)	
		yForce = yForce - 200
	if blowUp:
		yForce = yForce - 2000*delta

func doTeleport():
	telePorter = true
	if telePorter:
		var teleport_distance = 400.0
		var target_x = position.x
		
		if sprite.flip_h:
			target_x -= teleport_distance
		else:
			target_x += teleport_distance
		
		# Check if target position is safe using physics query
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = Vector2(target_x, position.y)
		query.collision_mask = collision_mask  # Use the character's collision mask
		
		var result = space_state.intersect_point(query)
		
		if result.is_empty():
			# Safe to teleport
			position.x = target_x
			# Reset velocity to prevent getting stuck
			velocity = Vector2.ZERO
			xForce = 0.0
			yForce = 0.0
			Globals.moveSparkEffect(global_position, rotation, sprite.flip_h, "TeleportSpark")
		else:
			# Find nearest safe position by checking incrementally
			var step = 50.0  # Check every 50 units
			var max_attempts = int(teleport_distance / step)
			var found_safe = false
			
			for i in range(1, max_attempts + 1):
				var check_x = position.x + (teleport_distance - i * step) * (1 if not sprite.flip_h else -1)
				query.position = Vector2(check_x, position.y)
				result = space_state.intersect_point(query)
				
				if result.is_empty():
					position.x = check_x
					velocity = Vector2.ZERO
					xForce = 0.0
					yForce = 0.0
					Globals.moveSparkEffect(global_position, rotation, sprite.flip_h, "TeleportSpark")
					found_safe = true
					break
			
			if not found_safe:
				print("No safe teleport position found")


		


func doIdle(delta: float):
	changeState(STATES.IDLE)
	if state == STATES.IDLE:
		currentIdleTime += delta
		if not blowUp and currentIdleTime >= nextIdleTime:
			var randomValue: float = Globals.get_rand_between(0, 3)
			#print("Random Idle Time: " + str(randomValue))
			if randomValue < 1:
				currentAnimation = "WaitIdle1"
			elif randomValue < 2:
				currentAnimation = "WaitIdle2"
			else:
				currentAnimation = "WaitIdle3"
			currentIdleTime = 0.0
			nextIdleTime= Globals.get_rand_between(2, 6)


func doJump(isNowOnFloor: bool):
	if isNowOnFloor or (doubleJump and jumpCounter<1) or (jetPack):
		if (doubleJump and jumpCounter<2):
			#print("Double Jump Activated")
			currentJumpForce = jumpPower 
		if jetPack:
			#print("Jet Pack Activated")
			currentJumpForce = jumpPower / 2
		
		#print(rotation_degrees)	
		springing = false
		if rotation_degrees >= 45 or rotation_degrees <= -45:
			currentJumpForce = currentJumpForce/2
			if rotation_degrees > 0:
				xForce = xForce - currentJumpForce
			else:
				xForce = xForce + currentJumpForce
		yForce=currentJumpForce
		jumpCounter=jumpCounter+1
		currentJumpForce=0.0
		changeState(STATES.JUMPING)
		
		
func doCameraShake(delta: float):
	if shakeStrength > 0:
		shakeStrength = max(shakeStrength - shakeDecay * delta, 0)
		var offset_x = randf_range(-1.0, 1.0) * shakeOfferSet.x * shakeStrength
		var offset_y = randf_range(-1.0, 1.0) * shakeOfferSet.y * shakeStrength
		camera.offset = Vector2(offset_x, offset_y)
	else:
		camera.offset = Vector2.ZERO

func doForces(delta: float):
	yForce=yForce+Globals.GRAVITY *delta
	#print ("wallRide: " + str(wallRide) + " isOnFloor: " + str(isOnFloor()) + " rayFacing Colliding: " + str(nextToWall())+ " rotation_degrees: " + str(rotation_degrees))
	if not wallRide	and  nextToWall() and ( not isOnFloor() or rotation_degrees>=45 or rotation_degrees<=-45):
		if rayFacing.is_colliding():
			print("push off wall R")
			xForce = xForce - 20
		else:
			print("push off wall L")
			xForce = xForce + 20

	velocity.y = yForce 
	velocity.x = xForce 

func doRotate(delta: float):
	var maxRotation: float = 45.0
	if wallRide:
		maxRotation = 90.0
	if rayFront.is_colliding() and not rayBack.is_colliding():
		rotation_degrees=rotation_degrees-90.0*delta
	
		if rotation_degrees < -maxRotation:
			rotation_degrees = -maxRotation
		if rotation_degrees > maxRotation:
			rotation_degrees = maxRotation	
		# xForce = xForce - (Globals.GRAVITY * delta * 0.1)
	if not rayFront.is_colliding() and  rayBack.is_colliding():
		rotation_degrees=rotation_degrees+90.0*delta
		if rotation_degrees < -maxRotation:
			rotation_degrees = -maxRotation
		if rotation_degrees > maxRotation:
			rotation_degrees = maxRotation	
		# xForce = xForce + (Globals.GRAVITY * delta * 0.1)
	if (rayFront.is_colliding() and  rayBack.is_colliding()) or (not rayFront.is_colliding() and not rayBack.is_colliding()):
		if rotation_degrees> 0: 
			rotation_degrees=rotation_degrees-90.0*delta
			
		if rotation_degrees< 0: 
			rotation_degrees=rotation_degrees+90.0*delta
	if wallRide:
		if nextToWall():
			#print("Wall Ride Rotation:" + str(rotation_degrees))
			if rotation_degrees<90:
				rotation_degrees=rotation_degrees-90.0*delta
			if rotation_degrees>90:
				rotation_degrees=rotation_degrees+90.0*delta
	

func isOnFloor() -> bool:
	if rayFront.is_colliding() or rayBack.is_colliding():
		return true
	return false
