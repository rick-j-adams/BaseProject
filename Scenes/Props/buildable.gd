extends Node2D

class_name Buildable

enum BuildableType {
	FAN,
	TELEPORTER,
	MAP_MACHINE,
	FAST_TRAVEL
}

@export var oid = 0

@export var buildableType: BuildableType = BuildableType.TELEPORTER

@export var isOn := false	
@export var isBroken :bool = true
@export var mapAreaName = ""

@onready var sprite :Sprite2D = $Sprite2D
@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var startBuildTimer :Timer = $StartBuildTimer


const BITS = "bits"
@export var repairCostInBits : float = 5

# func tool_texture() ->void:
# 	if buildableType == BuildableType.TELEPORTER:
# 		sprite.texture = preload("res://Images/Props/Pin.png")
# 	elif buildableType == BuildableType.MAP_MACHINE:
# 		sprite.texture = preload("res://Images/Props/mapmachine.png")
# 	elif buildableType == BuildableType.FAST_TRAVEL:
# 		sprite.texture = preload("res://Images/Props/FastTraveller.png")

func getConfiguration() -> Dictionary:
	var configuration :Dictionary =  {"buildableType":buildableType , "isOn":isOn, "isBroken":isBroken }
	return configuration 

func saveBuildableState() -> void:	
	var levelsBuildables =  Globals.allResources.allLevelsBuildables.get(Globals.currentLevel)
	if levelsBuildables == null:
		var newBuildableDetails = { oid:getConfiguration()}
		Globals.allResources.allLevelsBuildables.set(Globals.currentLevel, newBuildableDetails)
		levelsBuildables =  Globals.allResources.allLevelsBuildables.get(Globals.currentLevel)	
	var buildableDetails = levelsBuildables.get(oid)
	if buildableDetails==null:
		levelsBuildables.set(oid, getConfiguration())
		buildableDetails = levelsBuildables.get(oid)
	buildableDetails.set("buildableType",buildableType)
	buildableDetails.set("isOn",isOn)
	buildableDetails.set("isBroken",isBroken)



func setUpBuildable(details:Dictionary):
	buildableType = details.get("buildableType")
	isOn = details.get("isOn")
	isBroken = details.get("isBroken")
	configNewState()

func configNewState() -> void:
	if buildableType == BuildableType.FAN:
		sprite.texture=Globals.getTextureByName("fan")
	if buildableType == BuildableType.TELEPORTER:
		sprite.texture=Globals.getTextureByName("pin")
	elif buildableType == BuildableType.MAP_MACHINE:
		sprite.texture=Globals.getTextureByName("mapmachine")
	elif buildableType == BuildableType.FAST_TRAVEL:
		sprite.texture=Globals.getTextureByName("fasttravel")
	# if Engine.is_editor_hint():
	# 	tool_texture()
	if isOn:
		animationPlayer.play("Idle")
	else:
		if isBroken:
			animationPlayer.play("Broken")
		else:
			animationPlayer.play("Off")

func _ready():
	configNewState()

func repair(setPosition: Vector2):
	if isBroken:
		var bits = Globals.getGamePropery(BITS)
		if bits >= repairCostInBits:
			Globals.moveBitPayMachine(setPosition, global_position,repairCostInBits)		
			startBuildTimer.wait_time = 0.2*repairCostInBits
			startBuildTimer.start()	
			
		else:
			Globals.nsfHud(repairCostInBits)

func working () ->BuildableType:
	if not isBroken and isOn: 
		animationPlayer.play("Working")	
		if 	buildableType == BuildableType.MAP_MACHINE:
			pass #TODO add map details
		if 	buildableType == BuildableType.FAST_TRAVEL:
			return buildableType
	return 	BuildableType.TELEPORTER
			
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
	saveBuildableState()

func setUnUseable():
	animationPlayer.play("Idle")
	if buildableType == BuildableType.TELEPORTER:
		Globals.mainCharacter.canTeleport = false
	saveBuildableState()

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

func requestLight() -> void:
	if buildableType == BuildableType.TELEPORTER:
		Globals.requestTempLight(global_position, TempLight.LightType.FLAME)
	if buildableType == BuildableType.MAP_MACHINE:
		Globals.requestTempLight(global_position, TempLight.LightType.LIGHTNING)
	if buildableType == BuildableType.FAST_TRAVEL:
		Globals.requestTempLight(global_position, TempLight.LightType.LIGHTNING)
