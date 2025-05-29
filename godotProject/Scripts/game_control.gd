extends Node2D

@onready var menu = $CanvasLayer/InGameMenu
var paused = false

@export var timer_label : Label
var timer : MyTimer

# 2D array of the connecting caves for each cave
var connectingCavesMaster = []

# array of all the caves going from 1-30
var caveList: Array[Cave] = []

# variables to store which caves are hazards
var batList: Array[Cave] = []
var pitList: Array[Cave] = []
var wumpusCave: Cave

# where the player spawns
var playerSpawn: int

var difficulty: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# hide menu when game starts
	menu.hide()
	# signal for resuming from in game menu
	$CanvasLayer/InGameMenu.connect("resume_pressed", Callable(self, "_on_resume_pressed"))
	
	# timer show/hide
	timer = get_tree().get_first_node_in_group("timer")
	var options = $CanvasLayer/InGameMenu/CanvasLayer2/Options
	options.connect("toggle_time_visibility", Callable(self, "_on_toggle_timer_visibility"))
	
	# set difficulty of game
	difficulty = Global.difficulty
	print(difficulty)
	
	# creates the cave objects
	create_caves()
	# assings the connecting cave array to each
	populate_connecting_caves()
	# gives each cave gold
	distribute_gold(100)
	# choose a random cave to spawn in
	playerSpawn = randi() % 30
	PlayerData.currentRoomNumber = playerSpawn
	# assigns the pit and bat caves
	assign_special_caves()
	# loads the caveList to caveDefault
	$CaveDefault.loadCave()
	# sets the first cave
	$CaveDefault.updateCave(caveList[playerSpawn])
	
	# lets the all values adjust before cave shown to player
	$GameStartBlackScreen.visible = true
	await wait(0.55)
	$GameStartBlackScreen.visible = false
	
	print("bats------------------")
	for cave in batList:
		print(cave.currentCaveNumber)
	
	print("pits------------------")
	for cave in pitList:
		print(cave.currentCaveNumber)
		
	GameData.caveList = caveList
	GameData.pitList = pitList
	GameData.batList = batList

func _on_resume_pressed():
	in_game_menu()

# creates 30 cave objects and gives them numbers 1-30, ordered ascending
func create_caves():
	for i in range(30):
		var cave = Cave.new()
		cave.currentCaveNumber = i+1
		caveList.append(cave)

# randomly picks 2 caves to be the bat caves and two to be pit caves and
# one to be the wumpus cave
func assign_special_caves():
	
	randomize()
	
	# fill array with 0-29
	var numbers = []
	for i in range(30):
		numbers.append(i)
	
	# make sure the player doesn't spawn in a hazard cave
	numbers.erase(playerSpawn)
	
	# shuffle the list to get random first 5
	numbers.shuffle()
	
	# set the 0 & 1 caves to bat, 2 & 3 caves to pit and 5 to wumpus
	# also stores them in variables for easy access later
	caveList[numbers[0]].hasBat = true
	batList.append(caveList[numbers[0]])
	caveList[numbers[1]].hasBat = true
	batList.append(caveList[numbers[1]])
	caveList[numbers[2]].hasPit = true
	pitList.append(caveList[numbers[2]])
	caveList[numbers[4]].hasPit = true
	pitList.append(caveList[numbers[3]])
	caveList[numbers[4]].hasWumpus = true
	wumpusCave = caveList[numbers[4]]
	WumpusData.currentRoomNumber = caveList[numbers[4]]

# give each cave anywhere between 0 and 10 gold up to 100 gold
func distribute_gold(total_gold: int):
	# counter that keeps track of total gold given
	var givenGold : int
	randomize()
	
	var numbers = []
	for i in range(30):
		numbers.append(i)
		numbers.shuffle()
	
	# goes through all 30 caves
	for i in numbers:
		# finding the cave that is in the shuffled list in the actual list
		var cave = caveList[i]
		
		# if all the gold is given stop looping
		if givenGold >= 100:
			break
		# if there is 90 or more gold, then give the next cave the rest
		if givenGold >= 90:
			cave.roomGoldAmount = total_gold - givenGold
			givenGold += total_gold - givenGold
		# add random amount between 0 and 10 gold, and increment counter
		else:
			var gold = randi() % 10 + 1
			cave.roomGoldAmount = gold
			givenGold += gold


