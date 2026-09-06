extends Control

class_name LiftButtons

@onready var greyedButtons :Node2D = $GreyedButtons
@onready var touchButtons :Node2D = $TouchButtons
@onready var sprite2DSelector :Sprite2D = $Sprite2DSelector


var buttonPointer :int = 0
const BLOCKED_BUTTON_POINT = 3
const OFFSET :float = 16

func _ready() -> void:
	unblockButtons()

func _process(delta: float) -> void:
	if Globals.currentMode != Globals.MODES.LIFT_SELECT:
		visible = false
		return
	unblockButtons()
	visible = true
	var buttons : Array = touchButtons.get_children()
	var maxPointer = buttons.size() - 1
	if not Globals.isObjectiveDone("fixClearBlockage"):
		maxPointer = BLOCKED_BUTTON_POINT
	
	if Input.is_action_just_pressed("ui_left"):
		buttonPointer=buttonPointer-1
		if buttonPointer < 0:
			buttonPointer = maxPointer
		sprite2DSelector.visible = true
	elif Input.is_action_just_pressed("ui_right"):
		buttonPointer=buttonPointer+1
		if buttonPointer > maxPointer:
			buttonPointer = 0
		if buttonPointer < 0:
			buttonPointer = maxPointer	
		sprite2DSelector.visible = true

	elif Input.is_action_just_pressed("ui_cancel"):
		Globals.currentMode=Globals.MODES.PLAY	
		if Globals.mainCharacter != null:
			Globals.mainCharacter.doExitLift()
		#exit
	

	var button :Node2D = buttons[buttonPointer]
	sprite2DSelector.position.x = button.position.x +OFFSET
	sprite2DSelector.position.y = button.position.y + OFFSET

	if Input.is_action_just_pressed("ui_select"):
		button.emit_signal("released")



func unblockButtons() -> void:
	if  Globals.isObjectiveDone("fixClearBlockage"):
		greyedButtons.visible = false
	
func doTouchButton(buttonName:String) -> void:
	
	if not Globals.isObjectiveDone("fixLift"):
		return
	if Globals.mainCharacter != null:
		
	
		Globals.mainCharacter.doLiftTransitionTo(buttonName, buttonPointer)

func doBlockedButton(buttonName:String) -> void:
	if not Globals.isObjectiveDone("fixClearBlockage"):
		return
	doTouchButton(buttonName)

func _on_touch_screen_button_dark_blue_released() -> void:
	doBlockedButton("R001")


func _on_touch_screen_button_purple_released() -> void:
	doBlockedButton("R001")


func _on_touch_screen_button_yellow_released() -> void:
	doBlockedButton("R001")


func _on_touch_screen_button_light_blue_released() -> void:
	doBlockedButton("R001")


func _on_touch_screen_button_pink_released() -> void:
	doBlockedButton("R001")


func _on_touch_screen_button_peach_released() -> void:
	doTouchButton("R001")


func _on_touch_screen_button_orange_released() -> void:
	doTouchButton("R002")


func _on_touch_screen_button_brown_released() -> void:
	doTouchButton("R001")

func _on_touch_screen_button_aqua_released() -> void:
	doTouchButton("R001")
