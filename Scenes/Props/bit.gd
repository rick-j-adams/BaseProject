extends CharacterBody2D

class_name Bit

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var collisionShape2D :CollisionShape2D = $CollisionShape2D
@onready var timer :Timer = $Timer
@onready var rollTimer :Timer = $RollTimer


@export var isOn : bool = false
@export var isWaiting : bool = false
@export var bitType : int = 0

const OUT_OFF_WAY : Vector2 = Vector2(-1000000000, -1000000000)
const FLY_ANIMATION = "Fly"
const WAIT_ANIMATION = "Wait"

var maxSpeed : float = 800.0

var animationName = FLY_ANIMATION + str(bitType)

var repool = false

func _ready() -> void:
	stand_by()

func stand_by() -> void:
	isOn = false
	isWaiting = false
	repool = true
	collision_layer = 16
	collision_mask = 16
	
	

func rerepool() -> void:
	repool = false
	global_position = OUT_OFF_WAY	
	

func _process(delta: float) -> void:
	if repool:
		rerepool()	
		return
	if isOn:
		var yBefore: float = velocity.y	
		velocity.y=velocity.y+Globals.GRAVITY *delta
		move_and_slide()	
		if not isWaiting:
			if yBefore > 0 and velocity.y <= 0:
				velocity.y = -yBefore/2			#if velocity is nearin zero then stop and play animation
			if velocity.length() < 10:
				changeToWait()
				
				
				
func changeToWait() -> void:
	velocity = Vector2.ZERO
	isWaiting = true
	animationName = WAIT_ANIMATION + str(bitType+1)
	animationPlayer.play(animationName)

func moveBit(setPosition: Vector2) -> void:
	global_position = setPosition
	bitType = Globals.get_random_four()
	velocity.x = Globals.get_rand_between(-maxSpeed, maxSpeed)
	velocity.y = Globals.get_rand_between(-maxSpeed, 0)
	animationName = FLY_ANIMATION + str(bitType+1)
	animationPlayer.play(animationName)
	isOn = true
	isWaiting = false
	visible = true
	collision_layer = 2
	collision_mask = 2
	timer.wait_time = 10
	timer.start()
	rollTimer.wait_time = 3
	rollTimer.start()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			if isOn and isWaiting:
				Globals.createPuff(global_position)
				Globals.moveSparkEffect(global_position, 0, false, "VolumeBloom")
				stand_by()
				body.bitCounter += 1
				#print("Bit Counter: ", body.bitCounter)


func _on_timer_timeout() -> void:
	Globals.createPuff(global_position)
	Globals.moveSparkEffect(global_position, 0, false, "Bloom")
	stand_by()


func _on_roll_timer_timeout() -> void:
	changeToWait()
