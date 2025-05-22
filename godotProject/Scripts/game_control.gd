extends Node2D

# 2D array of the connecting caves for each cave
var connectingCavesMaster = []

# array of all the caves going from 1-30
var caveList: Array[Cave] = []

var batList: Array[Cave] = []
var pitList: Array[Cave] = []
var wumpusCave: Cave

var playerLocation: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# creates the cave objects
	create_caves()
	# assings the connecting cave array to each
	populate_connecting_caves()
	# gives each cave gold
	distribute_gold(100)
	# assigns the pit and bat caves
	assign_special_caves()
	# loads the caveList to caveDefault
	$CaveDefault.loadCave()
	# sets the first cave
	$CaveDefault.updateCave(caveList[0])
	
	
	playerLocation = randi() % 29 + 1
	
	print("bats------------------")
	for cave in batList:
		print(cave.currentCaveNumber)
	
	print("pits------------------")
	for cave in pitList:
		print(cave.currentCaveNumber)

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
	caveList[numbers[3]].hasPit = true
	pitList.append(caveList[numbers[3]])
	caveList[numbers[4]].hasWumpus = true
	wumpusCave = caveList[numbers[4]]

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
		

# for this first cave sets all the first amounts before the system takes control
func initialize_cave(pickedCave:Cave):
	# updating attributes
	$CaveDefault.roomGoldAmount = pickedCave.roomGoldAmount
	$CaveDefault.connectingCaves = pickedCave.connectingCaves
	$CaveDefault.bestOption = pickedCave.bestOption
	$CaveDefault.currentCaveNumber = pickedCave.currentCaveNumber
	$CaveDefault.hasBat = pickedCave.hasBat
	$CaveDefault.hasWumpus = pickedCave.hasWumpus
	$CaveDefault.hasPit = pickedCave.hasPit
	

# gives each cave an array of its 3 connecting caves to make the map
func populate_connecting_caves():
	
	connectingCavesMaster = [
		[caveList[1], caveList[5], caveList[6]],       # 1
		[caveList[0], caveList[2], caveList[8]],       # 2
		[caveList[1], caveList[3], caveList[27]],      # 3
		[caveList[2], caveList[8], caveList[9]],       # 4
		[caveList[5], caveList[10], caveList[28]],     # 5
		[caveList[0], caveList[4], caveList[11]],      # 6
		[caveList[0], caveList[7], caveList[12]],      # 7
		[caveList[6], caveList[13], caveList[14]],     # 8
		[caveList[1], caveList[3], caveList[14]],      # 9
		[caveList[3], caveList[10], caveList[15]],     # 10
		[caveList[4], caveList[9], caveList[16]],      # 11
		[caveList[5], caveList[12], caveList[17]],     # 12
		[caveList[6], caveList[11], caveList[18]],     # 13
		[caveList[7], caveList[19], caveList[20]],     # 14
		[caveList[7], caveList[8], caveList[20]],      # 15
		[caveList[9], caveList[16], caveList[21]],     # 16
		[caveList[10], caveList[15], caveList[17]],    # 17
		[caveList[11], caveList[16], caveList[22]],    # 18
		[caveList[12], caveList[23], caveList[24]],    # 19
		[caveList[13], caveList[24], caveList[25]],    # 20
		[caveList[13], caveList[14], caveList[26]],    # 21
		[caveList[15], caveList[22], caveList[27]],    # 22
		[caveList[17], caveList[21], caveList[28]],    # 23
		[caveList[18], caveList[29], caveList[24]],    # 24
		[caveList[18], caveList[19], caveList[25]],    # 25
		[caveList[19], caveList[24], caveList[26]],    # 26
		[caveList[20], caveList[25], caveList[27]],    # 27
		[caveList[2], caveList[21], caveList[26]],     # 28
		[caveList[4], caveList[22], caveList[29]],     # 29
		[caveList[23], caveList[27], caveList[29]]     # 30
	]
	
	var i = 0
	
	for cave in caveList:
		cave.connectingCaves = connectingCavesMaster[i]
		i += 1

# BFS loop


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/in_game_menu/in_game_menu.tscn")
