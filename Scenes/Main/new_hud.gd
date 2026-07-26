extends CanvasLayer

const BITS = "bits"

var BASE_SIZE : float = 36.0
var INCREMENT_SIZE : float = 20

# var maxHealthSize : float = 10.0
enum BAG_STATES {OPEN,OPENING,CLOSED,CLOSING}
enum CASE_STATES {SHOW,SHOWING,HIDE,HIDING}

enum MODES {PLAY,INVENTORY,EXPANSION,BATTERY,MAP}


@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var animationPlayerBag :AnimationPlayer = $AnimationPlayerBag
@onready var animationPlayerCase :AnimationPlayer = $AnimationPlayerCase

@onready var touchPlayerBag :TouchScreenButton = $PanelContainerBag/TouchScreenButton
@onready var openCloseTimer :Timer = $PanelContainerBag/OpenCloseTimer
@onready var showHideTimer :Timer = $PanelContainerCase/ShowHideTimer

@onready var healthBar: ColorRect = $HealthBar
@onready var maxHealthBar: ColorRect = $MaxHealth
@onready var payBar: ColorRect = $PayBar
@onready var bagPosition: RPoint = $RPointBagPosition

@onready var panelContainerBag: PanelContainer = $PanelContainerBag

@onready var slotSelector :Sprite2D = $PanelContainerCase/Sprite2DSlotSelector
@onready var batterySelector :Sprite2D = $PanelContainerCase/Sprite2DBatterySelector

@onready var slotOne1 :RPoint = $PanelContainerCase/RPointSlot1
@onready var slotOne2 :RPoint = $PanelContainerCase/RPointSlot2
@onready var slotOne3 :RPoint = $PanelContainerCase/RPointSlot3
@onready var slotOne4 :RPoint = $PanelContainerCase/RPointSlot4
@onready var slotOne5 :RPoint = $PanelContainerCase/RPointSlot5
@onready var slotOne6 :RPoint = $PanelContainerCase/RPointSlot6
@onready var slotOne7 :RPoint = $PanelContainerCase/RPointSlot7

@onready var board1 :Sprite2D = $PanelContainerCase/Boards/Board1
@onready var board2 :Sprite2D = $PanelContainerCase/Boards/Board2
@onready var board3 :Sprite2D = $PanelContainerCase/Boards/Board3
@onready var board4 :Sprite2D = $PanelContainerCase/Boards/Board4
@onready var board5 :Sprite2D = $PanelContainerCase/Boards/Board5
@onready var board6 :Sprite2D = $PanelContainerCase/Boards/Board6
@onready var board7 :Sprite2D = $PanelContainerCase/Boards/Board7

var boards:Array = [board1,board2,board3,board4,board5,board6,board7]

var selectedItem : PickUp = null
var selectedPointer : int = 0
var currentMode : MODES = MODES.PLAY

var bagState:BAG_STATES = BAG_STATES.CLOSED
var caseState: CASE_STATES = CASE_STATES.HIDE

var itemsInBag : Dictionary = {}
var itemSize = 64
var itemWidth= 7

var boardSlotList:Array = [slotOne2, slotOne4, slotOne5 ,slotOne6]
var boardSlotPosition = 0

func _ready():
	Globals.hud = self
	var bits = Globals.getGameProperyNoDefault(BITS)
	if bits == null:
		bits = 5
		Globals.setGamePropery(BITS, bits)
		animationPlayerCase.play("HideCase")
		boardSlotList = [slotOne2, slotOne4, slotOne5 ,slotOne6]

func _process(delta: float) -> void:
	var bits = Globals.getGameProperyNoDefault(BITS)
	var size = BASE_SIZE + (bits * INCREMENT_SIZE)
	var maxHealthSize = BASE_SIZE + (Globals.getMaxHealth() * INCREMENT_SIZE) 
	healthBar.size = Vector2(size, healthBar.size.y)
	if maxHealthBar.size.x < maxHealthSize:
		maxHealthBar.size.x = maxHealthBar.size.x + (INCREMENT_SIZE * delta) 
	if maxHealthBar.size.x > maxHealthSize:
		maxHealthBar.size.x = maxHealthSize
	handleInput()	

func handleInput() -> void:
	if bagState == BAG_STATES.OPEN and Input.is_action_just_pressed("ui_cancel"):
		triggerCloseBox()	
	if currentMode == MODES.INVENTORY:
		inventoryInput()
	if currentMode == MODES.EXPANSION:
		slotInput()
		
func slotInput() -> void:
	if caseState == CASE_STATES.SHOW and Input.is_action_just_released("ui_right"):
		boardSlotPosition=boardSlotPosition+1
		if boardSlotPosition>=len(boardSlotList):
			boardSlotPosition=0
		moveSlotSelector()
	if caseState == CASE_STATES.SHOW  and Input.is_action_just_released("ui_left"):
		boardSlotPosition=boardSlotPosition-1
		if boardSlotPosition<0:
			boardSlotPosition=len(boardSlotList)-1
		moveSlotSelector()
	if caseState == CASE_STATES.SHOW  and Input.is_action_just_released("ui_select"):
		changeSelectedBoard()

