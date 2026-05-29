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
@onready var upperside :RPoint = $UPoint
@onready var hitTimer :Timer = $HitTimer
@onready var dyingTimer :Timer = $DyingTimer
@onready var birthTimer :Timer = $BirthTimer
@onready var magnetTimer :Timer = $MagTimer



const BITS = "bits"

@onready var teleportRightRay :RayCast2D = $RayCast2DTeleportRight
@onready var teleportLeftRay :RayCast2D = $RayCast2DTeleportLeft

# @export var zap : bool = false
# @export var bigZap : bool = false
# @export var doubleJump : bool = false #done
# @export var jetPack : bool = false #done
# @export var wallRide : bool = true # done - for now
# @export var telePorter : bool = false
# @export var healthPack : bool = false
# @export var bigHealthPack : bool = false
# @export var chute : bool = false
# @export var magnet : bool = false # done
@export var security : bool = false
# @export var speedBoost : bool = false #done

enum STATES {BIRTH, IDLE, WALKING, RUNNING, PREJUMP, JUMPING, FALLING, BLOWING}
var state : STATES = STATES.BIRTH

var currentAnimation : String = "Birth"
var lastAnimation : String = ""
var wasOnFloor : bool = true

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

# Camera
var shakeDecay := 5.0
var shakeOfferSet := Vector2(10, 10)
var shakeStrength := 0.0

var buildableArea : Node2D = null
var blowUp : bool = false
var lastBlowUp : bool = false
var canTeleport : bool = false
var invulnerable : bool = false
var dying : bool = false
var birthing : bool = true
var magneting:	 bool = false

var magnetCounter : int = 0

# ─── helpers ──────────────────────────────────────────────────────────────────

func isOnFloor() -> bool:
	return rayFront.is_colliding() or rayBack.is_colliding()

func nextToWall() -> bool:
	return rayFacing.is_colliding() or rayFacingBack.is_colliding()

# True once the character has rotated far enough to be gripping a wall.
func isOnWallRide() -> bool:
	return Globals.getBoolGamePropery("wallRide") and nextToWall() and (rotation_degrees >= 45.0 or rotation_degrees <= -45.0)

# ─── ready ────────────────────────────────────────────────────────────────────

func _ready() -> void:
	add_to_group("actor")
	# animationPlayer.play(currentAnimation)
	Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "BirthSpark")
	Globals.setMainCharacter(self)
	startBirth()
	

func startBirth():
	birthing = true
	var bits = Globals.getGamePropery(BITS)
	bits = 1
	Globals.setGamePropery(BITS, bits)
	birthTimer.start()
	state = STATES.BIRTH
	currentAnimation  = "Birth"
	animationPlayer.play(currentAnimation)


# ─── animation ────────────────────────────────────────────────────────────────

func doAnimation(onFloor: bool):
	if not inControl():
		return
	# if currentAnimation == "Damage":
	# 	if animationPlayer.is_playing() != false:
	# 		lastAnimation = currentAnimation	
	# 	else:
	# 		animationPlayer.play("Normal")
	# 		currentAnimation = "Default"	
	# 	return
		
	match state:
		STATES.BIRTH:
			currentAnimation = "Birth"
			if animationPlayer.is_playing() == false:
				changeState(STATES.IDLE)

		STATES.IDLE:
			if animationPlayer.is_playing() == false:
				if currentAnimation == "Walk":
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
					if currentAnimation == "ParashootOpen" or currentAnimation == "Parashootfloat":
						currentAnimation = "ParaShootClose"
					else:
						currentAnimation = "Walk"
				else:
					if blowUp:
						if currentAnimation != "Parashootfloat":
							currentAnimation = "ParashootOpen"
						else:
							currentAnimation = "Parashootfloat"
					elif Globals.getBoolGamePropery("jetPack"):
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

	if blowUp and currentAnimation == "ParashootOpen":
		if animationPlayer.is_playing() == false:
			currentAnimation = "Parashootfloat"
	if not blowUp and (currentAnimation == "ParashootOpen" or currentAnimation == "Parashootfloat"):
		currentAnimation = "ParaShootClose"
	if currentAnimation == "Falling" or currentAnimation == "Rising":
		if not blowUp and onFloor:
			currentAnimation = "Land"

	if currentAnimation != lastAnimation or not animationPlayer.is_playing():
		animationPlayer.play(currentAnimation)
		lastAnimation = currentAnimation

