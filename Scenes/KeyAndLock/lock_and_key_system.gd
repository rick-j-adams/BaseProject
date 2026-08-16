extends Node2D

class_name LockAndKeySystem

var door:Door = null
var batteryReceptacleWallMount:BatteryReceptacleWallMount = null
var switch:Switch = null

@onready var timerCheckSystemState : Timer = $TimerCheckSystemState

func _ready() -> void:
	for node in get_children():
		if node is Door:
			door = node
			door.lockAndKeySystem = self

		if node is BatteryReceptacleWallMount:
			batteryReceptacleWallMount = node
			batteryReceptacleWallMount.lockAndKeySystem = self

		if node is Switch:
			switch = node
			switch.lockAndKeySystem = self
	timerCheckSystemState.start()
	



func systemHasPower() -> bool:
	if batteryReceptacleWallMount !=null and batteryReceptacleWallMount.hasBattery:
		return true
	return false

func powerOnSystem() -> void:
	if systemHasPower():
		if switch != null:
			switch.powerOn()
		if door != null:
			door.hasPower =true
			door.setUpType()
			
		
func powerOffSystem() -> void:
	if not systemHasPower():
		if switch != null:
			switch.powerOff()
		if door != null:
			door.hasPower = false
			door.setUpType()

func switchOn() -> void:
	if systemHasPower():
		if door != null:
			door.openDoor()

func switchOff() -> void:
	if systemHasPower():
		if door != null:
			door.closeDoor()


func _on_timer_check_system_state_timeout() -> void:
	if batteryReceptacleWallMount != null:
		if batteryReceptacleWallMount.hasBattery:
			powerOnSystem()		
		else: 
			powerOffSystem()
	timerCheckSystemState.stop()
