extends CanvasLayer

const BITS = "bits"

var BASE_SIZE : float = 36.0
var INCREMENT_SIZE : float = 20

# var maxHealthSize : float = 10.0
enum BAG_STATES {OPEN,OPENING,CLOSED,CLOSING}


@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var animationPlayerBag :AnimationPlayer = $AnimationPlayerBag
@onready var touchPlayerBag :TouchScreenButton = $PanelContainerBag/TouchScreenButton
@onready var openCloseTimer :Timer = $PanelContainerBag/OpenCloseTimer

@onready var healthBar: ColorRect = $HealthBar
@onready var maxHealthBar: ColorRect = $MaxHealth
@onready var payBar: ColorRect = $PayBar
@onready var bagPosition: RPoint = $RPointBagPosition

@onready var panelContainerBag: PanelContainer = $PanelContainerBag

var bagState:BAG_STATES = BAG_STATES.CLOSED

var itemsInBag : Dictionary = {}
var itemSize = 64
var itemWidth= 7

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
	if bagState == BAG_STATES.OPEN and Input.is_action_just_pressed("ui_cancel"):
		triggerCloseBox()	

func nsf(amount: float) -> void:
	var maxPaySize = BASE_SIZE + (amount * INCREMENT_SIZE)
	payBar.size = Vector2(maxPaySize, payBar.size.y)
	animationPlayer.play("NSF")

func maxHealth() -> void:
	animationPlayer.play("MaxHealth")

func getBagPosition() -> RPoint:
	return bagPosition
	
func playBoxOpenAnimation() -> void:
	animationPlayer.play("OpenBox")


func _on_open_close_timer_timeout() -> void:
	if bagState == BAG_STATES.OPENING:
		bagState = BAG_STATES.OPEN
	elif bagState == BAG_STATES.CLOSING:
		bagState = BAG_STATES.CLOSED
		Globals.currentMode = Globals.MODES.PLAY
		

func triggerOpenBox() -> void:
	if bagState == BAG_STATES.CLOSED:
		bagState = BAG_STATES.OPENING
		animationPlayerBag.play("PlayerOpenBox")
		openCloseTimer.start()

func triggerCloseBox() -> void:
	if bagState == BAG_STATES.OPEN:
		bagState = BAG_STATES.CLOSING
		animationPlayerBag.play("PlayerCloseBox")
		openCloseTimer.start()
		Globals.currentMode = Globals.MODES.PLAY

func _on_touch_screen_button_released() -> void:
	Globals.currentMode = Globals.MODES.INVENTORY
	if bagState == BAG_STATES.CLOSED:
		triggerOpenBox()
	elif bagState == BAG_STATES.OPEN:
		triggerCloseBox()



func addItemToBox() -> void:
	for item in itemsInBag.keys():
		var itemData = itemsInBag.get(item)
		if itemData != null:
			itemData.queue_free()
	var newpostion = Vector2(itemSize, itemSize)
	var rowCount = 0
	# var newXPosition = itemSize
	# var newYPosition = itemSize
	for potentialItem in Globals.allResources.allPickUps.keys():
		var itemData = Globals.allResources.allPickUps.get(potentialItem)
		if itemData != null:
			if itemData.get("pickedUp") == true:
				var pickUpScene = Globals.sceneMap.get("pickUp")
				var pickUpInstance = pickUpScene.instantiate()
				pickUpInstance.pickUpType = potentialItem
				panelContainerBag.add_child(pickUpInstance)
				pickUpInstance.position = newpostion
				itemsInBag.set(potentialItem, pickUpInstance)
				pickUpInstance.setInventoryItem(true)
				pickUpInstance.inventoryItem = true
				newpostion.x += itemSize
				rowCount += 1
				if rowCount >= itemWidth:
					rowCount = 0
					newpostion.x = itemSize
					newpostion.y += itemSize