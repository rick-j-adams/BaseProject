extends Node2D

class_name MapRoom


@export var roomName: String = "TestRoom"
@export var roomsection: Map.SECTIONS = Map.SECTIONS.REFUSE

@onready var sprite2DRoomMap :Sprite2D = $Sprite2DRoomMap
@onready var maskRevealAreas :Node2D = $Maskers


func _ready() -> void:
	setupRoom()

func setupRoom():
	sprite2DRoomMap.modulate = Map.sectionColor.get(roomsection)


func doMaskReveals() ->void:

	var levelMaskDetails:Dictionary = Globals.getUpMaskRevealsForGivenLevel(roomName)
	print(levelMaskDetails)
	if levelMaskDetails == null:
		return
	var count = 1
	for node in maskRevealAreas.get_children():
		var thisMasksDetail = levelMaskDetails.get(count)
		print(str(count)+":"+str(thisMasksDetail))
		print(node.name)
		if thisMasksDetail[0]:
			if thisMasksDetail[1]:
				node.visible = false
			else:
				node.visible = true
		else:
			node.visible = false
		count=count+1
		

		# print(levelMaskDetails)
		# print("maskNumber:"+str(maskNumber)+ "thisMasksDetail:"+str(thisMasksDetail))
	# if thisMasksDetail is Array:
	# 	if len(thisMasksDetail) ==2 :
	# 		if thisMasksDetail[0]:
	# 			thisMasksDetail[1] = true
	
