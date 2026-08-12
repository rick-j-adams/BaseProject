extends Node2D

class_name MapRoom


@export var roomName: String = "TestRoom"
@export var roomsection: Map.SECTIONS = Map.SECTIONS.REFUSE

@onready var sprite2DRoomMap :Sprite2D = $Sprite2DRoomMap


func _ready() -> void:
	setupRoom()

func setupRoom():
	sprite2DRoomMap.modulate = Map.sectionColor.get(roomsection)
	

