extends Node2D

class_name Buildable

enum BuildableType {
	FAN,
	TELEPORTER
}

@export var buildableType: BuildableType = BuildableType.TELEPORTER
@export var isOn := false	
@export var isBroken :bool = true

@onready var sprite :Sprite2D = $Sprite2D
@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var startBuildTimer :Timer = $StartBuildTimer


const BITS = "bits"
@export var repairCostInBits : float = 5

func _ready():
	if isOn:
		animationPlayer.play("Idle")
	else:
		if isBroken:
			animationPlayer.play("Broken")
		else:
			animationPlayer.play("Off")

func repair(setPosition: Vector2):
	if isBroken:
		var bits = Globals.getGamePropery(BITS)
		if bits >= repairCostInBits:
			Globals.moveBitPayMachine(setPosition, global_position,repairCostInBits)		
			startBuildTimer.wait_time = 0.2*repairCostInBits
			startBuildTimer.start()	
		else:
			Globals.nsfHud(repairCostInBits)
		
			
func turnOn():
	if not isBroken:
		isOn = true
		animationPlayer.play("Idle")


func _on_build_area_body_exited(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			body.buildableArea = null


func _on_start_build_timer_timeout() -> void:
	animationPlayer.play("Birth")
	isBroken = false
	startBuildTimer.stop()
	Globals.createPuff(global_position)
	Globals.movePuffMachine(global_position, 0.05, 1)
	if Globals.closeTo(global_position):
		setUseable()

func _on_build_area_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			body.buildableArea = self

func setUseable():
	if !animationPlayer.is_playing():
		animationPlayer.play("Ready")
	if buildableType == BuildableType.TELEPORTER:
		Globals.mainCharacter.canTeleport = true

func setUnUseable():
	animationPlayer.play("Idle")
	if buildableType == BuildableType.TELEPORTER:
		Globals.mainCharacter.canTeleport = false

func _on_use_area_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			if isOn and not isBroken :				
				setUseable()

func _on_use_area_body_exited(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			if isOn and not isBroken:
				setUnUseable()
