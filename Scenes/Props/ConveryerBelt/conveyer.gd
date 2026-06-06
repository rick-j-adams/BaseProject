extends Node2D

class_name Conveyer

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer

@export var isOn: bool = true
@export var clockwise: bool = false
@export var speed: float = 100.0

var dydimoInRange: Dydimo = null
var sparePart: SpareParts = null

func _process(delta: float) -> void:
	if not isOn:
		return

	var push_dir: Vector2 = get_push_direction()
	var push_amount: Vector2 = push_dir * speed * delta

	if sparePart != null:
		sparePart.velocity += push_amount

	if dydimoInRange != null:
		dydimoInRange.xForce += push_dir.x * speed * delta
		dydimoInRange.yForce += push_dir.y * speed * delta
		dydimoInRange.setExternalForce(push_dir.x * speed, push_dir.y * speed)

func get_push_direction() -> Vector2:
	var tangent: Vector2 = Vector2.RIGHT.rotated(global_rotation)
	return tangent if clockwise else -tangent

func exit(body: Node2D) -> void:
	if body.is_in_group("actor") and body is Dydimo:
		dydimoInRange.setExternalForce(0.0, 0.0)
		dydimoInRange = null

	if body.is_in_group("spareparts"):
		sparePart.converyerCount=sparePart.converyerCount-1
		if sparePart.converyerCount <= 0:
			sparePart.velocity.x = 0
		sparePart = null

func enter(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			dydimoInRange=body
	if body.is_in_group("spareparts"):
		sparePart=body
		sparePart.converyerCount += 1

func _on_area_2dre_body_exited(body:Node2D) -> void:
	exit(body)

func _on_area_2dre_body_entered(body:Node2D) -> void:
	enter(body)

func _on_area_2d_mid_body_entered(body: Node2D) -> void:
	enter(body)

func _on_area_2d_mid_body_exited(body: Node2D) -> void:
	exit(body)

func _on_area_2dle_body_entered(body: Node2D) -> void:
	enter(body)

func _on_area_2dle_body_exited(body: Node2D) -> void:
	exit(body)

func _on_area_2ddl_body_entered(body: Node2D) -> void:
	enter(body)

func _on_area_2ddl_body_exited(body: Node2D) -> void:
	exit(body)

func _on_area_2ddh_body_entered(body: Node2D) -> void:
	enter(body)

func _on_area_2ddh_body_exited(body: Node2D) -> void:
	exit(body)

func _on_area_2ddd_body_exited(body:Node2D) -> void:
	exit(body)

func _on_area_2ddd_body_entered(body:Node2D) -> void:
	enter(body)

