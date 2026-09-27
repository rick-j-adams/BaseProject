extends StaticBody2D

class_name Noga


enum STATES {INTRO, HIDDEN, RISING, SEARCHING, ZAPPINGR, ZAPPINGL, FALLING, DEAD}

var currentState : STATES = STATES.INTRO

@onready var animationPlayerFrames :AnimationPlayer = $AnimationPlayerFrames
@onready var animationPlayerMovement :AnimationPlayer = $AnimationPlayerMovement
@onready var animationPlayerZapp :AnimationPlayer = $AnimationPlayerZapp
@onready var animationPlayerTakeDamge :AnimationPlayer = $AnimationPlayerTakeDamge
@onready var rPointLight1 :RPoint  = $Sprite2DNoga/RPointLight1
@onready var rPointLight2 :RPoint  = $Sprite2DNoga/RPointLight2
@onready var zapSprite :Sprite2D  = $Sprite2DNoga/Sprite2DZapper
@onready var rPointfinal : RPoint = $Node2D/RPoint
@onready var box1: GoodyBox = $Node2D/Box1
@onready var box2: GoodyBox = $Node2D/Box2

@onready var timer :Timer = $Timer
@onready var timerHitTimer :Timer = $TimerHitTimer


var rand:int = 1
var health:float = 5

var seenLeft:bool=false
var seenRight:bool=false
var takenDamge = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currentState == STATES.SEARCHING:
		if seenLeft :
			fireLeft()
		if seenRight:
			fireRight()


func _on_timer_timeout() -> void:
	# timer.stop()
	if currentState == STATES.INTRO:
		startIntro()
		return
	if currentState == STATES.HIDDEN:	
		var number:int = Globals.get_next_rand()
		rand = number%3
		rise()
		return
	if currentState == STATES.RISING:
		search()
		return	
	if currentState == STATES.SEARCHING:
		hideAway("")
		return
	if currentState == STATES.ZAPPINGR:
		hideAway("")
		return
	if currentState == STATES.ZAPPINGL:
		hideAway("Lef")
		return
	if currentState == STATES.DEAD:
		finalDeath()
		return
	# timer.start()


func hideAway(facing:String) -> void:
	animationPlayerFrames.play("RunAway"+facing)
	animationPlayerMovement.play("Run"+str(rand))
	animationPlayerZapp.play("off")
	currentState=STATES.HIDDEN
	print("to STATES.HIDDEN (at)"+str(rand))
	timer.wait_time = Globals.get_rand_between(2.0,5.0)

func search() -> void:
	animationPlayerFrames.play("LookRight")
	currentState=STATES.SEARCHING
	print("to STATES.SEARCHING")
	timer.wait_time= Globals.get_rand_between(0.8,1.0)

func rise() -> void:
	animationPlayerFrames.play("Rise")
	animationPlayerMovement.play("Rise"+str(rand))
	animationPlayerZapp.play("off")	
	currentState=STATES.RISING
	print("to STATES.RISING (at)"+str(rand))
	timer.wait_time= Globals.get_rand_between(1.0,1.1)

func startIntro()-> void:
	animationPlayerFrames.play("Intro")
	animationPlayerMovement.play("Intro")
	animationPlayerZapp.play("off")
	currentState=STATES.HIDDEN
	print("to STATES.HIDDEN")
	Globals.playAudioAt(global_position, "bossHorn2")
	Globals.playAmbienceAudio("boss1Music")
	timer.wait_time= Globals.get_rand_between(1.0,5.0)
	
func fireRight() ->void:
	animationPlayerFrames.play("SurpriseRight")
	animationPlayerZapp.play("FireRight")
	timer.wait_time= Globals.get_rand_between(0.5,0.8)
	currentState=STATES.ZAPPINGR
	timer.start()

func fireLeft() ->void:
	animationPlayerFrames.play("SurpriseLeft")
	animationPlayerZapp.play("FireLeft")
	timer.wait_time= Globals.get_rand_between(0.5,0.8)
	currentState=STATES.ZAPPINGL
	timer.start()