# ─── state machine ────────────────────────────────────────────────────────────

func changeState(newState: STATES):
	if state == newState:
		return
	if state == STATES.BIRTH and newState == STATES.IDLE:
		currentAnimation = "Default"
	if isOnFloor():
		if newState == STATES.WALKING:
			currentIdleTime = 0.0
		if state == STATES.IDLE and newState == STATES.WALKING:
			currentAnimation = "WalkStart"
		if state == STATES.WALKING and newState == STATES.IDLE:
			currentAnimation = "WalkStop"
			if magnetCounter <=0 :
				Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "StopSpark")
		if state == STATES.IDLE and newState == STATES.PREJUMP:
			currentAnimation = "Spring"
			currentJumpForce = 0.0
		if state == STATES.WALKING and newState == STATES.PREJUMP:
			currentAnimation = "Spring"
			currentJumpForce = 0.0
		if state == STATES.PREJUMP and newState == STATES.JUMPING:
			currentAnimation = "Falling"
	else:
		if state == STATES.BLOWING and newState == STATES.FALLING:
			currentAnimation = "ParashootClose"
		if state == STATES.PREJUMP and newState == STATES.FALLING:
			currentAnimation = "Falling"
		if state == STATES.JUMPING and newState == STATES.FALLING:
			currentAnimation = "Falling"
		if state == STATES.WALKING and newState == STATES.FALLING:
			currentAnimation = "Falling" if Globals.getBoolGamePropery("jetPack") else "Rising"
		if state == STATES.IDLE and newState == STATES.FALLING:
			currentAnimation = "Rising"
		if state == STATES.JUMPING and newState == STATES.PREJUMP:
			currentAnimation = "Falling"
		if state == STATES.FALLING and newState == STATES.PREJUMP:
			currentAnimation = "Falling"
		if state == STATES.WALKING and newState == STATES.PREJUMP:
			currentAnimation = "Falling"
		if state == STATES.JUMPING and newState == STATES.JUMPING:
			currentAnimation = "Falling"
		if state == STATES.FALLING and newState == STATES.JUMPING:
			currentAnimation = "Falling"
		if state == STATES.WALKING and newState == STATES.JUMPING:
			currentAnimation = "Falling"

	if (state == STATES.IDLE or state == STATES.PREJUMP or state == STATES.JUMPING or state == STATES.FALLING) and newState == STATES.BLOWING:
		currentAnimation = "ParashootOpen"
	state = newState

# ─── movement ─────────────────────────────────────────────────────────────────

func calcAcceleration(delta: float, direction: float, currentSpeed: float, onFloor: bool):
	if xForce < 0 and direction > 0:
		decelerate(delta, sign(xForce), currentSpeed)
	elif xForce > 0 and direction < 0:
		decelerate(delta, sign(xForce), currentSpeed)
	else:
		var localAcceleration: float = acceleration
		var localMaxSpeed: float = maxSpeed
		if Globals.getBoolGamePropery("speedBoost"):
			localAcceleration *= 1.5
			localMaxSpeed *= 1.5
		if not onFloor:
			localAcceleration /= 2
		var appliedAcceleration: float = ((localMaxSpeed - currentSpeed) / localMaxSpeed) * localAcceleration
		if not onFloor:
			appliedAcceleration /= 2

		# xForce always drives along-surface movement.
		# doForces() is responsible for redirecting it onto the wall when wall riding.
		xForce += delta * appliedAcceleration * direction

func decelerate(delta: float, direction: float, currentSpeed: float, onFloor: bool = true):
	if onFloor and currentSpeed > 0:
		Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "StartSpark")

	var localMaxSpeed: float = maxSpeed
	if Globals.getBoolGamePropery("speedBoost"):
		localMaxSpeed *= 1.5
	var appliedRatio: float = clamp(1.0 - (currentSpeed / localMaxSpeed), 0.0, 1.0)
	var appliedBreakForce: float = breakForce
	if not onFloor:
		appliedBreakForce /= 2
	var appliedDeceleration: float = appliedBreakForce * appliedRatio
	if onFloor:
		appliedDeceleration *= 2

	xForce -= delta * appliedDeceleration * direction

	if direction < 0 and sign(xForce) > 0:
		xForce = 0
	elif direction > 0 and sign(xForce) < 0:
		xForce = 0

