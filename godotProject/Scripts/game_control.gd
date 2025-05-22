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
	
	for cave in caveList:
		cave.connectingCaves = connectingCavesMaster[i]
		i += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/in_game_menu/in_game_menu.tscn")
