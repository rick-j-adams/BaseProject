extends Node2D

class_name NewScreen

@onready var animationPlayerPickUp: AnimationPlayer = $AnimationPlayerPickUp
@onready var animationPlayerCost: AnimationPlayer = $AnimationPlayerCost
@onready var animationPlayerGrowBattery: AnimationPlayer = $AnimationPlayerGrowBattery
@onready var animationPlayerGrowBattertMax: AnimationPlayer = $AnimationPlayerGrowBattertMax
@onready var animationPlayerWarn: AnimationPlayer = $AnimationPlayerWarn

const WARNING :	String= "Warning"
const GROW : String = "Grow"

func changePickUp(pickUpName:String)->void:
	animationPlayerPickUp.play(pickUpName)

func showWarning()->void:
	animationPlayerWarn.play(WARNING)

func growMaxBattery(amount:int)->void:
	var animationName = GROW + str(amount)
	animationPlayerGrowBattertMax.play(animationName)

func growBattery(amount:int)->void:
	var animationName = GROW + str(amount)
	animationPlayerGrowBattery.play(animationName)

func showCost(amount:int)->void:
	var animationName = GROW + str(amount)
	animationPlayerCost.play(animationName)