func changeDirection(flip: bool):
	$Sprite2D.flip_h = flip

# ─── process ──────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	var currentSpeed: float = absf(xForce)
	var isNowOnFloor: bool = isOnFloor()
	interaction = false

	if Input.is_action_pressed("ui_right") and inControl():
		changeState(STATES.WALKING)
		changeDirection(false)
		calcAcceleration(delta, 1, currentSpeed, isNowOnFloor)
		interaction = true

	elif Input.is_action_pressed("ui_left") and inControl():
		changeState(STATES.WALKING)
		changeDirection(true)
		calcAcceleration(delta, -1, currentSpeed, isNowOnFloor)
		interaction = true

	else:
		decelerate(delta, sign(xForce), currentSpeed, isNowOnFloor)

	if Input.is_action_just_pressed("ui_up") and inControl():
		if isNowOnFloor or (Globals.getBoolGamePropery("doubleJump") and jumpCounter < 2) or Globals.getBoolGamePropery("jetPack"):
			changeState(STATES.PREJUMP)
			springing = true
			interaction = true
			# Globals.playInterfaceAudio(global_position, "rbjump")

	if Input.is_action_just_released("ui_up") and inControl():
		doJump(isNowOnFloor)
		interaction = true

	if Input.is_action_just_released("ui_down") and inControl():
		if buildableArea != null:
			buildableArea.repair(upperside.global_position)
		doTeleport()
		var bitPosition: Vector2 = global_position
		bitPosition.y -= 128
		# takeDamage(2.0, underside.global_position)

	if Input.is_action_just_released("ui_select") and inControl():
		print("SELECT")
		if Globals.getBoolGamePropery("zap"):
			Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "Zap")
		if Globals.getBoolGamePropery("biZap"):
			Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "BigZap")


	# Allow steep surfaces to act as walkable floor when wall riding
	if nextToWall() and Globals.getBoolGamePropery("wallRide") and (rotation_degrees < -45 or rotation_degrees > 45):
		floor_max_angle = deg_to_rad(100)
	else:
		floor_max_angle = deg_to_rad(50)

	if not interaction and Globals.getBoolGamePropery("wallRide"):
		floor_max_angle = deg_to_rad(50)

	if springing:
		if currentJumpForce >= jumpPower:
			var changedJumpForce: float = (jumpPower / maxJumpChargeTime) * delta
			currentJumpForce += changedJumpForce

	doBlowUp(delta)
	doForces(delta)
	doAnimation(isNowOnFloor)
	doRotate(delta)
	move_and_slide()
	doCameraShake(delta)

	# Only sync velocity → xForce/yForce when NOT wall riding.
	# While on a wall, xForce is the along-wall speed and must be preserved
	# so calcAcceleration keeps working correctly next frame.
	if not isOnWallRide():
		xForce = velocity.x
		yForce = velocity.y

	if lastYForce - yForce < -30 and not isNowOnFloor:
		changeState(STATES.FALLING)
	if state == STATES.FALLING and isNowOnFloor:
		changeState(STATES.IDLE)
	if isNowOnFloor:
		jumpCounter = 0
	if not interaction and isNowOnFloor:
		doIdle(delta)

	lastYForce = yForce
	lastBlowUp = blowUp
	Globals.lastPosition = global_position

# ─── forces ───────────────────────────────────────────────────────────────────

