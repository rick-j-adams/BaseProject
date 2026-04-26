extends Node2D

@export var isOn := false	
@export var isBroken :bool = true
@export var repairCost :int = 10

@onready var sprite :Sprite2D = $Sprite2D
@onready var animationPlayer :AnimationPlayer = $AnimationPlayer

func _ready():
	if isOn:
		animationPlayer.play("Fan")
	else:
		if isBroken:
			animationPlayer.play("Broken")
		else:
			animationPlayer.play("Off")

func repair():
	if isBroken:
		isBroken = false
		animationPlayer.play("Birth")

func turnOn():
	if not isBroken:
		isOn = true
		animationPlayer.play("Fan")

func _on_blow_area_body_exited(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			if isOn and not isBroken and body.chute:
				body.blowUp = false

func _on_blow_area_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			if isOn and not isBroken and body.chute:
				body.blowUp = true


func _on_build_area_body_exited(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			body.buildableArea = null

func _on_build_area_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			body.buildableArea = self
