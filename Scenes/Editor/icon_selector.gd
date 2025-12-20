extends Node2D

var allIconsMap: Dictionary = {}

const MAXNUM_ICONS : int = 8
const ICONSPACING : int = 40
const SELECTNAME : String = "Select"


var minPoint : int = -1
var maxPoint : int = -1

var buttons :Array
var buttonIconMap: Dictionary = {}

var lastSelectedIcon : String = ""

func _ready():
	minPoint=-1
	maxPoint=-1
	resetAllIcons()
	setUpButton()
	
func resetAllIcons():
	allIconsMap.clear()
	for iconkey in Globals.imageMap.keys():
		if iconkey.begins_with("ICON"):
			#var iconVailue = Globals.imageMap.get(iconkey)
			allIconsMap[iconkey] = iconkey

func setUpButton():
	# Clear any existing buttons first
	for child in $Border/Background.get_children():
		child.queue_free()
	
	# Create buttons up to MAXNUM_ICONS or number of available icons
	var numIcons:int = min(MAXNUM_ICONS, allIconsMap.size())
	var xPostion:int = 4
	for i in range(numIcons):
		var button = TextureButton.new()
		button.texture_normal =  Globals.imageMap.get(allIconsMap.get(allIconsMap.keys()[i]))
		button.position.y = i * ICONSPACING  
		if minPoint <0 :
			minPoint=button.position.y-(ICONSPACING*2)
		button.position.x= button.position.x+xPostion
		button.name = SELECTNAME + str(i)
		buttonIconMap[SELECTNAME + str(i)] = i
		button.pressed.connect(_on_button_pressed.bind(i))
		buttons.append(button)
		$Border/Background.add_child(button)
		maxPoint=button.position.y

func _on_button_pressed(button_index: int) -> void:
	# Handle button press here
	var buttonName = buttons[button_index].name
	var icon_name = allIconsMap.keys()[buttonIconMap.get(buttonName)]
	lastSelectedIcon = icon_name
	print("Button " + str(button_index) + ":"+buttonName+" pressed. Selected icon: " + lastSelectedIcon)

func moveSelector(button ,direction: int) -> void:
	
	print("Wrapping button: " + button.name)
	print("orginal index: " + str(buttonIconMap[button.name]))
	if buttonIconMap.has(button.name):
		buttonIconMap[button.name]=buttonIconMap[button.name]+direction
		if buttonIconMap[button.name] >= allIconsMap.size():
			buttonIconMap[button.name]=0
		if buttonIconMap[button.name]<0:
			buttonIconMap[button.name]=allIconsMap.size()-1
		var icon_name =  allIconsMap.keys()[buttonIconMap.get(button.name)]
		button.texture_normal = Globals.imageMap.get(icon_name)
		button.modulate = Color(Color.BLUE)
	print("new index: " + str(buttonIconMap[button.name]))

func _on_down_touch_screen_button_pressed() -> void:
	print("Down button pressed")
	for button in buttons:
		button.position.y += ICONSPACING
		if button.position.y > maxPoint:
			button.position.y = minPoint
			moveSelector(button, MAXNUM_ICONS)	

func _on_up_touch_screen_button_pressed() -> void:
	print("Up button pressed")
	for button in buttons:
		button.position.y -= ICONSPACING
		if button.position.y < minPoint:
			button.position.y = maxPoint
			moveSelector(button, -MAXNUM_ICONS)
