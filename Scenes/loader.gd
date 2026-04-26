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

}

@onready var loadMapAudio :Dictionary  = {
	"scaryAmbience" : "res://Audio/TitleAmbience.ogg",
	"fissIn" : "res://Audio/StartUpFissInSound.ogg",
	"select": "res://Audio/select.ogg",
	"yesSound" : "res://Audio/yesSound.ogg",
	"noSound" : "res://Audio/noSound.ogg"
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
	
