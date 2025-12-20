extends Node2D

@onready var panelAttributes : Panel = $MainEditorInterface/AttributesPanel
@onready var panelEffects : Panel = $MainEditorInterface/EffectsPanel
@onready var panelAbilities : Panel = $MainEditorInterface/AbilitiesPanel
@onready var panelWorld : Panel = $MainEditorInterface/WorldPanel
@onready var allAttributesItemsList : ItemList = $MainEditorInterface/WorldPanel/AllAttributeList
@onready var worldAttributesItemsList : ItemList = $MainEditorInterface/WorldPanel/SelectedWorldAttributeList


var attributeSelected:AttributeType  = null

enum TAB {
	Attributes,
	Effects,
	Abilities,
	World
}


func _ready() -> void:
	hideAllPanels()
	panelAttributes.show()
	#for i in range(0, 100):
	#	var testLabel := Label.new()
	#	testLabel.text = "Test Label " + str(i)
	#	$MainEditorInterface/AttributesPanel/ScrollContainer/VBoxContainer.add_child(testLabel)

var changeToMainScene := func() -> void:
	Globals.transitionTo("mainMenu")

func _on_exit_screen_button_pressed() -> void:
	var popUpsInGroup :Array[Node]  = get_tree().get_nodes_in_group("PopUps")

	if popUpsInGroup.size()==0:
		var newPopUp := Globals.addToMainScene("popUp")
		newPopUp.yesFunction = changeToMainScene


func _on_exit_screen_button_released() -> void:
	pass 


func hideAllPanels() -> void:
	panelAttributes.hide()
	panelEffects.hide()
	panelAbilities.hide()
	panelWorld.hide()

func _on_tab_bar_tab_changed(tab: int) -> void:
	hideAllPanels()
	match tab:
		TAB.Attributes:
			panelAttributes.show()
		TAB.Effects:
			panelEffects.show()
		TAB.Abilities:
			panelAbilities.show()
		TAB.World:
			populateAttributeList(allAttributesItemsList)
			populateWorldAttributeList(worldAttributesItemsList)
			panelWorld.show()

func clearAttributeSelection() -> void:
	attributeSelected = AttributeType.new()
	$MainEditorInterface/AttributesPanel/InputPanel/nameLabel/LineEdit.text=""
	$MainEditorInterface/AttributesPanel/InputPanel/valueLabel/LineEdit.text=""
	

func attribute_on_add_button_button_up() -> void:
	clearAttributeMessage()
	clearAttributeSelection()

func getSelectedItemFromList(itemList :ItemList) -> String:
	for i in range(itemList.get_item_count()):
		if itemList.is_selected(i):
			return itemList.get_item_text(i)
	return ""

func crateAttributeDataType() -> AttributeType.DATA_TYPE:
	var  selectedDataType :String = getSelectedItemFromList($MainEditorInterface/AttributesPanel/InputPanel/dataType/ItemList)
	if	selectedDataType == "Integer":
		return AttributeType.DATA_TYPE.INT
	if	selectedDataType == "Float":
		return AttributeType.DATA_TYPE.FLOAT
	if	selectedDataType == "Boolean":
		return AttributeType.DATA_TYPE.BOOLEAN
	return AttributeType.DATA_TYPE.STRING	

func setAttributeValues(attribute :AttributeType) -> void:
	attribute.name = $MainEditorInterface/AttributesPanel/InputPanel/nameLabel/LineEdit.text
	attribute.dataType = crateAttributeDataType()
	var  valuecontents :String = $MainEditorInterface/AttributesPanel/InputPanel/valueLabel/LineEdit.text
	var  selectedDataType :String = getSelectedItemFromList($MainEditorInterface/AttributesPanel/InputPanel/dataType/ItemList)
	var  iconContents :String  = $MainEditorInterface/AttributesPanel/InputPanel/iconLabel/LineEdit.text
	if iconContents != null  and iconContents != "":
		attribute.iconValue = iconContents
	if	selectedDataType == "Integer":
		attribute.intValue = int(valuecontents)
	elif	selectedDataType == "Float":
		attribute.floatValue = float(valuecontents)
	elif	selectedDataType == "Boolean":
		attribute.boolValue = false
		if valuecontents == "true"  or  valuecontents == "True" or valuecontents == "TRUE" or valuecontents == "1" :
			attribute.boolValue = true
	else	:
		attribute.stringValue = valuecontents
	
