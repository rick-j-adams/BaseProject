extends CharacterBody2D

class_name DotBot

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var sprite:Sprite2D = $Sprite2D 
@onready var timerDying:Timer = $TimerDying 
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer 



var isDead=false

func _physics_process(delta: float) -> void:
	if isDead:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		animationPlayer.play("PrepJump")
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction > 0:
		sprite.flip_h=false
	else:
		sprite.flip_h=true	

	if not animationPlayer.is_playing():
		
		if not is_on_floor():
			if velocity.y < 0:
				animationPlayer.play("JumpUp")
			if velocity.y > 0:
				animationPlayer.play("FallDown")
		elif  velocity.x > 0 or velocity.x  < 0: 
			animationPlayer.play("Walk")
		else:
			animationPlayer.play("Idle")
		 

	move_and_slide()

func bounceUp() -> void:
	velocity.y=-200

func bounceUpHard() -> void:
	velocity.y=-800


func die() ->void:
	timerDying.start()
	visible=false
	Globals.requestExplodeAt(modulate,position)


func _on_timer_dying_timeout() -> void:
	timerDying.stop()
	var parent:FastTravelMap = get_parent()
	if parent!=null:
		parent.doStartPosition()
	visible=true
