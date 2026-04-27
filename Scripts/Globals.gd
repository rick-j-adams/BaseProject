#Sound Effect by Rescopic Sound from Pixabay - cinematic-designed-sci-fi-whoosh-transition-nexawave-228295
#                                            - cinematic-designed-sci-fi-riser-orbit-228309 *
#											 - sci-fi-elements-ambience-low-230538 *
# Sound Effect by freesound_community from Pixabay - haunted-space-49341
#                                                   - scary-ambience-59002
# Sound Effect by Yhomar Frhiss Cueva Oviedo from Pixabay - alien-sci-fi-pulse-287311.mp3



extends Node

const GRAVITY := 2000.0


const RESOURCE_CLAZZ = preload("res://Scripts/AllResources.gd")
const RESOURCE_FILE_PATH = "res://Data/AllResources.res"
var allResources:AllResources = RESOURCE_CLAZZ.new()

var sparkEffectScene:Sprite2D = null

const prime1:int = 7919
const prime2:int = 6997
const prime3:int = 5869

var editMode : bool = true

var mainScene  : Node = null
var mainCamera : Camera2D = null

var transitionMask : TransistionMask = null
var interfaceAudio : AudioStreamPlayer2D = null

var sceneMap: Dictionary = {}
var imageMap: Dictionary = {}
var audioMap: Dictionary = {}
var gdMap: Dictionary = {}
var dataMap: Dictionary = {}

var randomPointer : int = 0
var randomNumbers :Array = [47 ,22 ,67 ,83 ,82 ,36 ,2 ,89 ,98 ,42 ,70 ,60 ,53 ,92 ,21 ,14 ,54 ,76 ,9 ,11 ,1 ,32 ,55 ,79 ,10 ,4 ,46 ,80 ,72 ,35 ,3 ,44 ,48 ,20 ,99 ,84 ,0 ,86 ,66 ,90 ,28 ,15 ,30 ,25 ,38 ,63 ,61 ,71 ,27 ,51 ,41 ,45 ,64 ,23 ,94 ,33 ,12 ,56 ,31 ,49 ,75 ,52 ,13 ,43 ,57 ,74 ,85 ,34 ,73 ,96 ,39 ,26 ,69 ,7 ,88 ,37 ,62 ,65 ,77 ,91 ,93 ,97 ,16 ,68 ,18 ,87 ,17 ,24 ,81 ,40 ,19 ,78 ,29 ,6 ,58 ,5 ,95 ,50 ,59 ,8 ,8 ,57 ,51 ,14 ,28 ,85 ,64 ,93 ,61 ,90 ,1 ,33 ,76 ,75 ,62 ,7 ,46 ,79 ,78 ,19 ,65 ,88 ,41 ,36 ,54 ,58 ,77 ,23 ,72 ,12 ,26 ,71 ,84 ,3 ,9 ,63 ,42 ,89 ,5 ,16 ,48 ,32 ,39 ,15 ,94 ,87 ,6 ,60 ,13 ,66 ,70 ,56 ,18 ,99 ,83 ,30 ,47 ,35 ,69 ,0 ,91 ,52 ,38 ,81 ,74 ,24 ,25 ,55 ,49 ,22 ,97 ,21 ,27 ,50 ,96 ,31 ,43 ,44 ,67 ,98 ,37 ,45 ,53 ,82 ,17 ,10 ,59 ,29 ,11 ,92 ,80 ,68 ,95 ,40 ,34 ,2 ,73 ,4 ,86 ,20 ,42 ,25 ,89 ,93 ,23 ,47 ,15 ,30 ,84 ,48 ,27 ,10 ,56 ,24 ,98 ,19 ,12 ,67 ,43 ,7 ,92 ,35 ,69 ,83 ,4 ,32 ,20 ,70 ,91 ,17 ,45 ,51 ,13 ,75 ,37 ,34 ,11 ,33 ,76 ,2 ,28 ,18 ,79 ,36 ,53 ,66 ,71 ,61 ,60 ,38 ,57 ,46 ,59 ,44 ,63 ,49 ,62 ,6 ,65 ,40 ,8 ,1 ,82 ,74 ,88 ,87 ,0 ,26 ,14 ,50 ,22 ,9 ,78 ,96 ,85 ,80 ,94 ,39 ,97 ,41 ,55 ,86 ,3 ,29 ,5 ,64 ,52 ,31 ,81 ,73 ,58 ,72 ,77 ,90 ,16 ,21 ,99 ,68 ,54 ,95 ,81 ,86 ,24 ,90 ,5 ,64 ,17 ,3 ,8 ,29 ,60 ,77 ,14 ,16 ,2 ,82 ,43 ,80 ,11 ,28 ,65 ,36 ,34 ,25 ,94 ,79 ,53 ,20 ,85 ,46 ,9 ,40 ,57 ,4 ,51 ,59 ,70 ,96 ,62 ,55 ,35 ,27 ,56 ,50 ,6 ,91 ,87 ,7 ,66 ,19 ,88 ,38 ,30 ,33 ,67 ,76 ,47 ,93 ,71 ,41 ,73 ,0 ,10 ,45 ,74 ,23 ,15 ,95 ,26 ,61 ,18 ,1 ,78 ,98 ,52 ,83 ,75 ,32 ,48 ,21 ,54 ,63 ,37 ,68 ,69 ,89 ,12 ,72 ,42 ,13 ,92 ,49 ,31 ,99 ,39 ,84 ,22 ,58 ,97 ,44 ,45 ,52 ,27 ,20 ,2 ,65 ,38 ,54 ,35 ,70 ,9 ,14 ,71 ,68 ,76 ,30 ,25 ,18 ,55 ,66 ,72 ,64 ,19 ,26 ,11 ,78 ,61 ,91 ,84 ,43 ,50 ,73 ,0 ,97 ,44 ,40 ,5 ,8 ,31 ,88 ,51 ,15 ,16 ,42 ,62 ,95 ,63 ,24 ,89 ,22 ,3 ,49 ,48 ,17 ,57 ,1 ,7 ,56 ,86 ,28 ,39 ,21 ,98 ,83 ,67 ,41 ,96 ,36 ,93 ,4 ,74 ,13 ,69 ,99 ,10 ,32 ,77 ,33 ,37 ,29 ,79 ,53 ,90 ,59 ,60 ,34 ,58 ,80 ,87 ,12 ,85 ,75 ,23 ,94 ,92 ,81 ,82 ,47 ,46 ,6]

