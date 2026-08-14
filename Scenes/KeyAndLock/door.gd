extends Node2D

class_name Door

enum DOOR_TYPE {ELECTRIC_DOOR, BULKHEAD_DOOR}
enum DOOR_STATES {OPEN, OPENING, CLOSED, CLOSING}

@export var doorType: DOOR_TYPE = DOOR_TYPE.ELECTRIC_DOOR
	
@export var doorState: DOOR_STATES = DOOR_STATES.CLOSED
@export var flippedPower:bool = false
@export var hasPower:bool = true

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var sprite2D :Sprite2D = $Sprite2D
@onready var timer :Timer = $Timer
@onready var staticBody2D :StaticBody2D = $StaticBody2D

func _ready() -> void:
	setUpType()
	if doorState == DOOR_STATES.OPEN:
		setOpen()
	if doorState == DOOR_STATES.CLOSED:
		setClosed()

func getDoorTexture() ->Texture2D :
	var texture:Texture2D = null
	if doorType == DOOR_TYPE.ELECTRIC_DOOR:
		texture = Globals.getTextureByName("electricDoor")
	if doorType == DOOR_TYPE.BULKHEAD_DOOR:
		texture = Globals.getTextureByName("bulkHeadDoor")
	return texture

func setUpType() -> void:
	sprite2D.texture = getDoorTexture()

	if not hasPower and flippedPower: 
		doorState = DOOR_STATES.OPEN

		


func openDoor() ->void:
	if doorState != DOOR_STATES.CLOSED:
		return
	if hasPower or (not hasPower and flippedPower) :
		doorState = DOOR_STATES.OPENING
		animationPlayer.play("Opening")
		timer.start()

func closeDoor() ->void:
	if doorState != DOOR_STATES.OPEN:
		return
	if hasPower or (not hasPower and flippedPower) :
		doorState = DOOR_STATES.CLOSING
		animationPlayer.play("Closing")
		timer.start()

func toggleState() ->void:
	if doorState == DOOR_STATES.OPEN:
		closeDoor()
	if doorState == DOOR_STATES.CLOSED:
		openDoor()


func setOpen() -> void:
	doorState = DOOR_STATES.OPEN
	staticBody2D.set_collision_layer_value(1, false)
	animationPlayer.play("Open")

func setClosed() -> void:
	doorState = DOOR_STATES.CLOSED
	staticBody2D.set_collision_layer_value(1, true)
	animationPlayer.play("Closed")

func doLighting() ->void:
	if doorType == DOOR_TYPE.ELECTRIC_DOOR:
		Globals.requestTempLight(global_position, TempLight.LightType.PURPLE_LIGHTNING)

func _on_timer_timeout() -> void:
	if doorState != DOOR_STATES.OPENING:
		setOpen()
	if doorState != DOOR_STATES.CLOSING:
		setClosed()
		
