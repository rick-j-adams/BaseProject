extends CanvasLayer

const BITS = "bits"

var BASE_SIZE : float = 36.0
var INCREMENT_SIZE : float = 20

# var maxHealthSize : float = 10.0

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var healthBar: ColorRect = $HealthBar
@onready var maxHealthBar: ColorRect = $MaxHealth
@onready var payBar: ColorRect = $PayBar


func _ready():
	Globals.hud = self
	var bits = Globals.getGameProperyNoDefault(BITS)
	if bits == null:
		bits = 5
		Globals.setGamePropery(BITS, bits)

func _process(delta: float) -> void:
	var bits = Globals.getGameProperyNoDefault(BITS)
	var size = BASE_SIZE + (bits * INCREMENT_SIZE)
	var maxHealthSize = BASE_SIZE + (Globals.getMaxHealth() * INCREMENT_SIZE) 
	healthBar.size = Vector2(size, healthBar.size.y)
	if maxHealthBar.size.x < maxHealthSize:
		maxHealthBar.size.x = maxHealthBar.size.x + (INCREMENT_SIZE * delta) 
	if maxHealthBar.size.x > maxHealthSize:
		maxHealthBar.size.x = maxHealthSize

func nsf(amount: float) -> void:
	var maxPaySize = BASE_SIZE + (amount * INCREMENT_SIZE)
	payBar.size = Vector2(maxPaySize, payBar.size.y)
	animationPlayer.play("NSF")

func maxHealth() -> void:
	animationPlayer.play("MaxHealth")
	
