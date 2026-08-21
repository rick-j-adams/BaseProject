extends CharacterBody2D

class_name Enemy

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var rPointDmg: RPoint = $RPointDmg


enum STATES {BIRTH, IDLE, SEARCH, MOVE, ATTACKING, DYING}
var state : STATES = STATES.BIRTH

var destination: Vector2 = Vector2.ZERO

var dydimoSeen: Dydimo = null
var sparePartSeen: SpareParts = null

var dydimoDmg: Dydimo = null
var sparePartDmg: SpareParts = null

@onready var parts: Node2D = $Parts
@onready var timer: Timer = $Timer

@export var levelId: int = 0

@export var health: float = 5.0
@export var speed: float = 300.0
@export var flying: bool = false
@export var touchDamage: int = 1
@export var weakpointDamage:int = 1
@export var attackDamage: int = 2

# Movement improvements
@export var acceleration: float = 1500.0
@export var deceleration: float = 1200.0
@export var stoppingDistance: float = 15.0
var targetVelocity: Vector2 = Vector2.ZERO

var facingRight: bool = true

func _ready():
	animateParts("Birth")
	var childeren = parts.get_children()
	for child in childeren:
		if child is EnemyPart:
			child.parentEnemy = self

func switchToIdle():
	state = STATES.IDLE
	timer.wait_time = Globals.get_rand_between(0.5, 3.5)
	timer.start()

func switchToSearch():
	state = STATES.SEARCH
	timer.wait_time = Globals.get_rand_between(1.0, 4.0)
	timer.start()
	animationPlayer.play("Search")

func _process(delta: float) -> void:
	match state:
		STATES.BIRTH:
			if not timer.is_stopped():
				return
			switchToIdle()			
			animateParts("Birth")
		STATES.IDLE:
			if dydimoSeen != null or sparePartSeen != null:
				state = STATES.MOVE
				animateParts("Move")
			
		STATES.SEARCH:
			pass
		STATES.MOVE:
			var direction: Vector2 = (destination - global_position).normalized()
			var distanceToTarget: float = global_position.distance_to(destination)
			
			# Check if reached destination
			if distanceToTarget < stoppingDistance:
				state = STATES.IDLE
				velocity = Vector2.ZERO
				targetVelocity = Vector2.ZERO
				switchToIdle()
				animateParts("Idle")
			else:
				# Set target velocity
				if flying:
					targetVelocity = direction * speed
				else:
					targetVelocity.x = direction.x * speed
					targetVelocity.y = 0  # Let gravity handle vertical movement
				
				# Smooth acceleration towards target velocity
				var accel = acceleration if velocity.length() < speed else deceleration
				if flying:
					velocity = velocity.lerp(targetVelocity, accel * delta / speed)
				else:
					velocity.x = move_toward(velocity.x, targetVelocity.x, accel * delta)
					velocity.y += Globals.GRAVITY * delta
		STATES.DYING:
			return
			
	velocity.y += Globals.GRAVITY * delta
	if flying:
		if velocity.y > 5.0:
			velocity.y = -4.0
		animationPlayer.play("Move")
		# velocity = velocity.lerp(targetVelocity, acceleration * delta / speed)
	
	move_and_slide()
	

func animateParts(animationName: String):
	var childeren = parts.get_children()
	for child in childeren:
		if child is EnemyPart:
			child.playPartAnimation(animationName)

func setDestinationToBody(newDestination: Vector2):
	destination = newDestination
	state = STATES.MOVE
	targetVelocity = Vector2.ZERO
	if destination.x > global_position.x:
		facingRight = true
		animationPlayer.play("FlipRight")
	else:
		facingRight = false
		animationPlayer.play("FlipLeft")
	animateParts("Move")

func seenBody(body:Node2D):
	if state == STATES.DYING:
		return
	if body is Dydimo:
		dydimoSeen = body
		setDestinationToBody(body.global_position)
	elif body is SpareParts:
		sparePartSeen = body
		setDestinationToBody(body.global_position)