var sectionRandomer : int = 11621
var subSectionRandomer : int = 17377

var puffPool : Array = []
var maxPuffPoolSize : int = 32
var puffMachine :PuffMachine = null

var bitPool : Array = []
var maxBitPoolSize : int = 32
#var bitMachine :PuffMachine = null

func get_next_rand() -> int:
	var number:int = randomNumbers[randomPointer]
	randomPointer=randomPointer+1
	if randomPointer>=len(randomNumbers):
		randomPointer=0
	return number
	
func get_rand_between(min_val :float, max_val :float) -> float:
	var diff:float = float(max_val) -float( min_val)
	var next_random:int = get_next_rand()
	var change_by:float = float(next_random)/float(100)
	var nextValue:float  =  float(min_val) + (float(diff) * change_by) 
	return nextValue

func get_random_eight() -> int:
	var number:int = get_next_rand()
	return number%8

func get_random_four() -> int:
	var number:int = get_next_rand()
	return number%4
	
func get_random_five() -> int:
	var number:int = get_next_rand()
	return number%5	

func setUpPuffPool() -> void:
	for i in range(maxPuffPoolSize):
		var puff:Node = sceneMap.get("puffEffect").instantiate()
		puffPool.append(puff)
		if mainScene != null:
			mainScene.add_child(puff)
		
func createPuff(position:Vector2) -> void:
	if puffPool.size() == 0:
		setUpPuffPool()
	for puff in puffPool:
		if not puff.visible:
			puff.setAndRelease(position)
			return

func setUpBitPool() -> void:
	for i in range(maxBitPoolSize):
		var bit:Node = sceneMap.get("bit").instantiate()
		bitPool.append(bit)
		if mainScene != null:
			mainScene.add_child(bit)

func createBit(position:Vector2) -> void:
	if bitPool.size() == 0:
		setUpBitPool()
	for bit in bitPool:
		if not bit.isOn:
			bit.moveBit(position)
			return

func moveSparkEffect(position:Vector2, rotation:float, flipX:bool, animationName:String):
	if sparkEffectScene == null:
		sparkEffectScene = sceneMap.get("sparkEffect").instantiate()
		if sparkEffectScene != null and mainScene != null:
			mainScene.add_child(sparkEffectScene)

	if sparkEffectScene != null:
		var sparkAnimationPlayer :AnimationPlayer = sparkEffectScene.get_node("AnimationPlayer")
		sparkEffectScene.global_position = position
		sparkEffectScene.rotation = rotation
		sparkEffectScene.flip_h = flipX
		sparkAnimationPlayer.play(animationName)

func movePuffMachine(setPosition:Vector2, setCooldown: float, setDuration: float):
	if puffMachine == null:
		puffMachine = sceneMap.get("puffMachine").instantiate()
		if puffMachine != null and mainScene != null:
			mainScene.add_child(puffMachine)

	if puffMachine != null:
		if not puffMachine.isOn:
			puffMachine.createPuffMMachine(setPosition, setCooldown, setDuration)



func transitionTo(newSceneName:String):
	if transitionMask !=null:
		transitionMask.playTransistion()
	if mainScene !=null :
		var newSceneNode:PackedScene = sceneMap.get(newSceneName)
		if newSceneNode!=null:
			for child in mainScene.get_children():
				child.queue_free()
			mainScene.add_child(newSceneNode.instantiate())
				
	
func addToMainScene(newSceneName:String) -> Node:
	if mainScene !=null :
		var newSceneNode:PackedScene = sceneMap.get(newSceneName)
		if newSceneNode!=null:
			var newNode := newSceneNode.instantiate()
			mainScene.add_child(newNode)
			return newNode
	return null
			

func playInterfaceAudio(localPostion: Vector2, audioName: String) -> void:
	if interfaceAudio !=null: 
		interfaceAudio.global_position = localPostion
		var audio = audioMap.get(audioName)
		if audioName != null:
			interfaceAudio.stream =  audio
			interfaceAudio.play()
		

func saveResources() -> void:
	var result = ResourceSaver.save(allResources, RESOURCE_FILE_PATH)
	print("save result = "+str(result))

func loadResources() -> void:
	if ResourceLoader.exists(RESOURCE_FILE_PATH):
		allResources = ResourceLoader.load(RESOURCE_FILE_PATH)
		if allResources is AllResources:
			print("loaded allShips")
			print(allResources.allAttributes.size())
		else:
			print("new ")
			allResources=AllResources.new()



	
