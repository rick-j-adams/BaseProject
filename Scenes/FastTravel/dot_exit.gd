extends Node2D

class_name DotExit 
@onready var timer:Timer = $Timer 
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer 
@onready var loadInPoint:RPoint = $LoadingPoint 


@export var oid = -1
@export var destinationLevel = "E2"
@export var destinationOid = -1

var readyBody = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_start_exit_body_entered(body:Node2D) -> void:

	if body is DotBot:
		animationPlayer.play("exit")
		timer.start()
		readyBody=body

func _on_area_2d_start_exit_body_exited(body:Node2D) -> void:
	if body is DotBot:
		readyBody=null


func _on_timer_timeout() -> void:
	timer.stop()
	if readyBody !=null:
		readyBody.bounceUpHard()


func _on_area_2d_finish_exit_body_entered(body: Node2D) -> void:
	if body is DotBot:
		print("TODO load: level: "+ str(destinationLevel)+" OID:"+str(destinationOid))
		Globals.transitionToBuildable(destinationLevel,destinationOid)
