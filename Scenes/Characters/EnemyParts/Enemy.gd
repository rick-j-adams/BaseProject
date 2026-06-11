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

@export var health: int = 5
@export var speed: float = 300.0
@export var flying: bool = false
@export var touchDamage: int = 1
@export var weakpointDamage:int = 1
@export var attackDamage: int = 2

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
			if flying:
				velocity = direction * speed
			else:
				velocity.x = direction.x * speed
			
			if global_position.distance_to(destination) < 5.0:
				state = STATES.IDLE
				velocity = Vector2.ZERO
				switchToIdle()
				animateParts("Idle")
		STATES.DYING:
			return
			
	velocity.y += Globals.GRAVITY * delta
	move_and_slide()
	

func animateParts(animationName: String):
	var childeren = parts.get_children()
	for child in childeren:
		if child is EnemyPart:
			child.playPartAnimation(animationName)

func setDestinationToBody(newDestination: Vector2):
	destination = newDestination
	state = STATES.MOVE
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
	velocity = Vector2.ZERO
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
	if state == STATES.DYING:
		return
	if body is Dydimo:
		health -= weakpointDamage
		if health <= 0:
			die(body)
		else:
			Globals.movePuffMachine(global_position, 0.05, 0.5)
			var childeren = parts.get_children()
			for child in childeren:
				if child is EnemyPart:
					child.playDamageAnimation()
		body.yForce -= 1000	

func die(body:Node2D):
	state = STATES.DYING	
	# set_collision_layer_value(1, false)
	set_collision_layer_value(1, false)
	var duration :float = 0.2 * health
	Globals.movePuffMachine(global_position, 0.5, 0.5)
	Globals.moveBitMachine(global_position, 0.1, duration)
	Globals.moveSparkEffect(global_position, rotation, facingRight, "RedBloom")
	var childeren = parts.get_children()
	timer.wait_time = 2.0
	timer.start()
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
	animateParts("Idle")
	if dydimoSeen != null or sparePartSeen != null:
		state = STATES.MOVE
		animateParts("Move")

func doAttack():
	if state == STATES.DYING:
		return
	state = STATES.ATTACKING
	velocity = Vector2.ZERO
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
		queue_free()
	
