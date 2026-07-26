extends Node2D

class_name PickUp

enum PickUpType {
NONE,
JUMP,
JUMP2,
ZAP,
ZAP2,
JETPACK,
WALLRIDE,
TELEPORT,
HEALTH1,
HEALTH2,
CHUTE,
MAGNET,
SECURITY,
HEALTH3,
ZAP3,
SPEED,
#motherboards
MB1,
MB2,
MB3,
MB4,
#batteries
BATTERYLOW1,
BATTERYLOW2,
BATTERYLOW3,
BATTERYLOW4,
BATTERYLOW5,
BATTERYLOW6,
BATTERYLOW7,
BATTERYLOW8,
BATTERYLOW9,
BATTERYLOW10,
BATTERYLOW11,
BATTERYLOW12,
BATTERYMED1,
BATTERYMED2,
BATTERYMED3,
BATTERYMED4,
BATTERYMED5,
BATTERYMED6,
BATTERYHIGH1,
BATTERYHIGH2,
BATTERYHIGH3,
BATTERYHIGH4,
}

var onGround : bool = true
var pickingUp : bool = false
var inventoryItem = false;

var speed : float = 1000.0
@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var sprite :Sprite2D = $Sprite2D
@onready var spriteHighLight :Sprite2D = $Sprite2DHighLight
@onready var pointLight2D :PointLight2D = $PointLight2D


@export var pickUpType :PickUpType = PickUpType.HEALTH1

func _ready() -> void:
	Globals.setUpPicksUpMap()
	var textureName = Globals.allResources.allPickUps.get(pickUpType).get("texture")
	var textureValue = Globals.getTextureByName(textureName)
	sprite.texture = textureValue
	spriteHighLight.texture=textureValue
	UnhighlightPickUp()

func _process(delta: float) -> void:
	if pickingUp:
		var screenPos := Vector2(40, 40) # HUD/Screen coordinates
		var worldPos := get_canvas_transform().affine_inverse() * screenPos

		if global_position.distance_to(worldPos) <= 10:
			Globals.playBoxOpenAnimationHud()
			queue_free()
		else:
			global_position = global_position.move_toward(worldPos, speed * delta)

func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if onGround:
			if body is Dydimo:			
				onGround = false
				Globals.movePuffMachine(global_position, 0.05, 0.5)
				animationPlayer.play("PickUp")
				pickingUp = true
				body.addPickUp(pickUpType)

func setInventoryItem(value: bool) -> void:
	inventoryItem = value
	if inventoryItem:
		onGround = false
		pickingUp = false
		animationPlayer.play("Wait")
	
func HighlightPickUp() -> void:
	spriteHighLight.visible = true
	pointLight2D.energy = 1.0

func UnhighlightPickUp() -> void:
	spriteHighLight.visible = false
	pointLight2D.energy = 0.0
