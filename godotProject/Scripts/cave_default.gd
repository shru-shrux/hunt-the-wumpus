extends Node2D
class_name Cave

#to do: make hazards for bottomless pit and wumpus. Figure out what will
# happen when a player enters a hazard cave (all three). Coordinate with
# Emily for in game menu (riddles, etc). 

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
		
	# if game control sets this to bat cave start minigame
	if hasBat:
		pass
	
	# if game control sets this to wumpus cave start minigame
	if hasWumpus:
		pass
	
	# if game control sets this to pit cave start minigame
	if hasPit:
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# currentCave - the cave the player is in currently
# destination - the cave the player is trying to go to
func changeCaves(currentCave:Cave, destination:Cave):
	# if the destination has a connection to currentCave change caves
	if destination in currentCave.connectingCaves:
		updateCave(destination)
	# if the destination DOES NOT have a connection we can't change
	else:
		print("Cave is not accessible from current cave")
		return

# change all of the attributes of the currentCave to our the cave the player
# is changing to
func updateCave(newCave:Cave):
	# updating attributes
	roomGoldAmount = newCave.roomGoldAmount
	connectingCaves = newCave.connectingCaves
	bestOption = newCave.bestOption
	currentCaveNumber = newCave.currentCaveNumber
	hasBat = newCave.hasBat
	hasWumpus = newCave.hasWumpus
	hasPit = newCave.hasPit
	
	# loops through the connecting caves and updates the numbers above the
	# cave entrances in the scene
	var i : int = 0
	for cave in connectingCaves:
		var path : String = str(i) + "/CaveNumber"
		get_node(path).text = str(cave.currentCaveNumber)
		i += 1
	
	
	# checking connecting caves for hazards to show ----
	
	# if there is a bat cave nearby, let the user know
	for cave in connectingCaves:
		if cave.hasBat:
			$BatSound.play()
			return
	
	# if there is a pit cave nearby, let the user know
	for cave in connectingCaves:
		if cave.hasPit:
			# figure out what should happen here -------------------------------
			return
	
	# if there is a wumpus cave nearby, let the user know
	for cave in connectingCaves:
		if cave.hasWumpus:
			# figure out what should happen here -------------------------------
			return
	

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
