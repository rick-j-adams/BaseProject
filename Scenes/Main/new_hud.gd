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

@onready var batteryHole1 :RPoint = get_node_or_null("PanelContainerCase/RPointBatteryHole1")
@onready var batteryHole2 :RPoint = get_node_or_null("PanelContainerCase/RPointBatteryHole2")
@onready var batteryHole3 :RPoint = get_node_or_null("PanelContainerCase/RPointBatteryHole3")
@onready var batteryHole4 :RPoint = get_node_or_null("PanelContainerCase/RPointBatteryHole4")

@onready var battery1 :Sprite2D = get_node_or_null("PanelContainerCase/BatteryHoles/Sprite2DBattery1")
@onready var battery2 :Sprite2D = get_node_or_null("PanelContainerCase/BatteryHoles/Sprite2DBattery2")
@onready var battery3 :Sprite2D = get_node_or_null("PanelContainerCase/BatteryHoles/Sprite2DBattery3")
@onready var battery4 :Sprite2D = get_node_or_null("PanelContainerCase/BatteryHoles/Sprite2DBattery4")

@onready var mainBoard :Sprite2D = $PanelContainerCase/Sprite2DBoard


var boards:Array = [board1,board2,board3,board4,board5,board6,board7]

var selectedItem : PickUp = null
var selectedPointer : int = 0
var currentMode : MODES = MODES.PLAY

var bagState:BAG_STATES = BAG_STATES.CLOSED
var caseState: CASE_STATES = CASE_STATES.HIDE

var itemsInBag : Dictionary = {}
var itemSize:int = 64
var itemWidth:int= 6

var boardSlotList:Array = [slotOne2, slotOne4, slotOne5 ,slotOne6]
var boardSlotPosition:int = 0

var batteryHoleList:Array = [batteryHole1,batteryHole2]
var batteryPosition:int = 0
var batties:Array = [battery1,battery2,battery3,battery4 ]

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
	if currentMode == MODES.BATTERY:
		batteryInput()
		
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
	placeBoard()

func batteryInput() -> void:
	if caseState == CASE_STATES.SHOW and Input.is_action_just_released("ui_right"):
		batteryPosition += 1
		if batteryPosition >= len(batteryHoleList):
			batteryPosition = 0
		moveBatterySelector()
	if caseState == CASE_STATES.SHOW and Input.is_action_just_released("ui_left"):
		batteryPosition -= 1
		if batteryPosition < 0:
			batteryPosition = len(batteryHoleList) - 1
		moveBatterySelector()
	if caseState == CASE_STATES.SHOW and Input.is_action_just_released("ui_select"):
		changeSelectedBattery()

func changeSelectedBattery() -> void:
	hideSelectors()
	currentMode = MODES.INVENTORY
	var pickUpType:PickUp.PickUpType = getPickUpInBatterySlot(batteryPosition)
	if pickUpType != PickUp.PickUpType.NONE:
		Globals.allResources.allPickUps.get(pickUpType).set("slotNo", -1)
		Globals.allResources.allPickUps.get(pickUpType).set("pluggedIn", false)
	Globals.playInterfaceAudio(batteryHoleList[batteryPosition].position, "click")
	Globals.allResources.allPickUps.get(selectedItem.pickUpType).set("slotNo", batteryPosition)
	Globals.allResources.allPickUps.get(selectedItem.pickUpType).set("pluggedIn", true)
	placeBattery()

func getPickUpInSlot(slotNo:int)->PickUp.PickUpType:
	for potentialItem in Globals.allResources.allPickUps.keys():
		var itemData = Globals.allResources.allPickUps.get(potentialItem)
		if itemData != null and itemData.get("category")=="expansion":
			var whichSlot:int = itemData.get("slotNo")
			if whichSlot==slotNo:
				return potentialItem
	return PickUp.PickUpType.NONE

func getPickUpInBatterySlot(slotNo:int)->PickUp.PickUpType:
	for potentialItem in Globals.allResources.allPickUps.keys():
		var itemData = Globals.allResources.allPickUps.get(potentialItem)
		if itemData != null and itemData.get("category")=="battery":
			var whichSlot:int = itemData.get("slotNo")
			if whichSlot==slotNo:
				return potentialItem
	return PickUp.PickUpType.NONE

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
				if whichSlot >=len(boardSlotList):
					Globals.allResources.allPickUps.get(potentialItem).set("slotNo",-1)
					Globals.allResources.allPickUps.get(potentialItem).set("pluggedIn",false)


func placeBattery() -> void:
	var batteryCount:int = 0
	for batterySprite:Sprite2D in batties:
		if batterySprite != null:
			batterySprite.visible=false
	for potentialItem in Globals.allResources.allPickUps.keys():
		var itemData = Globals.allResources.allPickUps.get(potentialItem)
		if itemData != null and itemData.get("category") == "battery":
			if itemData.get("pluggedIn") == true:
				var whichSlot:int = itemData.get("slotNo")
				if whichSlot >=0 and whichSlot < len(batteryHoleList) and batteryCount < len(batties):
					var batterySprite:Sprite2D = batties[batteryCount]
					
					if batterySprite != null:
						batterySprite.visible = true
						batterySprite.position = batteryHoleList[whichSlot].position
						batterySprite.texture = Globals.getTextureByName(itemData.get("texture")+"Top")
						batteryCount += 1

