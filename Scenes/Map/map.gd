extends Node2D

class_name Map

@onready var camera2DViewPort :Camera2D = $Camera2DViewPort

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

#Remember that the main level should be from -6912.0 to 6912.0
# and mapRooms should be 256 with a ratio of 54 
func setPosition():

	var currentPosition = Globals.mainCharacter.position
	var sprite = $Sprite2DPostion #TODO onready these
	var mapRoom = $MapRoom #TODO coose active map
	#mapRoom.add_child(sprite)
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
	print(zoomLevel)
	camera2DViewPort.zoom.x = zoomLevel
	camera2DViewPort.zoom.y = zoomLevel

func zoomout():
	zoomPointer=zoomPointer-1
	if zoomPointer <0 :
		zoomPointer = len(zoomLevels)-1
	setZoom()
	


	#camera2DViewPort.zoom.x = 
