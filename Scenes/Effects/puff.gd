extends Node2D

@onready var sprite :Sprite2D = $Sprite2D
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

const ANIMATION_NAME = "Puff"
var rotationSpeed: float = 0.0

var velocity: Vector2 = Vector2.ZERO
var animationNumerator: int = 0
var animationPlaying: String = ANIMATION_NAME+str(animationNumerator)
var maxSpeed: float = 200.0
var maxRotationSpeed: float = 5.0

func setAndRelease(setPosition: Vector2):
	self.position = setPosition
	self.velocity.x = Globals.get_rand_between(-maxSpeed, maxSpeed)
	self.velocity.y = Globals.get_rand_between(-maxSpeed, maxSpeed)
	self.rotationSpeed = Globals.get_rand_between(0, maxRotationSpeed)
	self.visible = true
	animationNumerator = Globals.get_random_eight()
	animationPlaying = ANIMATION_NAME+str(animationNumerator)
	animationPlayer.play(animationPlaying)

func _process(delta: float) -> void:
	if not visible:
		return
	
	position += velocity * delta
	rotation += rotationSpeed * delta
	if not animationPlayer.is_playing():
		visible = false