extends CharacterBody2D

class_name Bit

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var collisionShape2D :CollisionShape2D = $CollisionShape2D
@onready var timer :Timer = $Timer
@onready var rollTimer :Timer = $RollTimer
@onready var grabTimer :Timer = $GrabTimer



@export var isOn : bool = false
@export var isWaiting : bool = false
@export var isPayment: bool = false
var canGrab = false
var paymentDestination : Vector2 = Vector2.ZERO

@export var bitType : int = 0

const OUT_OFF_WAY : Vector2 = Vector2(-1000000000, -1000000000)
const FLY_ANIMATION = "Fly"
const WAIT_ANIMATION = "Wait"
const BITS = "bits"

var maxSpeed : float = 800.0

var animationName = FLY_ANIMATION + str(bitType)

var repool = false

func _ready() -> void:
	stand_by()

func stand_by() -> void:
	isOn = false
	isWaiting = false
	isPayment = false
	repool = true
	collision_layer = 16
	collision_mask = 16
	animationPlayer.play("White")
	
	

func rerepool() -> void:
	repool = false
	global_position = OUT_OFF_WAY	
	

func _process(delta: float) -> void:
	if repool:
		rerepool()	
		return
	if isOn:
		var yBefore: float = velocity.y	
		if not isPayment:
			velocity.y=velocity.y+Globals.GRAVITY *delta
		else:
			var direction = (paymentDestination - global_position).normalized()
			velocity = velocity + ( direction * maxSpeed *delta)
		move_and_slide()	
		if not isWaiting:
			if yBefore > 0 and velocity.y <= 0:
				velocity.y = -yBefore/2			#if velocity is nearin zero then stop and play animation
			if not isPayment and velocity.length() < 10:
				changeToWait()
			if isPayment and global_position.distance_to(paymentDestination) < 50:
				doPayment()
				
				
func doPayment() -> void:
	isPayment = true
	stand_by()
	var bits = Globals.getGamePropery(BITS)
	bits -= 1
	Globals.setGamePropery(BITS, bits)

func changeToWait() -> void:
	velocity = Vector2.ZERO
	isWaiting = true
	animationName = WAIT_ANIMATION + str(bitType+1)
	animationPlayer.play(animationName)

	if Globals.closeTo(global_position):
		pickUp()


func moveBitPayment(setPosition: Vector2, setDestination: Vector2) -> void:
	isPayment = true
	paymentDestination = setDestination
	moveBit(setPosition)
	animationPlayer.play("Yellow")
	var direction = ( global_position - paymentDestination).normalized()
	velocity =  ( direction  )
	

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
	rollTimer.wait_time = 3.0
	rollTimer.start()
	canGrab=false
	grabTimer.wait_time=0.5
	grabTimer.start()

func pickUp() -> void:
	Globals.createPuff(global_position)
	Globals.moveSparkEffect(global_position, 0, false, "VolumeBloom")
	stand_by()
	var bits = Globals.getGamePropery(BITS)
	bits += 1
	if bits > Globals.getMaxHealth():
		bits = Globals.getMaxHealth()
		Globals.maxHealthHud()
	Globals.setGamePropery(BITS, bits)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			if isOn and (isWaiting or canGrab) and not isPayment:
				pickUp()
			
				

func _on_timer_timeout() -> void:
	Globals.createPuff(global_position)
	Globals.moveSparkEffect(global_position, 0, false, "Bloom")
	stand_by()


func _on_roll_timer_timeout() -> void:
	if isPayment:
		doPayment()
	else:
		changeToWait()


func _on_grab_timer_timeout() -> void:
	canGrab=true