# gives each cave an array of its 3 connecting caves to make the map
func populate_connecting_caves():
	
	connectingCavesMaster = [
		[caveList[1], caveList[2], caveList[3]],       # 1
		[caveList[0], caveList[4], caveList[5]],       # 2
		[caveList[0], caveList[6], caveList[7]],       # 3
		[caveList[0], caveList[8], caveList[9]],       # 4
		[caveList[1], caveList[10], caveList[11]],     # 5
		[caveList[1], caveList[12], caveList[13]],     # 6
		[caveList[2], caveList[14], caveList[15]],     # 7
		[caveList[2], caveList[16], caveList[17]],     # 8
		[caveList[3], caveList[18], caveList[19]],     # 9
		[caveList[3], caveList[20], caveList[21]],     # 10
		[caveList[4], caveList[22], caveList[23]],     # 11
		[caveList[4], caveList[24], caveList[25]],     # 12
		[caveList[5], caveList[26], caveList[27]],     # 13
		[caveList[5], caveList[28], caveList[29]],     # 14
		[caveList[6], caveList[22], caveList[24]],     # 15
		[caveList[6], caveList[23], caveList[25]],     # 16
		[caveList[7], caveList[26], caveList[28]],     # 17
		[caveList[7], caveList[27], caveList[29]],     # 18
		[caveList[8], caveList[22], caveList[26]],     # 19
		[caveList[8], caveList[23], caveList[27]],     # 20
		[caveList[9], caveList[24], caveList[28]],     # 21
		[caveList[9], caveList[25], caveList[29]],     # 22
		[caveList[10], caveList[14], caveList[18]],    # 23
		[caveList[10], caveList[15], caveList[19]],    # 24
		[caveList[11], caveList[14], caveList[20]],    # 25
		[caveList[11], caveList[15], caveList[21]],    # 26
		[caveList[12], caveList[16], caveList[18]],    # 27
		[caveList[12], caveList[17], caveList[19]],    # 28
		[caveList[13], caveList[16], caveList[20]],    # 29
		[caveList[13], caveList[17], caveList[21]],    # 30
	]
	
	var i = 0
	
	# give each cave in caveList its corresponding connectingCaves list
	for cave in caveList:
		cave.connectingCaves = connectingCavesMaster[i]
		i += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_timer_label()
	
	if WumpusData.health <= 0:
		# maybe do a cut scene to wumpus dying
		PlayerData.wumpusKilled = true
		get_tree().change_scene_to_file("res://Scenes/end_scene.tscn")
	
func update_timer_label():
	timer_label.text = timer.time_to_string()

func _on_options_button_pressed() -> void:
	print(menu)
	print(menu.visible)
	in_game_menu()

func in_game_menu():
	if paused:
		menu.hide()
		Engine.time_scale = 1
	else:
		menu.show()
		Engine.time_scale = 0
	
	paused = !paused

# when timer button toggled set the timer visibility to the opposite of what it
# was
func _on_toggle_timer_visibility(visible: bool) -> void:
	timer_label.visible = !timer_label.visible

# when riddle button toggled set the riddle visibility on updateCave to the 
# opposite of what it was
#func _on_show_riddle_button_toggled(toggled_on: bool) -> void:
	#$Riddle.shownOnUpdate = !$Riddle.shownOnUpdate

func _on_show_riddle_button_pressed() -> void:
	$Riddle.visible = !$Riddle.visible

# helper function for animations
func wait(seconds:float):
	await get_tree().create_timer(seconds).timeout
