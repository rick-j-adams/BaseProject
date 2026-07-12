extends Node2D

enum EffectType {
	ELECTRIC,
	BEAM
}

var isOn : bool = false
var fading : bool = false
var addNew : bool = false

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var timer :Timer = $Timer


@export var effectType :EffectType = EffectType.ELECTRIC
@export var energy :float = 5.0
@export var direction :Vector2 = Vector2(1, 0)

var size = 31

func _ready() -> void:
	standBy()

func standBy() -> void:
	isOn = false
	position = Vector2(-1000000000, -1000000000)
	animationPlayer.stop()
	fading = false
	addNew = false

func setup(owner: Node2D, setPosition: Vector2, setDirection: Vector2, setEnergy: float) -> void:
	isOn = true
	position = setPosition
	direction = setDirection
	energy = setEnergy
	animationPlayer.play("Grow")
	timer.start()
	fading = false
	addNew = false
	if owner != null:
		owner.add_child(self)

func getAnimationName() -> String:
	var animationName :String = "Go"
	var which :int = Globals.get_random_four()
	var newname :String = animationName + str(which)	
	return newname

func nextAnimation() -> void:
	if energy > 0:
		energy -= 1
		animationPlayer.play(getAnimationName())
		var nextPosition = global_position 
		nextPosition.x += direction.x * size
		if !addNew:
			Globals.createElement(self, nextPosition, effectType, energy, direction)
			addNew = true
	else:
		animationPlayer.play("Fade")
		fading = true
	
		


func reStage() -> void:
	standBy()


func _on_timer_timeout() -> void:
	if isOn:
		if not fading:
			nextAnimation()
		else:
			standBy()