func doForces(delta: float):
	if isOnWallRide():
		# Cancel gravity entirely while gripping the wall.
		yForce = 0.0

		# xForce (built by calcAcceleration / decelerate) drives movement
		# along the wall surface.  A small constant presses the character
		# into the wall so rayFront / rayBack keep detecting it as "floor".
		#
		# Right wall (rotation ≈ +90°):
		#   pressing right (xForce > 0) → velocity.y = -xForce → moves UP  ✓
		# Left wall (rotation ≈ -90°):
		#   pressing left  (xForce < 0) → velocity.y =  xForce → moves UP  ✓
		var wallPressForce: float = 150.0
		if rotation_degrees >= 45.0:
			# Right wall — press rightward, move vertically on xForce
			velocity.x = wallPressForce
			velocity.y = -xForce
		else:
			# Left wall — press leftward, move vertically on xForce (inverted)
			velocity.x = -wallPressForce
			velocity.y = xForce
	else:
		if magnetCounter>0 :
			yForce -= Globals.GRAVITY * delta
		else:
			yForce += Globals.GRAVITY * delta

		# Push character away from walls when wallRide is disabled
		if not Globals.getBoolGamePropery("wallRide") and nextToWall() and (not isOnFloor() or rotation_degrees >= 45 or rotation_degrees <= -45):
			if rayFacing.is_colliding():
				xForce -= 20
			else:
				xForce += 20
		# if hit the ground hard enough, bounce a little bit. Only if not wall riding, otherwise it gets weird.
		
		velocity.y = yForce
		
		velocity.x = xForce

# ─── rotation ─────────────────────────────────────────────────────────────────

func doRotate(delta: float):
	var maxRotation: float = 90.0 if Globals.getBoolGamePropery("wallRide") else 45.0

	# ── slope rotation from floor rays ──────────────────────────────────────
	if rayFront.is_colliding() and not rayBack.is_colliding():
		rotation_degrees -= 90.0 * delta
		rotation_degrees = clamp(rotation_degrees, -maxRotation, maxRotation)

	elif not rayFront.is_colliding() and rayBack.is_colliding():
		rotation_degrees += 90.0 * delta
		rotation_degrees = clamp(rotation_degrees, -maxRotation, maxRotation)

	else:
		# Both or neither ray hitting: drift back toward 0°
		if rotation_degrees > 0:
			rotation_degrees -= 90.0 * delta
		if rotation_degrees < 0:
			rotation_degrees += 90.0 * delta

	# ── wall ride: drive rotation TOWARD ±90° ───────────────────────────────
	# rayFacing   → detects the RIGHT wall → target +90°
	# rayFacingBack → detects the LEFT wall  → target -90°
	if Globals.getBoolGamePropery("wallRide") and nextToWall():
		if rayFacing.is_colliding() and not rayFacingBack.is_colliding():
			# Right wall — rotate toward +90°
			if rotation_degrees < 90.0:
				rotation_degrees += 90.0 * delta
			elif rotation_degrees > 90.0:
				rotation_degrees -= 90.0 * delta

		elif rayFacingBack.is_colliding() and not rayFacing.is_colliding():
			# Left wall — rotate toward -90°
			if rotation_degrees > -90.0:
				rotation_degrees -= 90.0 * delta
			elif rotation_degrees < -90.0:
				rotation_degrees += 90.0 * delta

# ─── jump ─────────────────────────────────────────────────────────────────────

func doJump(isNowOnFloor: bool):
	if isNowOnFloor or (Globals.getBoolGamePropery("doubleJump") and jumpCounter < 1) or Globals.getBoolGamePropery("jetPack"):
		if Globals.getBoolGamePropery("doubleJump") and jumpCounter < 2:
			currentJumpForce = jumpPower
			if (!isNowOnFloor):
				Globals.moveSparkEffect(underside.global_position, rotation, sprite.flip_h, "Smoke")

		if Globals.getBoolGamePropery("jetPack"):
			currentJumpForce = jumpPower / 2
		if (!isNowOnFloor):
				Globals.moveSparkEffect(underside.global_position, rotation, sprite.flip_h, "RedBloom")

		springing = false

		# Wall jump: kick the character AWAY from the wall.
		# currentJumpForce is negative, so:
		#   right wall (rotation > 0) → add negative = push LEFT  ✓
		#   left  wall (rotation < 0) → subtract negative = push RIGHT ✓
		if rotation_degrees >= 45 or rotation_degrees <= -45:
			currentJumpForce /= 2
			if rotation_degrees > 0:
				xForce += currentJumpForce  # pushes left
			else:
				xForce -= currentJumpForce  # pushes right
		if magnetCounter >0:
			yForce = -currentJumpForce
		else:
			yForce = currentJumpForce
		jumpCounter += 1
		currentJumpForce = 0.0
		changeState(STATES.JUMPING)

# ─── blow up (parachute) ──────────────────────────────────────────────────────