func loadAttributeToScreen(attribute :AttributeType) -> void:
	print("Loading attribute to screen")
	$MainEditorInterface/AttributesPanel/InputPanel/nameLabel/LineEdit.text = attribute.name
	$MainEditorInterface/AttributesPanel/InputPanel/iconLabel/TextureRect.texture = Globals.imageMap.get($MainEditorInterface/AttributesPanel/InputPanel/iconLabel/LineEdit.text)
	$MainEditorInterface/AttributesPanel/InputPanel/valueLabel/LineEdit.text = str(attribute.getValue())
	var dataType :String = "String"
	match attribute.dataType:
		AttributeType.DATA_TYPE.INT:
			dataType = "Integer"
		AttributeType.DATA_TYPE.FLOAT:
			dataType = "Float"
		AttributeType.DATA_TYPE.BOOLEAN:
			dataType = "Boolean"
	attributeSelected = attribute
	for i in range($MainEditorInterface/AttributesPanel/InputPanel/dataType/ItemList.get_item_count()):
		if $MainEditorInterface/AttributesPanel/InputPanel/dataType/ItemList.get_item_text(i) == dataType:
			$MainEditorInterface/AttributesPanel/InputPanel/dataType/ItemList.select(i)
			break

func createAttribute() -> AttributeType:
	var attribute :AttributeType = AttributeType.new()
	attribute.name = $MainEditorInterface/AttributesPanel/InputPanel/nameLabel/LineEdit.text
	setAttributeValues(attribute)
	return attribute

func attribute_on_ok_button_button_up() -> void:
	clearAttributeMessage()
	if valid_attribute_values():

		var savedAttribute:AttributeType = createAttribute()
		var key:String = savedAttribute.name
		var existingAttribute :AttributeType = Globals.allResources.allAttributes.get(key)
		# if existingAttribute == null:
		# Globals.allResources.allAttributes.put(key, savedAttribute)
		# else:
		Globals.allResources.allAttributes[key] = savedAttribute
		attributeSelected = savedAttribute
		 #try to load existing AllAttributes resource
		# if allAttributes == null:
		# 	allAttributes = AllAttributes.new()
		# 	Globals.gdMap["AllAttributes"] = allAttributes
		# if allAttributes.attributes.has(key):
		# 	allAttributes.attributes[key] = savedAttribute
		# else:
		# 	allAttributes.attributes[key] = savedAttribute
		Globals.saveResources()
		displayAttributeMessage("Attribute saved")
		#reload the attribute to screen to make sure it is correctly displayed
		loadAttributeToScreen(savedAttribute)
		get($MainEditorInterface/AttributesPanel/InputPanel/iconLabel/LineEdit.text)

func clearAttributeMessage() -> void:
	$MainEditorInterface/AttributesPanel/Messages.text = ""

func displayAttributeMessage(message: String) -> void:
	$MainEditorInterface/AttributesPanel/Messages.text = message

func valid_attribute_values() -> bool:
	var  nameContents :String = $MainEditorInterface/AttributesPanel/InputPanel/nameLabel/LineEdit.text
	var  valuecontents :String = $MainEditorInterface/AttributesPanel/InputPanel/valueLabel/LineEdit.text
	var  selectedDataType :String = getSelectedItemFromList($MainEditorInterface/AttributesPanel/InputPanel/dataType/ItemList)
	var iconContents :String  = $MainEditorInterface/AttributesPanel/InputPanel/iconLabel/LineEdit.text
	if nameContents == null  or nameContents == "":
		displayAttributeMessage("Attribute name cannot be empty")
		return false
	if valuecontents == null or valuecontents == "":
		displayAttributeMessage("Attribute value cannot be empty")
		return false
	if selectedDataType == null or selectedDataType == "":
		displayAttributeMessage("Attribute dataType cannot be empty")
		return false
	if	selectedDataType == "Integer":
		if not valuecontents.is_valid_int():
			displayAttributeMessage("Value must be an integer")
			return false
	if	selectedDataType == "Float":
		if not valuecontents.is_valid_float():
			displayAttributeMessage("Value must be a float")
			return false	
	if	selectedDataType == "Boolean":
		if not (valuecontents == "true" or valuecontents == "false" or  valuecontents == "True" or valuecontents == "False" or valuecontents == "TRUE" or valuecontents == "FALSE" or valuecontents == "1" or valuecontents == "0"):
			displayAttributeMessage("Value must be a Boolean (true/false)")
			return false	
	if iconContents != null  and iconContents != "":
		if not Globals.imageMap.has(iconContents):
			displayAttributeMessage("Icon does not exist in image map")
			return false

	return true

