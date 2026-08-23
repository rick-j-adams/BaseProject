extends CharacterBody2D

enum TYPE {SNAKE, VIRUS, THREAT}


@onready var timer:Timer = $Timer 
@onready var sprite:Sprite2D = $Sprite2D 

@export var colour: Color = Color.WHITE
@export var type: TYPE= TYPE.SNAKE



const SPEED = 150.0
const JUMP_VELOCITY = -400.0



var direction:int = 1 
var upDownDirection = 1
var changeState = false

func _ready() -> void:
	modulate=colour

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and  type != TYPE.VIRUS:
		velocity += get_gravity() * delta

	if type == TYPE.THREAT and is_on_floor():
		velocity.y = JUMP_VELOCITY


	if direction:
		velocity.x = direction * SPEED	
	else:
		velocity.x = move_toward(velocity.x,0, SPEED)

	if upDownDirection:
		if type == TYPE.VIRUS:
			velocity.y = upDownDirection * SPEED	
	else:
		velocity.y = move_toward(velocity.y,0, SPEED)
		
	if direction > 0:
		sprite.flip_h=false
	else:
		sprite.flip_h=true	


	if is_on_wall():
		if not changeState:
			timer.wait_time = 1.0
			timer.start()
			changeState=true
			direction=direction*-1
			#upDownDirection=upDownDirection*-1
	
	if type == TYPE.VIRUS:
		if is_on_ceiling(): 
			upDownDirection=1	
		if  is_on_floor():
			upDownDirection=-1
		

	move_and_slide()


func _on_timer_timeout() -> void:
	changeState=false
	timer.stop()
	
func kill():
	Globals.requestExplodeAt(modulate,position)
	queue_free()


func _on_kill_area_2d_body_entered(body: Node2D) -> void:
	if body is DotBot:
		body.bounceUp()
		kill()
		


func _on_hit_area_2d_body_entered(body: Node2D) -> void:
	if body is DotBot:
		body.bounceUp()
		body.die()
