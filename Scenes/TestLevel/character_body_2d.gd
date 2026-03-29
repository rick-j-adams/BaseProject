extends CharacterBody2D

@onready var sprite := $Sprite2D

const MAX_SPEED := 300.0
const ACCELERATION := 1200.0
const FRICTION := 1000.0
const GRAVITY := 900.0
const JUMP_VELOCITY := -350.0

const TILT_SPEED := 8.0
const MAX_TILT := deg_to_rad(35)

func _physics_process(delta):
	var input := Input.get_axis("ui_left", "ui_right")

	# Always apply gravity
	velocity.y += GRAVITY * delta

	if is_on_floor():
		var n := get_floor_normal()
		var tangent := Vector2(n.y, -n.x).normalized()

		# Ensure tangent matches player input
		if tangent.dot(Vector2(input, 0)) < 0:
			tangent = -tangent

		# Current speed along slope
		var speed := velocity.dot(tangent) * input

		# Accelerate along slope
		speed = move_toward(
			speed,
			input * MAX_SPEED,
			ACCELERATION * delta
		)

		# Friction when no input
		if input == 0:
			speed = move_toward(speed, 0.0, FRICTION * delta)

		velocity = tangent * speed 

		# Jump
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY

		# # Visual tilt only
		# var target_angle := atan2(n.x, n.y)
		# sprite.rotation = lerp_angle(
		# 	sprite.rotation,
		# 	clamp(target_angle, -MAX_TILT, MAX_TILT),
		# 	TILT_SPEED * delta
		# )
	else:
		sprite.rotation = lerp_angle(sprite.rotation, 0.0, TILT_SPEED * delta)

	move_and_slide()
