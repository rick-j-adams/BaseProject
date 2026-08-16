extends Node2D


@onready var entryPoints :Node2D = $EntryPoints
@onready var enemies :Node2D = $Enemies
@onready var pickUps :Node2D = $PickUps
@onready var maskRevealAreas :Node2D = $MaskRevealAreas


func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.is_in_group("actor"):
		if body is Dydimo:
			body.explode()

func getLevelLimts () -> Array:
	var left:float= 0 
	var top :float= 0 
	var right:float = 0 
	var bottom:float =0
	for node in entryPoints.get_children():
		if node.global_position.x < left :
			left=node.global_position.x
		if node.global_position.x > right :
			right=node.global_position.x
		if node.global_position.y < top :
			top=node.global_position.y
		if node.global_position.y > bottom :
			bottom=node.global_position.y
	return [left,top,right,bottom ]

func resetLevel() -> void:
	for node in pickUps.get_children():
		if node is PickUp:
			var pickUpDetails = Globals.allResources.allPickUps.get(node.pickUpType)
			if pickUpDetails !=null:
				if pickUpDetails.get("pickedUp"): 
					node.queue_free()
	
	for node in enemies.get_children():
		if node is Enemy or node is GoodyBox:
			var levelDetails =  Globals.allResources.allLevels.get(Globals.currentLevel)
			if levelDetails != null:
				for cid in  levelDetails.get("culled"):
					if cid == node.levelId:
						node.queue_free()
				 
# PickUp.PickUpType.JUMP: {"category": "expansion", "pickedUp"		
func getMaskRevealDictionary() -> Dictionary:
	var levelDetails = Globals.allResources.allLevels.get(Globals.currentLevel)
	var levelMaskDetails = levelDetails.get("levelMasks")
	if levelMaskDetails.size() == 0:
		var maskDetailsDictionary:Dictionary = {}
		for node in maskRevealAreas.get_children():
			if node is MaskRevealArea:
				var maskDetails :Array = [node.isOn, false]
				maskDetailsDictionary.set(node.maskNumber , maskDetails )
		levelDetails.set("levelMasks", maskDetailsDictionary)
		levelMaskDetails = maskDetailsDictionary
	return levelMaskDetails


func findEntryPointsPosition(entryPointsName:String) -> Vector2:
	for node in entryPoints.get_children():
		if node.name == entryPointsName:
			return node.global_position
	return Vector2(0.0,0.0)
