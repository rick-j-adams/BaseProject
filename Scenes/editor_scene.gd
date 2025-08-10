extends Node2D

@onready var panelAttributes : Panel = $MainEditorInterface/AttributesPanel
@onready var panelEffects : Panel = $MainEditorInterface/EffectsPanel
@onready var panelAbilities : Panel = $MainEditorInterface/AbilitiesPanel

var attributeSelected  = null

enum TAB {
	Attributes,
	Effects,
	Abilities
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

func _on_tab_bar_tab_changed(tab: int) -> void:
	hideAllPanels()
	match tab:
		TAB.Attributes:
			panelAttributes.show()
		TAB.Effects:
			panelEffects.show()
		TAB.Abilities:
			panelAbilities.show()

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
		var savedAttribute = createAttribute()
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
			displayAttributeMessage("Value must be an float")
			return false	
	if	selectedDataType == "Boolean":
		if not (valuecontents == "true" or valuecontents == "false" or  valuecontents == "True" or valuecontents == "False" or valuecontents == "TRUE" or valuecontents == "FALSE" or valuecontents == "1" or valuecontents == "0"):
			displayAttributeMessage("Value must be an Boolean (true/false)")
			return false	
	if iconContents != null  and iconContents != "":
		if not Globals.imageMap.has(iconContents):
			displayAttributeMessage("Icon does not exist in image map")
			return false

	return true


#TODO: you just add the attribute UI, need to next load the Data resource and save the attribute to it