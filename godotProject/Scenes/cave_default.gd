extends Node2D
class_name Cave

#to do: make hazards for bottomless pit and wumpus. Figure out what will
# happen when a player enters a hazard cave (all three). Coordinate with
# Emily for in game menu (riddles, etc). 

# the amount of gold the player gets for entering the cave
var roomGoldAmount = 0
# the caves the player can go into from this one
var connectingCaves: Array[Cave] = []
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
		get_node(path).text = currentCaveNumber
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
	

# if the player enters any of the 3 Area2D this runs
# it updates the text to the right number cave and shows it
func _on_area_entered(area: Area2D) -> void:
	print("entered")
	$EnterCave.text = "Press 'E' to enter cave " + connectingCaves[int(area.name)].currentCaveNumber
	$EnterCave.visible = true

# if the player exists any of the 3 Area2D this runs
# it makes the text invisible again
func _on_area_exited(area: Area2D) -> void:
	$EnterCave.visible = false