func changeSelectedBoard()->void:
	hideSelectors()
	currentMode=MODES.INVENTORY
	var pickUpType:PickUp.PickUpType = getPickUpInSlot(boardSlotPosition)
	if pickUpType!=PickUp.PickUpType.NONE:
		Globals.allResources.allPickUps.get(pickUpType).set("slotNo",-1)
		Globals.allResources.allPickUps.get(pickUpType).set("pluggedIn",false)
	Globals.playInterfaceAudio(boardSlotList[boardSlotPosition].position, "click")
	Globals.allResources.allPickUps.get(selectedItem.pickUpType).set("slotNo",boardSlotPosition)
	Globals.allResources.allPickUps.get(selectedItem.pickUpType).set("pluggedIn",true)
	print(selectedItem.pickUpType)
	placeBoard()



func getPickUpInSlot(slotNo:int)->PickUp.PickUpType:
	for potentialItem in Globals.allResources.allPickUps.keys():
		var itemData = Globals.allResources.allPickUps.get(potentialItem)
		if itemData != null and itemData.get("category")=="expansion":
			var whichSlot:int = itemData.get("slotNo")
			if whichSlot==slotNo:
				return potentialItem
	return PickUp.PickUpType.NONE

			# Globals.allResources.allPickUps.get(selectedItem.pickUpType).get("category")

func placeBoard()->void:
	var boardCount:int = 0
	for b:Sprite2D in boards:
		b.visible=false
	for potentialItem in Globals.allResources.allPickUps.keys():
		var itemData = Globals.allResources.allPickUps.get(potentialItem)
		if itemData != null and itemData.get("category")=="expansion":
			if itemData.get("pluggedIn") == true:
				var whichSlot:int = itemData.get("slotNo")
				if whichSlot >=0 and whichSlot<len(boardSlotList):
					var nameOfItemTexure:String = itemData.get("texture")+"Top"
					boards[boardCount].visible=true
					boards[boardCount].position = boardSlotList[whichSlot].position
					boards[boardCount].texture = Globals.getTextureByName(nameOfItemTexure)
					boardCount=boardCount+1

		
func setUpBoard()->void:

	boards.clear()
	boards.append(board1)
	boards.append(board2)
	boards.append(board3)
	boards.append(board4)
	boards.append(board5)
	boards.append(board6)
	boards.append(board7)


	boardSlotList.clear()
	boardSlotList.append(slotOne2)
	boardSlotList.append(slotOne4)
	boardSlotList.append(slotOne5)
	boardSlotList.append(slotOne6)


func moveSlotSelector()->void:
	slotSelector.position=boardSlotList[boardSlotPosition].position
	

func inventoryInput() -> void:
	if bagState == BAG_STATES.OPEN and Input.is_action_just_pressed("ui_right"):
		if itemsInBag.keys().size() > 0:
			selectedItem.UnhighlightPickUp()
			selectedPointer += 1
			if selectedPointer >= itemsInBag.keys().size():
				selectedPointer = 0
			var firstItemKey = itemsInBag.keys()[selectedPointer]
			selectedItem = itemsInBag.get(firstItemKey)
			if selectedItem != null:
				selectedItem.HighlightPickUp()
	if bagState == BAG_STATES.OPEN and Input.is_action_just_pressed("ui_left"):
		if itemsInBag.keys().size() > 0:
			selectedItem.UnhighlightPickUp()
			selectedPointer -= 1
			if selectedPointer < 0:
				selectedPointer = itemsInBag.keys().size() - 1
			var firstItemKey = itemsInBag.keys()[selectedPointer]
			selectedItem = itemsInBag.get(firstItemKey)
			if selectedItem != null:
				selectedItem.HighlightPickUp()
	if  bagState == BAG_STATES.OPEN and Input.is_action_just_pressed("ui_select"):
# Globals.currentMode==Globals.MODES.EXPAND and
		if caseState == CASE_STATES.SHOW and Globals.allResources.allPickUps.get(selectedItem.pickUpType).get("category") == "expansion":
			slotSelector.visible=true
			currentMode=MODES.EXPANSION
			moveSlotSelector()
		if  caseState == CASE_STATES.SHOW and Globals.allResources.allPickUps.get(selectedItem.pickUpType).get("category") == "battery":
			batterySelector.visible=true
			currentMode=MODES.EXPANSION


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

func hideSelectors()->void:
	slotSelector.visible=false
	batterySelector.visible=false

func triggerShowCase() -> void:
	if caseState == CASE_STATES.HIDE:
		caseState = CASE_STATES.SHOWING
		animationPlayerCase.play("ShowCase")
		hideSelectors()
		showHideTimer.start()	

func triggerHideCase() -> void:
	if caseState == CASE_STATES.SHOW:
		caseState = CASE_STATES.HIDING
		animationPlayerCase.play("HideCase")
		hideSelectors()
		showHideTimer.start()	

func triggerOpenBox() -> void:
	if bagState == BAG_STATES.CLOSED:
		bagState = BAG_STATES.OPENING
		animationPlayerBag.play("PlayerOpenBox")
		openCloseTimer.start()
		currentMode = MODES.INVENTORY

func triggerCloseBox() -> void:
	triggerHideCase()
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
	if itemsInBag.keys().size() > 0:
		selectedPointer = 0
		var firstItemKey = itemsInBag.keys()[selectedPointer]
		selectedItem = itemsInBag.get(firstItemKey)
		if selectedItem != null:
			selectedItem.HighlightPickUp()
	

func _on_show_hide_timer_timeout() -> void:
	if caseState == CASE_STATES.SHOWING:
		caseState = CASE_STATES.SHOW
		setUpBoard()
	elif caseState == CASE_STATES.HIDING:
		caseState = CASE_STATES.HIDE
