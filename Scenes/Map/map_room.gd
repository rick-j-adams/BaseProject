extends Node2D

class_name MapRoom


@export var roomName: String = "TestRoom"
@export var roomsection: Map.SECTIONS = Map.SECTIONS.REFUSE

@onready var sprite2DRoomMap :Sprite2D = $Sprite2DRoomMap
@onready var maskRevealAreas :Node2D = $Maskers

const KEY_NAME : String = "Map"

func _ready() -> void:
	setupRoom()

func setupRoom():
	sprite2DRoomMap.modulate = Map.sectionColor.get(roomsection)
	sprite2DRoomMap.texture = Globals.imageMap.get(roomName+KEY_NAME)


func doMaskReveals() ->void:

	var levelMaskDetails:Dictionary = Globals.getUpMaskRevealsForGivenLevel(roomName)
	if levelMaskDetails == null:
		return
	var count = 1
	for node in maskRevealAreas.get_children():
		var thisMasksDetail = levelMaskDetails.get(count)
		if thisMasksDetail[0]:
			if thisMasksDetail[1]:
				node.visible = false
			else:
				node.visible = true
		else:
			node.visible = false
		count=count+1
		
func revealAllMasks() -> void:
	var levelMaskDetails:Dictionary = Globals.getUpMaskRevealsForGivenLevel(roomName)
	if levelMaskDetails == null:
		return
	var count = 1
	for node in maskRevealAreas.get_children():	
		var thisMasksDetail = levelMaskDetails.get(count)
		if thisMasksDetail[0]:
			node.visible = false
			thisMasksDetail[1] = true
		count=count+1
	var levelDetails = Globals.allResources.allLevels.get(roomName)
	if levelDetails != null :
		levelDetails.set( "visited" , true)
				