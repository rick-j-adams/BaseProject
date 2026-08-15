extends Node2D

const WIDTH : float = 960

enum LOAD_STATES {SCENES, IMAGES, AUDIO, GD, DATA, FINISHED, DONE}
var currentloadState = LOAD_STATES.SCENES

@onready var loadingBar: ColorRect = $ColorRect

@onready var loadMapScenes :Dictionary  = {
	"mainMenu": "res://Scenes/Title.tscn",
	"editorScene" : "res://Scenes/EditorScene.tscn",
	"popUp" : "res://Scenes/PopUp.tscn",
	"gameWindow" : "res://Scenes/Main/GameWindow.tscn",
	"credits" : "res://Scenes/Credits.tscn",
	"sparkEffect" :"res://Images/Character/SparkEffects.tscn",
	"puffEffect" :"res://Scenes/Effects/Puff.tscn",
	"puffMachine" :"res://Scenes/Effects/PuffMachine.tscn",
	"bitMachine" :"res://Scenes/Effects/BitMachine.tscn",
	"bitPayMachine" :"res://Scenes/Effects/BitPayMachine.tscn",
	"bit" :"res://Scenes/Props/Bit.tscn",
	"element" :"res://Scenes/Effects/Element.tscn",
	"pickUp" :"res://Scenes/PickUps/PickUp.tscn",
	"tempLight" :"res://Scenes/Effects/TempLight.tscn",
	"test" :"res://Scenes/TestLevel/TestLevel.tscn",

}

@onready var loadMapImages :Dictionary  = {
	"yes" : "res://Images/System/UIConfirmButtonUp.png",
	"no" : "res://Images/System/UINegateButtonUp.png",
	"blacksquare" : "res://Images/Icons/blacksquare.png",
	"heart" : "res://Images/Icons/heart.png",
	"ICONheart" : "res://Images/Icons/heart.png",
	"ICONalarm" : "res://Images/Icons/alarm.png",
	"ICONarrow1" : "res://Images/Icons/arrow1.png",
	"ICONarrow2" : "res://Images/Icons/arrow2.png",
	"ICONcomet" : "res://Images/Icons/comet.png",
	"ICONdot" : "res://Images/Icons/dot.png",
	"ICONdown" : "res://Images/Icons/down.png",
	"ICONfan" : "res://Images/Icons/fan.png",
	"ICONgear1" : "res://Images/Icons/gear1.png",
	"ICONgear2" : "res://Images/Icons/gear2.png",
	"ICONgear3" : "res://Images/Icons/gear3.png",
	"ICONland" : "res://Images/Icons/land.png",
	"ICONlaunch" : "res://Images/Icons/launch.png",
	"ICONleft" : "res://Images/Icons/left.png",
	"ICONlightning" : "res://Images/Icons/lightning.png",
	"ICONlowdial" : "res://Images/Icons/lowdial.png",
	"ICONmaxdial" : "res://Images/Icons/maxdial.png",
	"ICONquestion" : "res://Images/Icons/quetion.png",
	"ICONradar" : "res://Images/Icons/radar.png",
	"ICONright" : "res://Images/Icons/right.png",
	"ICONshell" : "res://Images/Icons/shell.png",
	"ICONshield" : "res://Images/Icons/shield.png",
	"ICONspanner" : "res://Images/Icons/spanner.png",
	"ICONspeach" : "res://Images/Icons/speach.png",
	"ICONspeed" : "res://Images/Icons/speed.png",
	"ICONstamp" : "res://Images/Icons/stamp.png",
	"ICONstar" : "res://Images/Icons/star.png",
	"ICONtarget" : "res://Images/Icons/target.png",
	"ICONthink" : "res://Images/Icons/think.png",
	"ICONup" : "res://Images/Icons/up.png",
	"PUBattery1" : "res://Images/PickUps/Battery1.png",
	"PUBattery2" : "res://Images/PickUps/Battery2.png",
	"PUBattery3" : "res://Images/PickUps/Battery3.png",
	"PUBattery4" : "res://Images/PickUps/Battery4.png",
	"PUMB1" : "res://Images/PickUps/MBPickUp1.png",
	"PUMB2" : "res://Images/PickUps/MBPickUp2.png",
	"PUMB3" : "res://Images/PickUps/MBPickUp3.png",
	"PUMB4" : "res://Images/PickUps/MBPickUp4.png",
	"PUBoardSecurity" : "res://Images/PickUps/BoardAccess.png",
	"PUChute" : "res://Images/PickUps/BoardChute.png",
	"PUBoardHealth1" : "res://Images/PickUps/BoardHeart.png",
	"PUBoardHealth2" : "res://Images/PickUps/BoardHeart2.png",
	"PUBoardHealth3" : "res://Images/PickUps/BoardHeart3.png",
	"PUBoardJet" : "res://Images/PickUps/BoardJet.png",
	"PUBoardJump1" : "res://Images/PickUps/BoardJump1.png",
	"PUBoardJump2" : "res://Images/PickUps/BoardJump2.png",
	"PUBoardMagnet" : "res://Images/PickUps/BoardMagnet.png",
	"PUBoardSpeed" : "res://Images/PickUps/BoardSpeed.png",
	"PUBoardTeleport" : "res://Images/PickUps/BoardTeleport.png",
	"PUBoardWallRide" : "res://Images/PickUps/BoardWallRide.png",
	"PUBoardZap1" : "res://Images/PickUps/BoardZapper.png",
	"PUBoardZap2" : "res://Images/PickUps/BoardZapp2.png",
	"PUBoardZap3" : "res://Images/PickUps/BoardZapp3.png",
	"PUBoardSecurityTop" : "res://Images/PickUps/BMDAccess.png",
	"PUChuteTop" : "res://Images/PickUps/BMDAChute.png",
	"PUBoardHealth1Top" : "res://Images/PickUps/BMDAHearth1.png",
	"PUBoardHealth2Top" : "res://Images/PickUps/BMDAHearth2.png",
	"PUBoardHealth3Top" : "res://Images/PickUps/BMDAHearth3.png",
	"PUBoardJetTop" : "res://Images/PickUps/BMDAJet.png",
	"PUBoardChute" : "res://Images/PickUps/BoardChute.png",
	"PUBoardJump1Top" : "res://Images/PickUps/BMDAJump.png",
	"PUBoardJump2Top" : "res://Images/PickUps/BMDAJump2.png",
	"PUBoardMagnetTop" : "res://Images/PickUps/BMDAMagnet.png",
	"PUBoardSpeedTop" : "res://Images/PickUps/BMDSpeed.png",
	"PUBoardTeleportTop" : "res://Images/PickUps/BMDATele.png",
	"PUBoardWallRideTop" : "res://Images/PickUps/BMDAWall.png",
	"PUBoardZap1Top" : "res://Images/PickUps/BMDAZap1.png",
	"PUBoardZap2Top" : "res://Images/PickUps/BMDAZap2.png",
	"PUBoardZap3Top" : "res://Images/PickUps/BMDAZap3.png",
	"PUBattery1Top" : "res://Images/PickUps/BMB1.png",
	"PUBattery2Top" : "res://Images/PickUps/BMB2.png",
	"PUBattery3Top" : "res://Images/PickUps/BMB3.png",
	"PUBattery4Top" : "res://Images/PickUps/BMB4.png",
	"PUBoardChuteTop" : "res://Images/PickUps/BMDAChute.png",
	"MainBoard1" : "res://Images/PickUps/MD1.png",
	"MainBoard2" : "res://Images/PickUps/MD2.png",
	"MainBoard3" : "res://Images/PickUps/MD3.png",
	"MainBoard4" : "res://Images/PickUps/MD4.png",
	"bulkHeadDoor" : "res://Images/KeyAndLock/BulkHeadDoor.png",
	"electricDoor" : "res://Images/KeyAndLock/ElectricDoor.png",




}

