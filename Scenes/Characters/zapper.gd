extends Node2D

class_name Zapper

@onready var removeTimer :Timer = $Timer
@onready var animationPlayer :AnimationPlayer = $AnimationPlayer


const ZAPPER_ENERGY_COST : float = 1.0

var isOn : bool = false
var damage : float = 1.0

func energyCost() -> void:
	Globals.currentPower -= ZAPPER_ENERGY_COST

func startZap(flip: bool) -> bool:
	
	var zapPower := getZapperPower()
	if zapPower <= 0:
		return false
	Globals.requestTempLight(global_position, TempLight.LightType.LIGHTNING)
	damage = float(zapPower) 
	isOn = true
	energyCost()
	removeTimer.start()
	var parentNode = get_parent()
	rotation = parentNode.midPoint.rotation
	var direction :String = "R"
	if flip:
		direction = "L"
	if zapPower > 5:
		zapPower=5
	var animationName :String = direction +"Zap" + str(zapPower)
	animationPlayer.play(animationName)
	return true
	
func getZapperPower() -> int:
	var zapPower:int = 0
	if Globals.isPickUpOn(PickUp.PickUpType.ZAP):
		zapPower += 1
	if Globals.isPickUpOn(PickUp.PickUpType.ZAP2):
		zapPower += 2
	if Globals.isPickUpOn(PickUp.PickUpType.ZAP3):
		zapPower += 3
	
	return zapPower
	
func _on_area_2d_body_entered(body:Node2D) -> void:
	if isOn and body is not Dydimo:
		Globals.moveSparkEffect(body.global_position, body.rotation, false, "SmallHit")
		# print("Zapper hit enemy: ", body.name)
		# if body is GoodyBox:
		# 	body.destroy()	
		if body is Enemy:
			var parent = get_parent()
			body.receieveDamage(parent, false, damage) #replace with level
		elif body is SpareParts:
			body.destroy()
		
		elif body is CharacterBody2D:
			var parentNode = body.get_parent()
			if parentNode is GoodyBox:
				parentNode.destroy()


func _on_timer_timeout() -> void:
	isOn = false
	