func doBlowUp(delta: float):
	if blowUp and not lastBlowUp:
		changeState(STATES.BLOWING)
		yForce -= 200
	if blowUp:
		yForce -= 2000 * delta

# ─── teleport ─────────────────────────────────────────────────────────────────

func doTeleport():
	if Globals.getBoolGamePropery("telePorter") and canTeleport:
		var teleport_distance = 400.0
		var target_x = position.x

		if sprite.flip_h:
			target_x -= teleport_distance
		else:
			target_x += teleport_distance

		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = Vector2(target_x, position.y)
		query.collision_mask = collision_mask

		var result = space_state.intersect_point(query)

		if result.is_empty():
			position.x = target_x
			velocity = Vector2.ZERO
			xForce = 0.0
			yForce = 0.0
			Globals.moveSparkEffect(global_position, rotation, sprite.flip_h, "TeleportSpark")
		else:
			var step = 50.0
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

# ─── idle ─────────────────────────────────────────────────────────────────────

func doIdle(delta: float):
	if not inControl():
		return
	changeState(STATES.IDLE)
	if state == STATES.IDLE:
		currentIdleTime += delta
		if not blowUp and currentIdleTime >= nextIdleTime:
			var randomValue: float = Globals.get_rand_between(0, 3)
			if randomValue < 1:
				currentAnimation = "WaitIdle1"
			elif randomValue < 2:
				currentAnimation = "WaitIdle2"
			else:
				currentAnimation = "WaitIdle3"
			currentIdleTime = 0.0
			nextIdleTime = Globals.get_rand_between(2, 6)

# ─── camera shake ─────────────────────────────────────────────────────────────

func doCameraShake(delta: float):
	if shakeStrength > 0:
		shakeStrength = max(shakeStrength - shakeDecay * delta, 0)
		var offset_x = randf_range(-1.0, 1.0) * shakeOfferSet.x * shakeStrength
		var offset_y = randf_range(-1.0, 1.0) * shakeOfferSet.y * shakeStrength
		camera.offset = Vector2(offset_x, offset_y)
	else:
		camera.offset = Vector2.ZERO
		
# ─── take damage ─────────────────────────────────────────────────────────────
func takeDamage(amount: float, sourceDirection: Vector2) -> void:
	if not invulnerable and inControl(): 
		animationPlayer.play("Damage")
		hitTimer.start()
		invulnerable = true
		# Apply knockback		
		var knockbackForce: Vector2 = (global_position - sourceDirection).normalized() * 500
		Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "NeckSpark")
		Globals.movePuffMachine(global_position, 0.05, 1)
		Globals.moveBitMachine(upperside.global_position, 0.05, (0.05 *amount))
		xForce += knockbackForce.x
		yForce += knockbackForce.y	
		var bits = Globals.getGamePropery(BITS)
		# print("bits before:"+str(bits))
		bits -= amount
		if bits <= 0:
			bits = 0
			doDeath()
		print("bits:"+str(bits))
		Globals.setGamePropery(BITS, bits)

func inControl() -> bool:
	return not birthing and not dying and not magneting

func _on_hit_timer_timeout() -> void:
	invulnerable=false
	if  inControl():
		animationPlayer.play("Normal")

func doDeath() -> void:
	dying = true
	dyingTimer.start()
	if Globals.get_random_four() <=2:
		animationPlayer.play("Death1")
	else:	
		animationPlayer.play("Death2")
	Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "Smoke")


func _on_dying_timer_timeout() -> void:
	dying=false
	dyingTimer.stop()
	startBirth()


func _on_birth_timer_timeout() -> void:
	birthing=false
	dying=false
	birthTimer.stop()
	changeState(STATES.IDLE)


func magOn() -> void:
	magnetTimer.start()
	magneting = true
	animationPlayer.play("Magenet")
	Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "TeleportSpark")

func magOff() -> void:
	magnetTimer.start()
	magneting = true
	animationPlayer.play("MagenetOff")
	Globals.moveSparkEffect(global_position, rotation, $Sprite2D.flip_h, "TeleportSpark")

func _on_mag_timer_timeout() -> void:
	magnetTimer.stop()
	magneting=false

func fix() -> void:
	# birthing=true
	animationPlayer.play("FaceForward")	