func setUpDisplayedBits()->void:
	boards.clear()
	boards.append(board1)
	boards.append(board2)
	boards.append(board3)
	boards.append(board4)
	boards.append(board5)
	boards.append(board6)
	boards.append(board7)

	batties.clear()
	if battery1 != null:
		batties.append(battery1)
	if battery2 != null:
		batties.append(battery2)
	if battery3 != null:
		batties.append(battery3)
	if battery4 != null:
		batties.append(battery4)

func setUpBoard()->void:
	setUpDisplayedBits()
	batteryHoleList.clear()
	boardSlotList.clear()

	if getMainBoard()=="MainBoard1":
		setUpMainBoard1()
	if getMainBoard()=="MainBoard2":
		setUpMainBoard2()
	if getMainBoard()=="MainBoard3":
		setUpMainBoard3()
	if getMainBoard()=="MainBoard4":
		setUpMainBoard4()
	
func setUpMainBoard2()->void:
	boardSlotList.append(slotOne2)
	boardSlotList.append(slotOne4)
	boardSlotList.append(slotOne5)
	boardSlotList.append(slotOne6)
	if batteryHole1 != null:
		batteryHoleList.append(batteryHole1)
		batteryHole1.position = Vector2(183.0,414.0)
	if batteryHole2 != null:
		batteryHoleList.append(batteryHole2)
		batteryHole2.position = Vector2(374.0,414.0)	
	if batteryHole3 != null:
		batteryHoleList.append(batteryHole3)
		batteryHole3.position = Vector2(374.0,358.0)	

func setUpMainBoard3()->void:
	boardSlotList.append(slotOne2)
	boardSlotList.append(slotOne3)
	boardSlotList.append(slotOne4)
	boardSlotList.append(slotOne5)
	boardSlotList.append(slotOne6)
	if batteryHole1 != null:
		batteryHoleList.append(batteryHole1)
		batteryHole1.position = Vector2(183.0,376.0)
	if batteryHole2 != null:
		batteryHoleList.append(batteryHole2)
		batteryHole2.position = Vector2(374.0,376.0)	
	if batteryHole3 != null:
		batteryHoleList.append(batteryHole3)
		batteryHole3.position = Vector2(183.0,441.0)	
	if batteryHole4 != null:
		batteryHoleList.append(batteryHole4)
		batteryHole4.position = Vector2(374.0,441.0)

func setUpMainBoard4()->void:
	boardSlotList.append(slotOne1)
	boardSlotList.append(slotOne2)
	boardSlotList.append(slotOne3)
	boardSlotList.append(slotOne4)
	boardSlotList.append(slotOne5)
	boardSlotList.append(slotOne6)
	boardSlotList.append(slotOne7)

	
	if batteryHole2 != null:
		batteryHoleList.append(batteryHole2)
		batteryHole2.position = Vector2(374.0,376.0)	
	if batteryHole3 != null:
		batteryHoleList.append(batteryHole3)
		batteryHole3.position = Vector2(183.0,441.0)	
	if batteryHole4 != null:
		batteryHoleList.append(batteryHole4)
		batteryHole4.position = Vector2(374.0,441.0)

func setUpMainBoard1()->void:
	boardSlotList.append(slotOne2)
	boardSlotList.append(slotOne4)
	boardSlotList.append(slotOne5)
	boardSlotList.append(slotOne6)

	if batteryHole1 != null: 
		batteryHoleList.append(batteryHole1)
		batteryHole1.position = Vector2(183.0,414.0)
	if batteryHole2 != null:
		batteryHoleList.append(batteryHole2)
		batteryHole2.position = Vector2(374.0,414.0)

func moveSlotSelector()->void:
	if boardSlotPosition>=len(boardSlotList):
		boardSlotPosition=0
	slotSelector.position=boardSlotList[boardSlotPosition].position

func moveBatterySelector() -> void:
	if batteryHoleList.size() > 0 and batteryPosition >= 0 and batteryPosition < len(batteryHoleList):
		batterySelector.position = batteryHoleList[batteryPosition].position
	
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
		if caseState == CASE_STATES.SHOW:
			var selectedCategory = Globals.allResources.allPickUps.get(selectedItem.pickUpType).get("category")
			if selectedCategory == "expansion":
				slotSelector.visible=true
				currentMode=MODES.EXPANSION
				moveSlotSelector()
			elif selectedCategory == "battery":
				batterySelector.visible=true
				currentMode=MODES.BATTERY
				moveBatterySelector()
			elif selectedCategory == "motherboard":
				setMainBoard()


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
	var newpostion = Vector2(itemSize*1.5, itemSize*1.5)
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
					newpostion.x = itemSize*1.5
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


func getMainBoard()->String:
	var mbName = Globals.getGameProperyNoDefault("mainBoard")
	if mbName==null:
		Globals.setGamePropery("mainBoard", "MainBoard1")
		mbName = Globals.getGameProperyNoDefault("mainBoard")
	print("getMainBoard:"+mbName)
	return mbName
	
func setMainBoard() -> void:
	var namedTexture:String = Globals.allResources.allPickUps.get(selectedItem.pickUpType).get("texture")
	if namedTexture == "PUMB1":
		Globals.setGamePropery("mainBoard", "MainBoard1")
	if namedTexture == "PUMB2":
		Globals.setGamePropery("mainBoard", "MainBoard2")
	if namedTexture == "PUMB3":
		Globals.setGamePropery("mainBoard", "MainBoard3")
	if namedTexture == "PUMB4":
		Globals.setGamePropery("mainBoard", "MainBoard4")	
	mainBoard.texture=Globals.getTextureByName(Globals.getGameProperyNoDefault("mainBoard"))
	setUpBoard()
	placeBattery()
	placeBoard()
