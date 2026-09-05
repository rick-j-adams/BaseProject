extends Node2D
class_name Overseer

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var animationTree : AnimationTree = $AnimationTree

@onready var idleTimer : Timer = $IdleTimer
@onready var fixTimer : Timer = $FixTimer

var dydimoInRange : Dydimo = null

func _ready() -> void:
	animationTree.active = true
	idleTimer.wait_time= Globals.get_rand_between(6, 15)
	idleTimer.start()

func resetAllAnimationTree():
	pass
	animationTree.set("parameters/conditions/lookright", false)
	animationTree.set("parameters/conditions/lookleft", false)
	animationTree.set("parameters/conditions/unlook", false)
	animationTree.set("parameters/conditions/emerge", false)
	animationTree.set("parameters/conditions/unemerge", false)
	animationTree.set("parameters/conditions/build", false)
	animationTree.set("parameters/conditions/endwork", false)
	animationTree.set("parameters/conditions/doPoint", false)
	animationTree.set("parameters/conditions/work", false)
	animationTree.set("parameters/conditions/unPoint", false)
	animationTree.set("parameters/conditions/idleOut", false)
	animationTree.set("parameters/conditions/screenBattery", false)
	animationTree.set("parameters/conditions/screenZap", false)
	animationTree.set("parameters/conditions/screenDown", false)
	animationTree.set("parameters/conditions/screenUp", false)
	animationTree.set("parameters/conditions/screenJump", false)
	animationTree.set("parameters/conditions/screenLeave", false)
	animationTree.set("parameters/conditions/screenLiftPower", false)
	animationTree.set("parameters/conditions/screenLiftBlocked", false)


func _on_area_2d_right_body_exited(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			resetAllAnimationTree()
			
			animationTree.set("parameters/conditions/unlook", true)
			animationTree.set("parameters/conditions/unPoint", true)

func doPoint() -> bool:
	var currentObject:String = Globals.getCurrentObjective()
	if currentObject=="battery":
		animationTree.set("parameters/conditions/screenBattery", true)
		return true
	if currentObject=="jumpboard":
		animationTree.set("parameters/conditions/screenJump", true)
		return true
	if currentObject=="firstfix":
		animationTree.set("parameters/conditions/screenDown", true)
		return true
	if currentObject=="firstjump":
		animationTree.set("parameters/conditions/screenUp", true)
		return true
	if currentObject=="zapBoard":
		animationTree.set("parameters/conditions/screenZap", true)
		return true
	if currentObject=="clearPath":
		animationTree.set("parameters/conditions/screenLeave", true)
		return true
	if currentObject=="fixLift":
		animationTree.set("parameters/conditions/screenLiftPower", true)
		return true
	if currentObject=="fixClearBlockage":
		animationTree.set("parameters/conditions/screenLiftBlocked", true)
		return true
	return false
	# "battery" : { "done" :false},
	# 		"jumpboard" : { "done" :false},
	# 		"firstfix" : { "done" :false},
	# 		"firstjump" : { "done" :false},
	# 		"zapBoard" : { "done" :false},


func _on_area_2d_right_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			resetAllAnimationTree()
			animationTree.set("parameters/conditions/emerge", true)
			if doPoint():
				animationTree.set("parameters/conditions/doPoint", true)
			else:
				animationTree.set("parameters/conditions/lookright", true)
			
			


func _on_area_2d_left_body_exited(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			resetAllAnimationTree()
			animationTree.set("parameters/conditions/unlook", true)

func _on_area_2d_left_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			resetAllAnimationTree()
			animationTree.set("parameters/conditions/emerge", true)
			animationTree.set("parameters/conditions/lookleft", true)

func _on_area_2d_in_range_body_exited(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			resetAllAnimationTree()
			animationTree.set("parameters/conditions/unemerge", true)



func _on_idle_timer_timeout() -> void:
	var random = Globals.get_rand_between(6, 15)
	idleTimer.wait_time= Globals.get_rand_between(6, 15)
	idleTimer.start()
	if dydimoInRange == null and random>10 : 
		resetAllAnimationTree()
		animationTree.set("parameters/conditions/emerge", true)
		animationTree.set("parameters/conditions/idleOut", true)
		animationTree.set("parameters/conditions/unlook", true)

func _on_area_2d_fix_body_entered(body: Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			body.inOverseerRange = true
			dydimoInRange=body
			fixTimer.wait_time= 0.5
			if dydimoInRange.currentAnimation == "Birth":
				animationTree.set("parameters/conditions/emerge", true)
				animationTree.set("parameters/conditions/build", true)
			fixTimer.start()

func _on_area_2d_fix_body_exited(body: Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			dydimoInRange=null
			body.inOverseerRange = false
			fixTimer.stop()
			resetAllAnimationTree()
			animationTree.set("parameters/conditions/endwork", true)

func _on_fix_timer_timeout() -> void:
	fixTimer.stop()
	if dydimoInRange != null:	
		resetAllAnimationTree()
		
		animationTree.set("parameters/conditions/work", true)
		animationTree.set("parameters/conditions/emerge", true)
		
		
		# dydimoInRange.fix()

func requestLight() -> void:
	Globals.requestTempLight(global_position, TempLight.LightType.LIGHTNING)