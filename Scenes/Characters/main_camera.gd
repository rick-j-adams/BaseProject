extends Camera2D

enum MODES {FOLLOW, PEAK, SWITCH}
var currentMode : MODES = MODES.FOLLOW


const TARGET_SMOOTHING = 32.0
const VERTICAL_TARGET_SMOOTHING = 52.0
const SWITCH_TARGET_SMOOTHING = 48.0
const PEAK_RETURN_SMOOTHING = 72.0
const PEAK_RETURN_SPEED_MULTIPLIER = 1.5
const MIN_CAMERA_SPEED = 18.0
const MAX_CAMERA_SPEED = 900.0
const MIN_CAMERA_SPEED_Y = 18.0
const MAX_CAMERA_SPEED_Y = 1400.0
const SPEED_DISTANCE = 360.0
const SPEED_ACCELERATION = 3000.0
const SPEED_ACCELERATION_Y = 4500.0
const VERTICAL_SPEED_CATCHUP = 240.0

@onready var timer :Timer = $Timer

var lastFacingRight :bool = true 
var smoothedTarget : Vector2
var lastCameraTarget : Vector2
var hasLastCameraTarget : bool = false
var cameraSpeedX : float = MIN_CAMERA_SPEED
var cameraSpeedY : float = MIN_CAMERA_SPEED_Y
var peakTarget : Vector2
var peakHoldDuration : float = 0.0
var peakTimerStarted : bool = false
var returningFromPeak : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.mainCamera= self
	smoothedTarget = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.currentMode == Globals.MODES.PLAY:
		var target_smoothing := PEAK_RETURN_SMOOTHING if returningFromPeak else SWITCH_TARGET_SMOOTHING if lastFacingRight != Globals.facingRight else TARGET_SMOOTHING
		var target_blend := 1.0 - exp(-target_smoothing * delta)
		var cameraTarget := peakTarget if currentMode == MODES.PEAK else Globals.moveCameraTo
		var vertical_target_smoothing := PEAK_RETURN_SMOOTHING if returningFromPeak else VERTICAL_TARGET_SMOOTHING
		var vertical_target_blend := 1.0 - exp(-vertical_target_smoothing * delta)
		var target_vertical_speed := 0.0
		if hasLastCameraTarget and delta > 0.0:
			target_vertical_speed = absf(cameraTarget.y - lastCameraTarget.y) / delta
		lastCameraTarget = cameraTarget
		hasLastCameraTarget = true
		smoothedTarget.x = lerpf(smoothedTarget.x, cameraTarget.x, target_blend)
		smoothedTarget.y = lerpf(smoothedTarget.y, cameraTarget.y, vertical_target_blend)

		var horizontal_ratio := clampf(absf(smoothedTarget.x - global_position.x) / SPEED_DISTANCE, 0.0, 1.0)
		var vertical_ratio := clampf(absf(smoothedTarget.y - global_position.y) / SPEED_DISTANCE, 0.0, 1.0)
		var horizontal_curve := horizontal_ratio * horizontal_ratio * (3.0 - 2.0 * horizontal_ratio)
		var vertical_curve := vertical_ratio * vertical_ratio * (3.0 - 2.0 * vertical_ratio)
		var speed_multiplier := PEAK_RETURN_SPEED_MULTIPLIER if returningFromPeak else 1.0
		var desired_speed_x := lerpf(MIN_CAMERA_SPEED, MAX_CAMERA_SPEED, horizontal_curve) * speed_multiplier
		var desired_speed_y := maxf(lerpf(MIN_CAMERA_SPEED_Y, MAX_CAMERA_SPEED_Y, vertical_curve), target_vertical_speed + VERTICAL_SPEED_CATCHUP) * speed_multiplier
		cameraSpeedX = move_toward(cameraSpeedX, desired_speed_x, SPEED_ACCELERATION * speed_multiplier * delta)
		cameraSpeedY = move_toward(cameraSpeedY, desired_speed_y, SPEED_ACCELERATION_Y * speed_multiplier * delta)
		global_position.x = move_toward(global_position.x, smoothedTarget.x, cameraSpeedX * delta)
		global_position.y = move_toward(global_position.y, smoothedTarget.y, cameraSpeedY * delta)
		lastFacingRight = Globals.facingRight
		if currentMode == MODES.PEAK and not peakTimerStarted and global_position.distance_to(peakTarget) <= 2.0:
			timer.wait_time = peakHoldDuration
			timer.start()
			peakTimerStarted = true
		if returningFromPeak and global_position.distance_to(Globals.moveCameraTo) <= 24.0:
			returningFromPeak = false

func peakAt(position: Vector2, holdDuration: float = 1.0) -> void:
	timer.stop()
	currentMode = MODES.PEAK
	returningFromPeak = false
	peakTarget = position
	peakHoldDuration = maxf(holdDuration, 0.0)
	peakTimerStarted = false

func cancelPeak() -> void:
	if currentMode != MODES.PEAK:
		return
	timer.stop()
	currentMode = MODES.FOLLOW
	peakTimerStarted = false
	returningFromPeak = true

func snapTo(newPosition:Vector2)->void:
	global_position=newPosition
	smoothedTarget=newPosition
	cameraSpeedX=MIN_CAMERA_SPEED
	cameraSpeedY=MIN_CAMERA_SPEED_Y


func _on_timer_timeout() -> void:
	timer.stop()
	if currentMode == MODES.SWITCH or currentMode == MODES.PEAK:
		returningFromPeak = currentMode == MODES.PEAK
		currentMode = MODES.FOLLOW
	peakTimerStarted = false
