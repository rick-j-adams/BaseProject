class_name AttributeType
extends Resource

enum DATA_TYPE {
	STRING,
	INT,
	FLOAT,
	BOOLEAN
}    

@export var name :String = "New Attribute"
@export var dataType: DATA_TYPE = DATA_TYPE.INT
@export var stringValue : String = "DefaultValue"
@export var intValue: int = 1
@export var floatValue :float   = 1.0
@export var boolValue : bool  = true
@export var iconValue : String = "no"

func getValue() -> Variant:
	match dataType:
		DATA_TYPE.STRING:
			return stringValue
		DATA_TYPE.INT:
			return intValue
		DATA_TYPE.FLOAT:
			return floatValue
		DATA_TYPE.BOOLEAN:
			return boolValue
	# Default case, should not happen
	return null

func setValue(value: Variant) -> void:
	match dataType:
		DATA_TYPE.STRING:
			stringValue = value
		DATA_TYPE.INT:
			intValue = value
		DATA_TYPE.FLOAT:
			floatValue = value
		DATA_TYPE.BOOLEAN:
			boolValue = value   
