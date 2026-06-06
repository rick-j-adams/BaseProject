extends Node2D
class_name Chrusher

var dydimoInRange : Dydimo = null
var sparePart : SpareParts = null
@onready var underside :RPoint = $RPoint

@export var damage : int = 2


func _on_area_2d_body_exited(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			dydimoInRange=null
	if body.is_in_group("spareparts"):
		sparePart=null

func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			dydimoInRange=body
	if body.is_in_group("spareparts"):
		sparePart=body


func doDamage() -> void:
	Globals.movePuffMachine(global_position, 0.05, 0.2)
	Globals.playInterfaceAudio(global_position, "crash")
	if dydimoInRange != null:
		Globals.moveSparkEffect(dydimoInRange.global_position, dydimoInRange.rotation, dydimoInRange.sprite.flip_h, "TeleportSpark")
		dydimoInRange.takeDamage(damage, underside.global_position,true)
	if sparePart != null:
		if not sparePart.destroyed:
			sparePart.destroy()