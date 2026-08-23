extends Node2D

class_name FastTravelMap

@onready var roomArea1 : Area2D = $Areas/Room1
@onready var roomArea2 : Area2D = $Areas/Room2
@onready var roomArea3 : Area2D = $Areas/Room3
@onready var roomArea4 : Area2D = $Areas/Room4
@onready var roomArea5 : Area2D = $Areas/Room5
@onready var roomArea6 : Area2D = $Areas/Room6
@onready var roomArea7 : Area2D = $Areas/Room7
@onready var roomArea8 : Area2D = $Areas/Room8
@onready var roomArea9 : Area2D = $Areas/Room9

@onready var dotPlosion : Node2D = $DotPlosion
@onready var entriesAndExits : Node2D = $EntriesAndExits

@onready var dottyBot : DotBot = $DotBot

@onready var camera2D: Camera2D = $Camera2D

const SPEED = 1200.0

var cameraDestination = Vector2(474.0, 257.0)


var moveCamera :bool= true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.dotPosion=dotPlosion


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moveCamera:
		camera2D.position = camera2D.position.move_toward(cameraDestination,  SPEED * delta)
		# velocity.x = move_toward(velocity.x, 0, SPEED)


func _on_room_1_body_entered(body:Node2D) -> void:
	if body is DotBot:
		cameraDestination = roomArea1.position
		moveCamera= true

func _on_room_9_body_entered(body:Node2D) -> void:
	if body is DotBot:
		cameraDestination = roomArea9.position
		moveCamera= true



func _on_room_8_body_entered(body:Node2D) -> void:
	if body is DotBot:
		cameraDestination = roomArea8.position
		moveCamera= true


func _on_room_7_body_entered(body:Node2D) -> void:
	if body is DotBot:
		cameraDestination = roomArea7.position
		moveCamera= true


func _on_room_6_body_entered(body:Node2D) -> void:
	if body is DotBot:
		cameraDestination = roomArea6.position
		moveCamera= true


func _on_room_5_body_entered(body:Node2D) -> void:
	if body is DotBot:
		cameraDestination = roomArea5.position
		moveCamera= true


func _on_room_4_body_entered(body:Node2D) -> void:
	if body is DotBot:
		cameraDestination = roomArea4.position
		moveCamera= true


func _on_room_3_body_entered(body:Node2D) -> void:
	if body is DotBot:
		cameraDestination = roomArea3.position
		moveCamera= true

func _on_room_2_body_entered(body:Node2D) -> void:
	if body is DotBot:
		cameraDestination = roomArea2.position
		moveCamera= true

func springUp(body:Node2D) -> void:
	if body is DotBot:
		if body.velocity.y<0:
			body.velocity.y = -600

func _on_spring_up_sw_body_entered(body:Node2D) -> void:
	springUp(body)


func doStartPosition() -> void:
	for node in entriesAndExits.get_children():
		if node is DotExit:
			if node.oid == Globals.fastTravelOid:
				dottyBot.global_position = node.loadInPoint.global_position
				dottyBot.velocity.x = 100
	# fastTravelOid