func findAttributePointer(attributeName:String) -> int:
	var keys:Array = Globals.allResources.allAttributes.keys()
	for i in range(keys.size()):
		if keys[i] == attributeName:
			return i
	return 0

func findAttributeByPointer(pointer:int) -> AttributeType:
	var keys:Array = Globals.allResources.allAttributes.keys()
	if pointer < 0 or pointer >= keys.size():
		return null
	var key:String = keys[pointer]
	return Globals.allResources.allAttributes.get(key)
	

func _on_previous_button_button_up() -> void:
	# attributeSelected
	var attributePointer:int = 0 
	if  attributeSelected != null:
		attributePointer = findAttributePointer(attributeSelected.name)
	if attributePointer == 0:
		attributePointer = Globals.allResources.allAttributes.size()
	attributePointer = attributePointer -1
	attributeSelected = findAttributeByPointer(attributePointer)
	loadAttributeToScreen(attributeSelected)



func _on_next_button_button_up() -> void:
	var attributePointer:int = 0 
	if  attributeSelected != null:
		attributePointer = findAttributePointer(attributeSelected.name)
	if attributePointer == Globals.allResources.allAttributes.size()-1:
		attributePointer = -1
	attributePointer = attributePointer +1
	attributeSelected = findAttributeByPointer(attributePointer)
	loadAttributeToScreen(attributeSelected)


func _on_delete_button_button_up() -> void:
	if attributeSelected != null and attributeSelected.name != null and attributeSelected.name != "":
		var key:String = attributeSelected.name
		if Globals.allResources.allAttributes.has(key):
			if not canDeleteSelectedAttribute(key):
				return	
			Globals.allResources.allAttributes.erase(key)
			Globals.saveResources()
			
			clearAttributeSelection()
			_on_previous_button_button_up() 
			displayAttributeMessage("Attribute deleted")
		else:
			displayAttributeMessage("Attribute not found to delete")
	else:
		displayAttributeMessage("No attribute selected to delete")

func canDeleteSelectedAttribute(key:String) -> bool:
	if key != null and key != "":
		if Globals.allResources.worldAttributes.has(key):
			displayAttributeMessage("Attribute user By World Attributes")
			return false
	return true

func populateAttributeList(itemList:ItemList) -> void:
	itemList.clear()
	var keys:Array = Globals.allResources.allAttributes.keys()
	for i in range(keys.size()):
		var key = keys[i]
		var attribute = Globals.allResources.allAttributes[key]
		itemList.add_item(key)
		if attribute.iconValue != null and attribute.iconValue != "":
			var icon = Globals.imageMap.get(attribute.iconValue)
			if icon:
				itemList.set_item_icon(i, icon)

func populateWorldAttributeList(itemList:ItemList) -> void:
	itemList.clear()
	var keys:Array = Globals.allResources.worldAttributes.keys()
	for i in range(keys.size()):
		var key = keys[i]
		var attribute = Globals.allResources.worldAttributes[key]
		itemList.add_item(key)
		if attribute.iconValue != null and attribute.iconValue != "":
			var icon = Globals.imageMap.get(attribute.iconValue)
			if icon:
				itemList.set_item_icon(i, icon)
		# if not canDeleteSelectedWorldAttribute(key):
		# 	itemList.set_item_disabled(i, true)
		


func _on_select_world_attribute_released() -> void:
	for i in range(allAttributesItemsList.get_item_count()):
		if allAttributesItemsList.is_selected(i):
			if Globals.allResources.worldAttributes.get(allAttributesItemsList.get_item_text(i))==null:
				var attributeToAdd:AttributeType = Globals.allResources.allAttributes.get(allAttributesItemsList.get_item_text(i))
				Globals.allResources.worldAttributes[attributeToAdd.name] = attributeToAdd
				#
	populateWorldAttributeList(worldAttributesItemsList)
	Globals.saveResources()



func _on_remove_world_attribute_2_released() -> void:
	for i in range(worldAttributesItemsList.get_item_count()):
		if worldAttributesItemsList.is_selected(i):
			
			var key:String = worldAttributesItemsList.get_item_text(i)
			if canDeleteSelectedWorldAttribute(key):
				if Globals.allResources.worldAttributes.get(key)!=null:
					Globals.allResources.worldAttributes.erase(worldAttributesItemsList.get_item_text(i))
	populateWorldAttributeList(worldAttributesItemsList)
	Globals.saveResources()

func canDeleteSelectedWorldAttribute(key:String) -> bool:
	#TODO check if attribute is used elsewhere
	return true


#TODO the last time you added a sort of pick list for world attributes.