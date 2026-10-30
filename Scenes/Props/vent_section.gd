extends Node2D

enum TYPES { TYPE1, TYPE2, TYPE3, TYPE4, TYPE5, TYPE6, VENTSHAFT, GRILL }
enum FLOOR_TYPES { SOLID, VENT, OPEN }

@onready var sprite2DBackWall : Sprite2D = $Sprite2DBackWall
@onready var sprite2DFloor : Sprite2D = $Sprite2DFloor
@onready var sprite2DCeiling : Sprite2D = $Sprite2DCeiling
@onready var staticBody2DFloor : StaticBody2D = $StaticBody2DFloor
@onready var lightOccluder2D : LightOccluder2D = $LightOccluder2D


@export var type : TYPES = TYPES.TYPE1
@export var floorType : FLOOR_TYPES = FLOOR_TYPES.SOLID

	# "WallVent1" : "res://Images/Walls/Vents/Ventl.png",
	# "WallVent2" : "res://Images/Walls/Vents/Vent2.png",
	# "WallVent3" : "res://Images/Walls/Vents/Vent3.png",
	# "WallVent4" : "res://Images/Walls/Vents/Vent4.png",
	# "WallVent5" : "res://Images/Walls/Vents/Vent5.png",
	# "WallVent6" : "res://Images/Walls/Vents/Vent6.png",
	# "WallVent7" : "res://Images/Walls/Vents/VentShaft.png",
	# "WallVentGrill" : "res://Images/Walls/Vents/VentGrillFloor.png",
	# "WallVentFloor" : "res://Images/Walls/Vents/VentFloor.png",
	# "WallVentFloor2" : "res://Images/Walls/Vents/VentGrillFloor.png",

var textureMapback = {
	TYPES.TYPE1 : "WallVent1",
	TYPES.TYPE2 : "WallVent2",
	TYPES.TYPE3 : "WallVent3",
	TYPES.TYPE4 : "WallVent4",
	TYPES.TYPE5 : "WallVent5",
	TYPES.TYPE6 : "WallVent6",
	TYPES.VENTSHAFT : "WallVent7",
	TYPES.GRILL : "WallVentGrill",
}

var textureMapFloor = {
	FLOOR_TYPES.SOLID : "WallVentFloor",
	FLOOR_TYPES.VENT : "WallVentFloor2",
	FLOOR_TYPES.OPEN : "WallVentFloor2",
}

func _ready() -> void:

	var backname = textureMapback[type]
	var floorname = textureMapFloor[floorType]
	
	sprite2DBackWall.texture = Globals.getTextureByName(backname)
	sprite2DFloor.texture = Globals.getTextureByName(floorname)

	if floorType == FLOOR_TYPES.OPEN:
		sprite2DFloor.visible = false
		staticBody2DFloor.set_collision_layer_value(1, false) 
		staticBody2DFloor.set_collision_layer_value(2, false) 
		lightOccluder2D.visible = false
		# lightOccluder2D.set_light_occluder_layer_value(1, false)



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Dydimo:
		Globals.playAudioAt(global_position, "ventflex")
