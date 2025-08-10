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
}

@onready var loadMapImages :Dictionary  = {
	"yes" : "res://Images/System/UIConfirmButtonUp.png",
	"no" : "res://Images/System/UINegateButtonUp.png",
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
	
