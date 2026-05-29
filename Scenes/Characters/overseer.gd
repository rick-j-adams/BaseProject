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
	animationTree.set("parameters/conditions/point", false)
	animationTree.set("parameters/conditions/work", false)
	animationTree.set("parameters/conditions/unpoint", false)
	animationTree.set("parameters/conditions/idleOut", false)


func _on_area_2d_right_body_exited(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			resetAllAnimationTree()
			animationTree.set("parameters/conditions/unlook", true)


func _on_area_2d_right_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			resetAllAnimationTree()
			animationTree.set("parameters/conditions/emerge", true)
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
			dydimoInRange=body
			fixTimer.wait_time= 2.0
			fixTimer.start()

func _on_area_2d_fix_body_exited(body: Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			dydimoInRange=null
			fixTimer.stop()
			resetAllAnimationTree()
			animationTree.set("parameters/conditions/endwork", true)

func _on_fix_timer_timeout() -> void:
	fixTimer.stop()
	if dydimoInRange != null:	
		resetAllAnimationTree()
		animationTree.set("parameters/conditions/emerge", true)
		animationTree.set("parameters/conditions/work", true)
		dydimoInRange.fix()
