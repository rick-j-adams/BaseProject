class_name TransistionMask
extends Node2D

func playTransistion() -> void:
	$AnimationPlayer.play("Transistion")

func _ready() -> void:
	Globals.transitionMask = self
