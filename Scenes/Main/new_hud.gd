extends CanvasLayer

const BITS = "bits"

var BASE_SIZE : float = 36.0
var INCREMENT_SIZE : float = 4.0


@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var bealthBar: ColorRect = $HealthBar

func _ready():
	Globals.hud = self
	var bits = Globals.getGameProperyNoDefault(BITS)
	if bits == null:
		bits = 5
		Globals.setGamePropery(BITS, bits)

func _process(delta: float) -> void:
	var bits = Globals.getGameProperyNoDefault(BITS)
	var size = BASE_SIZE + (bits * INCREMENT_SIZE)
	bealthBar.size = Vector2(size, bealthBar.size.y)

func nsf() -> void:
	animationPlayer.play("NSF")
	
