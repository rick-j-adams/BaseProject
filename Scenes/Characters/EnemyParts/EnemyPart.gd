extends Node2D

class_name EnemyPart

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var damagePlayer: AnimationPlayer = $DamagePlayer

var parentEnemy: Enemy = null
var detached: bool = false
var maxSpeed: float = 1600.0
var velocity: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if detached:
		velocity.y += Globals.GRAVITY * delta
		global_position += velocity * delta
		

func playPartAnimation(animationName: String):
	animationPlayer.play(animationName)

func playDamageAnimation():
	if damagePlayer != null:
		damagePlayer.play("Damage")

func die():
	velocity.x = Globals.get_rand_between(-maxSpeed, maxSpeed)
	velocity.y = Globals.get_rand_between(-maxSpeed, 0)
	detached = true
	animationPlayer.play("Rotate")

