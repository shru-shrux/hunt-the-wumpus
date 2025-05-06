extends Node2D

# 2D array of the connecting caves for each cave
var connectingCavesMaster = []

# array of all the caves going from 1-30
var caveList: Array[Cave] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# creates the cave objects
	create_caves()
	# assings the connecting cave array to each
	populate_connecting_caves()
	# gives each cave gold
	distribute_gold(100)
	# sets the first cave
	initialize_cave(caveList[0])
	
# creates 30 cave objects and gives them numbers 1-30, ordered ascending
func create_caves():
	for i in range(30):
		var cave = Cave.new()
		cave.currentCaveNumber = i+1
		caveList.append(cave)

# randomly picks 2 caves to be the bat caves and two to be pit caves
func assign_special_caves():
	var available_caves = caveList
	available_caves.shuffle()
	
	# assigning bat
	for i in range(2):
		var caveNumber = available_caves[i].currentCaveNumber
		caveList[caveNumber-1].hasBat = true
	
	# assigning pit
	for i in range(2, 4):
		var caveNumber = available_caves[i].currentCaveNumber
		caveList[caveNumber-1].hasPit = true

# give each cave anywhere between 0 and 10 gold up to 100 gold
func distribute_gold(total_gold: int):
	# counter that keeps track of total gold given
	var givenGold : int
	randomize()
	
	# shuffled list of all caves
	var available_caves = caveList
	available_caves.shuffle()
	
	# goes through all 30 caves
	for i in range(30):
		# finding the cave that is in the shuffled list in the actual list
		var caveNumber = available_caves[i].currentCaveNumber
		var cave = caveList[caveNumber-1]
		
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
		
	print(givenGold)

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
