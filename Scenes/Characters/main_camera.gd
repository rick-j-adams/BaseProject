extends Camera2D

enum MODES {FOLLOW, PEAK, SWITCH}
var currentMode : MODES = MODES.FOLLOW


const TARGET_SMOOTHING = 32.0
const SWITCH_TARGET_SMOOTHING = 48.0
const MIN_CAMERA_SPEED = 18.0
const MAX_CAMERA_SPEED = 900.0
const MIN_CAMERA_SPEED_Y = 18.0
const MAX_CAMERA_SPEED_Y = 1400.0
const SPEED_DISTANCE = 360.0
const SPEED_ACCELERATION = 3000.0
const SPEED_ACCELERATION_Y = 4500.0

@onready var timer :Timer = $Timer

var lastFacingRight :bool = true 
var smoothedTarget : Vector2
var cameraSpeedX : float = MIN_CAMERA_SPEED
var cameraSpeedY : float = MIN_CAMERA_SPEED_Y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.mainCamera= self
	smoothedTarget = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.currentMode == Globals.MODES.PLAY:
		var target_smoothing := SWITCH_TARGET_SMOOTHING if lastFacingRight != Globals.facingRight else TARGET_SMOOTHING
		var target_blend := 1.0 - exp(-target_smoothing * delta)
		smoothedTarget = smoothedTarget.lerp(Globals.moveCameraTo, target_blend)

		var horizontal_ratio := clampf(absf(smoothedTarget.x - global_position.x) / SPEED_DISTANCE, 0.0, 1.0)
		var vertical_ratio := clampf(absf(smoothedTarget.y - global_position.y) / SPEED_DISTANCE, 0.0, 1.0)
		var horizontal_curve := horizontal_ratio * horizontal_ratio * (3.0 - 2.0 * horizontal_ratio)
		var vertical_curve := vertical_ratio * vertical_ratio * (3.0 - 2.0 * vertical_ratio)
		var desired_speed_x := lerpf(MIN_CAMERA_SPEED, MAX_CAMERA_SPEED, horizontal_curve)
		var desired_speed_y := lerpf(MIN_CAMERA_SPEED_Y, MAX_CAMERA_SPEED_Y, vertical_curve)
		cameraSpeedX = move_toward(cameraSpeedX, desired_speed_x, SPEED_ACCELERATION * delta)
		cameraSpeedY = move_toward(cameraSpeedY, desired_speed_y, SPEED_ACCELERATION_Y * delta)
		global_position.x = move_toward(global_position.x, smoothedTarget.x, cameraSpeedX * delta)
		global_position.y = move_toward(global_position.y, smoothedTarget.y, cameraSpeedY * delta)
		lastFacingRight = Globals.facingRight

func snapTo(newPosition:Vector2)->void:
	global_position=newPosition
	smoothedTarget=newPosition
	cameraSpeedX=MIN_CAMERA_SPEED
	cameraSpeedY=MIN_CAMERA_SPEED_Y


func _on_timer_timeout() -> void:
	timer.stop()
	if currentMode == MODES.SWITCH:
		currentMode = MODES.FOLLOW
