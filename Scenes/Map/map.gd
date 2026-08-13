extends Node2D

class_name Map

@onready var camera2DViewPort :Camera2D = $Camera2DViewPort
@onready var mapRooms :Node2D = $MapRooms
@onready var positionIndecator : Sprite2D =  $Sprite2DPostion

enum SECTIONS {REFUSE, ENGINE, ENGINEERING, CARGO, GENERATION, SCIENCE, RECYCLING, MAINTENANCE, ADMINISTRATION, CREW, COMMAND, SECURITY, CORE }

const  sectionColor:Dictionary = {
	SECTIONS.REFUSE : Color.LIGHT_BLUE,
	SECTIONS.ENGINE : Color.ORANGE,
	SECTIONS.ENGINEERING : Color.BROWN,
	SECTIONS.CARGO : Color.AQUA,
	SECTIONS.GENERATION : Color.YELLOW,
	SECTIONS.SCIENCE : Color.PINK,
	SECTIONS.RECYCLING : Color.LIGHT_YELLOW,
	SECTIONS.MAINTENANCE : Color.BLUE,
	SECTIONS.ADMINISTRATION : Color.YELLOW_GREEN,
	SECTIONS.CREW : Color.PURPLE,
	SECTIONS.COMMAND : Color.BLUE_VIOLET,
	SECTIONS.SECURITY : Color.LIGHT_GREEN,
	SECTIONS.CORE : Color.DARK_GREEN
}

var zoomLevels: Array = [4.0,2.0,1, 0.5]
var zoomPointer :int = 0

func setUpMap() ->void:
	setPosition()
	setVisiblity()

func setVisiblity() -> void:
	for node in mapRooms.get_children():
		if node is MapRoom:
			var levelDetails = Globals.allResources.allLevels.get(node.roomName)
			if levelDetails != null:
				if levelDetails.get("visited"):
					node.visible=true
					node.doMaskReveals()
				else:
					node.visible=false
			else:
				node.visible=false



func findMatchingMap(mapName:String) -> MapRoom:
	for node in mapRooms.get_children():
		if node is MapRoom:
			if node.roomName == mapName:
				return node
	return null


#Remember that the main level should be from -6912.0 to 6912.0
# and mapRooms should be 256 with a ratio of 54 
func setPosition() -> void:

	var currentPosition = Globals.mainCharacter.position
	var sprite = positionIndecator #TODO scale 
	var mapRoom = findMatchingMap(Globals.currentLevel)
	#mapRoom.add_child(sprite)
	if mapRoom != null:
		var scaledPostion =  currentPosition
		scaledPostion =  scaledPostion/54
		sprite.position = mapRoom.position + scaledPostion
		camera2DViewPort.position = sprite.position



func zoomin():
	zoomPointer=zoomPointer+1
	
	if zoomPointer >= len(zoomLevels):
		zoomPointer=0
	setZoom()
	

func setZoom():
	print(Globals.mainScene)
	var zoomLevel = zoomLevels[zoomPointer]
	# print(zoomLevel)
	camera2DViewPort.zoom.x = zoomLevel
	camera2DViewPort.zoom.y = zoomLevel
	# if zoomLevel == len(zoomLevels)-1:
	# 	positionIndecator.scale.x = 1
	# 	positionIndecator.scale.y = 1
	# else:
	# 	positionIndecator.scale.x = 0.05
	# 	positionIndecator.scale.y = 0.05


func zoomout():
	zoomPointer=zoomPointer-1
	if zoomPointer <0 :
		zoomPointer = len(zoomLevels)-1
	setZoom()
	


	#camera2DViewPort.zoom.x = 
