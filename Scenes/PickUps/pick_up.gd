extends Node2D

class_name PickUp

enum PickUpType {
	HEALTH,
	ENERGY,
	SPAREPARTS
}

var onGround : bool = true
var pickingUp : bool = false
var speed : float = 300.0
@onready var animationPlayer :AnimationPlayer = $AnimationPlayer

@export var pickUpType :PickUpType = PickUpType.HEALTH

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if pickingUp:
		# var bagPosition = Globals.bagPositionHud()
		var screenPos = Vector2(40, 40) # Your HUD/Screen coordinates
		var worldPos = get_canvas_transform().affine_inverse() * screenPos	
		if global_position.distance_to(worldPos) < 10:
			queue_free()
		else:
			
			if worldPos.x < global_position.x:
				global_position.x -= speed * delta
			if worldPos.x > global_position.x:
				global_position.x += speed * delta
			if worldPos.y < global_position.y:
				global_position.y -= speed * delta
			if worldPos.y > global_position.y:
				global_position.y += speed * delta	
			# 	if global_position.x < bagPosition.global_position.x:
			# 		global_position.x += speed * delta
			# 	if global_position.x > bagPosition.global_position.x:
			# 		global_position.x -= speed * delta
			# 	if global_position.y < bagPosition.global_position.y:
			# 		global_position.y += speed * delta
			# 	if global_position.y > bagPosition.global_position.y:
			# 		global_position.y -= speed * delta	
			# global_position = global_position.lerp(bagPosition.global_position, 0.1)

func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if onGround:
			if body is Dydimo:			
				onGround = false
				Globals.movePuffMachine(global_position, 0.05, 0.5)
				animationPlayer.play("PickUp")
				pickingUp = true
				body.addPickUp(pickUpType)