@onready var loadMapAudio :Dictionary  = {
	"scaryAmbience" : "res://Audio/TitleAmbience.ogg",
	"fissIn" : "res://Audio/StartUpFissInSound.ogg",
	"select": "res://Audio/select.ogg",
	"yesSound" : "res://Audio/yesSound.ogg",
	"noSound" : "res://Audio/noSound.ogg",
	"crash" : "res://Audio/crash.ogg",
	"rbjump" : "res://Audio/rbjump.ogg",
	"click" : "res://Audio/click.ogg",
	"batteryon" : "res://Audio/batteryon.ogg",
	"batteryoff" : "res://Audio/batteryoff.ogg",
}

@onready var loadMapGD :Dictionary  = {
}

@onready var loadMapData :Dictionary  = {
	"allData": "res://Data/Data.res"
}

var totalToLoad : float= 0 
var totalLoaded : float = 0
var pointer : int = 0 
var lengthLoader : float = 1

func _ready() -> void:
	totalToLoad = loadMapScenes.size() + loadMapImages.size() + loadMapAudio.size() + loadMapGD.size() + loadMapData.size()				
	lengthLoader = WIDTH / float(totalToLoad)
	
func nextStage() -> void:
	pointer=0
	match currentloadState:
		LOAD_STATES.SCENES:
			currentloadState = LOAD_STATES.IMAGES
		LOAD_STATES.IMAGES:
			currentloadState = LOAD_STATES.AUDIO
		LOAD_STATES.AUDIO:
			currentloadState = LOAD_STATES.GD
		LOAD_STATES.GD:
			currentloadState = LOAD_STATES.DATA
		LOAD_STATES.DATA:
			currentloadState = LOAD_STATES.FINISHED
		LOAD_STATES.FINISHED:
			currentloadState = LOAD_STATES.DONE
			
func doLoad(loadFromMap : Dictionary, loadToMap :Dictionary):
	if pointer >= loadFromMap.size():
		nextStage()
		return
	var key: String = loadFromMap.keys()[pointer]
	var value:String = loadFromMap.get(key)
	var object  = load(value)
	loadToMap[key] = object
	pointer=pointer+1
	totalLoaded=totalLoaded+1
	
func doFinished():	
	if Globals.mainScene !=null:
		var mainMenu :Node = Globals.sceneMap.get("mainMenu").instantiate()
		Globals.mainScene.add_child(mainMenu)
	nextStage()

func doDone():
	Globals.loadResources()
	queue_free()
	
func _process(delta: float) -> void:
	loadingBar.size.x = lengthLoader * totalLoaded
	match currentloadState:
		LOAD_STATES.SCENES:
			doLoad(loadMapScenes, Globals.sceneMap)
		LOAD_STATES.IMAGES:
			doLoad(loadMapImages, Globals.imageMap)
		LOAD_STATES.AUDIO:
			doLoad(loadMapAudio, Globals.audioMap)
		LOAD_STATES.GD:
			doLoad(loadMapGD, Globals.gdMap)
		LOAD_STATES.DATA:
			doLoad(loadMapData, Globals.dataMap)
		LOAD_STATES.FINISHED:
			doFinished()
		LOAD_STATES.DONE:
			doDone()
	