func _on_area_2d_look_right_body_entered(body: Node2D) -> void:
	if body is Dydimo:	
		if currentState == STATES.INTRO:			
			timer.wait_time=2
			timer.start()
		seenRight=true	


func _on_area_2s_look_left_body_entered(body: Node2D) -> void:
	if body is Dydimo:	
		if currentState == STATES.INTRO:	
			timer.wait_time=2
			timer.start()
		seenLeft=true
	

func _on_area_2d_look_right_body_exited(body: Node2D) -> void:
	if body is Dydimo:	
		seenRight=false

func _on_area_2s_look_left_body_exited(body: Node2D) -> void:
	if body is Dydimo:	
		seenLeft=false

func requestLighting() -> void:
	Globals.requestTempLight(zapSprite.global_position, TempLight.LightType.LIGHTNING)

func requestRedLight1() -> void:
	Globals.requestTempLight(rPointLight1.global_position,TempLight.LightType.FLAME )

func requestRedLight2() -> void:
	Globals.requestTempLight(rPointLight2.global_position,TempLight.LightType.FLAME )

func doTouchDamge(body:Dydimo)->void:
	if not takenDamge:
		body.takeDamage(1,global_position,false)

func doLightningDamge(body:Dydimo)->void:
	Globals.moveSparkEffect(global_position, rotation, body.sprite.flip_h, "TeleportSpark")
	body.takeDamage(1,global_position,false)
		
func requestZapper() -> void:
	Globals.playAudioAt(global_position, "bugzapper")

func doTakeDamage(body:Dydimo)->void:
	Globals.playAudioAt(global_position, "bonk")
	animationPlayerTakeDamge.play("TakeDamge")
	body.shakeStrength=2
	body.launchInAir()
	takenDamge=true
	timerHitTimer.start()
	Globals.movePuffMachine(global_position, 0.05, 0.5)
	Globals.moveSparkEffect(global_position, rotation, body.sprite.flip_h, "RedBloom")
	health=health-1
	if health<=0:
		doDeath()
	# print("health:"+str(health))

func doDeath() -> void:
	currentState = STATES.DEAD
	animationPlayerFrames.play("RunAway")
	animationPlayerMovement.play("Run"+str(rand))
	animationPlayerZapp.play("off")
	timer.wait_time = Globals.get_rand_between(0.8,1.0)
	watchFinalDeath()

func finalDeath() -> void:
	animationPlayerFrames.play("Die")
	animationPlayerMovement.play("Die")
	animationPlayerZapp.play("Die")
	
	timer.stop()

func destroyBoxes() ->void:
	box1.destroy()
	box2.destroy()

func watchFinalDeath():
	if Globals.mainCamera != null :
		Globals.mainCamera.peakAt(rPointfinal.global_position, 2.0)
		Globals.playAudioAt(rPointLight1.global_position, "crash")
	Globals.playAmbienceAudio("ambience1")

func _on_area_2d_body_dmg_1_body_entered(body: Node2D) -> void:
	if body is Dydimo:
		doTouchDamge(body)
		
func _on_area_2d_body_dmg_2_body_entered(body: Node2D) -> void:
	if body is Dydimo:
		doTouchDamge(body)

func _on_area_2d_body_dmg_3_body_entered(body: Node2D) -> void:
	if body is Dydimo:
		doTouchDamge(body)

func _on_area_2d_weak_point_2_body_entered(body: Node2D) -> void:
	if body is Dydimo:
		doTakeDamage(body)

func _on_area_2d_weak_point_1_body_entered(body: Node2D) -> void:
	if body is Dydimo:
		doTakeDamage(body)

func _on_timer_hit_timer_timeout() -> void:
	if currentState!=STATES.DEAD:
		takenDamge=false
	timerHitTimer.stop()
	
func _on_area_2d_dmg_body_entered(body: Node2D) -> void:
	if body is Dydimo:
		doLightningDamge(body)
