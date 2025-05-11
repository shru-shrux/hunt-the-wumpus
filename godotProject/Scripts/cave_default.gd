extends Node2D
class_name Cave
signal new_cave_entered

#to do: make hazards for bottomless pit and wumpus. Figure out what will
# happen when a player enters a hazard cave (all three). Coordinate with
# Emily for in game menu (riddles, etc). 

var player : Node2D

# empty variable that is set later from game control
var caveList : Array[Cave] = []

# the amount of gold the player gets for entering the cave
var roomGoldAmount = 0
# the caves the player can go into from this one
var connectingCaves: Array = []
# the answer for the riddle and the cave the player 
# wants to go into
var bestOption = 0
# the number of the current cave
var currentCaveNumber = 0

# specialty caves that make it different than default

# will be a bat cave
var hasBat = false
# will be a wumpus cave
var hasWumpus = false
# will have a bottomless pit
var hasPit = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent().get_node("Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# change all of the attributes of the currentCave to our the cave the player
# is changing to
func updateCave(newCave:Cave):
	
	# make warnings not visible in new cave
	$PitWarning.visible = false
	$BatWarning.visible = false
	$BatSound.stop()
	
	# updating attributes
	roomGoldAmount = newCave.roomGoldAmount
	connectingCaves = newCave.connectingCaves
	bestOption = newCave.bestOption
	currentCaveNumber = newCave.currentCaveNumber
	hasBat = newCave.hasBat
	hasWumpus = newCave.hasWumpus
	hasPit = newCave.hasPit
	$CaveNumber.text = str(currentCaveNumber)
	
	print("\nNew Room entered \n --------------------------------")
	print("This room has " + str(roomGoldAmount) + " gold")
	player.goldChange(roomGoldAmount)
	
	# loops through the connecting caves and updates the numbers above the
	# cave entrances in the scene
	var i : int = 0
	for cave in connectingCaves:
		var path : String = str(i) + "/CaveNumber"
		get_node(path).text = str(cave.currentCaveNumber)
		i += 1
	
	if hasPit:
		print("Game over u are done, there is a pit here")
	
	if hasBat:
		print("your are in a bat cave")
		var cavePicked = false
		var randomCave : Cave
		while not cavePicked:
			randomCave = caveList[randi_range(0, 29)]
			if randomCave.hasBat == false and randomCave.hasPit == false and randomCave.hasWumpus == false and randomCave.currentCaveNumber != currentCaveNumber:
				cavePicked = true
		updateCave(randomCave)
		$BatWarning.text = "A bat picked you up and dropped you, -5 gold"
		$BatWarning.visible = true
		player.goldChange(-5)
	
	# checking connecting caves for hazards to show -----------------------
	
	checkHazards()
	
	

# if the player exists any of the 3 Area2D this runs
# it makes the text invisible again
func _on_area_exited(area: Area2D) -> void:
	$EnterCave.visible = false

# if the player enters area2D of the cave on the left, show its number in the
# enter cave text

# side note: have to have that space at the end to resolve 27 containing 2 and 27
func _on_0_area_entered(area: Area2D) -> void:
	$EnterCave.text = "Press 'E' to enter cave " + str(connectingCaves[0].currentCaveNumber) + " "
	$EnterCave.visible = true


# if the player enters area2D of the cave in the middle, show its number in the
# enter cave text

# side note: have to have that space at the end to resolve 27 containing 2 and 27
func _on_1_area_entered(area: Area2D) -> void:
	$EnterCave.text = "Press 'E' to enter cave " + str(connectingCaves[1].currentCaveNumber) + " "
	$EnterCave.visible = true

# if the player enters area2D of the cave on the right, show its number in the
# enter cave text

# side note: have to have that space at the end to resolve 27 containing 2 and 27
func _on_2_area_entered(area: Area2D) -> void:
	$EnterCave.text = "Press 'E' to enter cave " + str(connectingCaves[2].currentCaveNumber) + " "
	$EnterCave.visible = true


func _on_player_interact() -> void:
	
	# the cave the player is standing in front of
	var selectedCave:Cave
	
	if $EnterCave.visible == true:	
		
		# check which cave the player is standing in front of
		
		# iterates through each connecting cave and checks if that number is
		# in the EnterCave text because that is updated when a player enters
		# the area2D
		for cave in connectingCaves:
			if $EnterCave.text.contains(" " + str(cave.currentCaveNumber) + " "):
				# update numbers in scene and attributes on the object
				updateCave(cave)
				new_cave_entered.emit()

# called by game control once caveList is defined
func loadCave():
	caveList = get_parent().caveList

# checks the surrounding caves for special caves and lets the user know
func checkHazards():
	# if there is a bat nearby, let the user know
	for cave in connectingCaves:
		if cave.hasBat:
			$BatSound.play()
			$BatWarning.text = "You hear high pitched squeaks near you"
			$BatWarning.visible = true
			return
	
	# if there is a pit cave nearby, let the user know
	for cave in connectingCaves:
		if cave.hasPit:
			$PitWarning.text = "You hear a rock fall and hit the sides of some hole"
			$PitWarning.visible = true
			return
	
	# if there is a wumpus cave nearby, let the user know
	for cave in connectingCaves:
		if cave.hasWumpus:
			# figure out what should happen here -------------
			return