func lostSightOfBody(body:Node2D):
	if state == STATES.DYING:
		return
	if body is Dydimo:
		dydimoSeen = null
	elif body is SpareParts:
		sparePartSeen = null
	state = STATES.IDLE
	targetVelocity = Vector2.ZERO
	velocity.x = 0  # Only stop horizontal movement; gravity still applies for ground enemies
	switchToIdle()
	animateParts("Idle")

func doTouchDamage(body: Node2D):
	if state == STATES.DYING:
		return
	if body is Dydimo:
		body.takeDamage(touchDamage, global_position, false)
	elif body is SpareParts:
		body.destroy()

func takeDamage(body:Node2D):
	receieveDamage(body, true, weakpointDamage)

func receieveDamage(body:Node2D, bounceBack: bool, amount: float ):
	if state == STATES.DYING:
		return
	if body is Dydimo:
		health -= amount
		if health <= 0:
			die(body)
		else:
			Globals.movePuffMachine(global_position, 0.05, 0.5)
			var childeren = parts.get_children()
			for child in childeren:
				if child is EnemyPart:
					child.playDamageAnimation()
		if bounceBack:
			body.launchInAir()

func getNumberOfParts() -> float:
	
	return 0.4

func die(body:Node2D):
	state = STATES.DYING	
	# set_collision_layer_value(1, false)
	set_collision_layer_value(1, false)
	Globals.movePuffMachine(global_position, 0.5, 0.5)
	Globals.moveBitMachine(global_position, 0.1, getNumberOfParts())
	# Globals.moveBitMachine(global_position, 0.1, 0.4)

	Globals.moveSparkEffect(global_position, rotation, facingRight, "RedBloom")
	var childeren = parts.get_children()
	timer.wait_time = 2.0
	timer.start()
	Globals.requestTempLight(global_position, TempLight.LightType.WHITE_EXPLODE)
	for child in childeren:
		if child is EnemyPart:
			child.die()
	if body is Dydimo:
		body.shakeStrength = 2.0

func setInDamage(body:Node2D):
	if state == STATES.DYING:
		return
	if body is Dydimo:
		dydimoDmg = body
		doAttack()
	elif body is SpareParts:
		sparePartDmg = body
		doAttack()
	
func unSetInDamage(body:Node2D):
	if state == STATES.DYING:
		return
	if body is Dydimo:
		dydimoDmg = null
	elif body is SpareParts:
		sparePartDmg = null
	state = STATES.IDLE
	targetVelocity = Vector2.ZERO
	velocity.x = 0
	animateParts("Idle")
	if dydimoSeen != null or sparePartSeen != null:
		state = STATES.MOVE
		animateParts("Move")

func doAttack():
	if state == STATES.DYING:
		return
	state = STATES.ATTACKING
	targetVelocity = Vector2.ZERO
	velocity.x = 0
	animateParts("Attack")

func doDamage():
	if state == STATES.DYING:
		return
	if dydimoDmg != null:
		dydimoDmg.takeDamage(touchDamage, rPointDmg.global_position, false)
		Globals.movePuffMachine( rPointDmg.global_position, 0.5, 0.5)
	elif sparePartDmg != null:
		sparePartDmg.destroy()
		Globals.movePuffMachine( rPointDmg.global_position, 0.5, 0.5)

func _on_area_2d_damage_box_body_exited(body:Node2D) -> void:
	unSetInDamage(body)

func _on_area_2d_vision_body_exited(body:Node2D) -> void:
	lostSightOfBody(body)


func _on_area_2d_vision_body_entered(body:Node2D) -> void:
	seenBody(body)

func _on_area_2d_damage_box_body_entered(body:Node2D) -> void:
	setInDamage(body)

func _on_area_2d_touch_damage_body_entered(body:Node2D) -> void:
	doTouchDamage(body)

func _on_area_2d_weak_point_body_entered(body:Node2D) -> void:
	takeDamage(body)

func _on_timer_timeout() -> void:
	if state == STATES.IDLE:
		animateParts("IdleMove")
		var seach = Globals.get_rand_between(0.0, 1.0)
		if seach < 0.5:
			switchToSearch()
		else:
			switchToIdle()
		return
	if state == STATES.SEARCH:
		switchToIdle()
		return
	if state == STATES.DYING:
		Globals.addToCullList(levelId)
		queue_free()
	
