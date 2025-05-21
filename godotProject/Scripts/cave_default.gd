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
	if Input.is_action_just_pressed("shoot_arrow"):
		_on_player_shoot_arrow()
		
	if Input.is_action_just_pressed("Interact"):
		_on_player_interact()

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
	
	newCave.roomGoldAmount = 0
	
	# loops through the connecting caves and updates the numbers above the
	# cave entrances in the scene
	var i : int = 0
	for cave in connectingCaves:
		var path : String = str(i) + "/CaveNumber"
		get_node(path).text = str(cave.currentCaveNumber)
		i += 1
	
	if hasPit:
		
		player.can_move = false
		player.falling = true
		
		# to let it update
		await wait(0.01)
		
		$"Falling-1".visible = true
		$"Falling-2".visible = true
		
		player.position.y = -10
		player.position.x = 576
		
		
		await wait(1.0)
		$"Falling-1".visible = false
		
		player.position.y = -50
		player.position.x = 576
		
		await wait(1.0)
		
		# TODO this is set as the first cave in caveList for now
		updateCave(caveList[0])
		
		get_tree().change_scene_to_file("res://Scenes/cps_minigame.tscn")
		
		$"Falling-2".visible = false
	
	if hasBat:
		print("you are in a bat cave")
		var cavePicked = false
		var randomCave : Cave
		while not cavePicked:
			randomCave = caveList[randi_range(0, 29)]
			if randomCave.currentCaveNumber != currentCaveNumber:
				cavePicked = true
		updateCave(randomCave)
		$BatWarning.text = "A bat picked you up and dropped you, -5 gold"
		$BatWarning.visible = true
		player.goldChange(-5)
		
	if hasWumpus:
		get_tree().change_scene_to_file("res://Scenes/wumpus_cave.tscn")
	
	# checking connecting caves for hazards to show -----------------------
	
	checkHazards()
	
	

# if the player exists any of the 3 Area2D this runs
# it makes the text invisible again
func _on_area_exited(area: Area2D) -> void:
	$EnterCave.visible = false
	$ShootCave.visible = false
	$ShootCaveResult.visible = false

# if the player enters area2D of the cave on the left, show its number in the
# enter cave text

# side note: have to have that space at the end to resolve 27 containing 2 and 27
func _on_0_area_entered(area: Area2D) -> void:
	$EnterCave.text = "Press 'E' to enter cave " + str(connectingCaves[0].currentCaveNumber) + " "
	$EnterCave.visible = true
	$ShootCave.text = "Press 'Q' to shoot an arrow into cave " + str(connectingCaves[0].currentCaveNumber) + " "
	$ShootCave.visible = true


# if the player enters area2D of the cave in the middle, show its number in the
# enter cave text

# side note: have to have that space at the end to resolve 27 containing 2 and 27
func _on_1_area_entered(area: Area2D) -> void:
	$EnterCave.text = "Press 'E' to enter cave " + str(connectingCaves[1].currentCaveNumber) + " "
	$EnterCave.visible = true
	$ShootCave.text = "Press 'Q' to shoot an arrow into cave " + str(connectingCaves[1].currentCaveNumber) + " "
	$ShootCave.visible = true

# if the player enters area2D of the cave on the right, show its number in the
# enter cave text

# side note: have to have that space at the end to resolve 27 containing 2 and 27
func _on_2_area_entered(area: Area2D) -> void:
	$EnterCave.text = "Press 'E' to enter cave " + str(connectingCaves[2].currentCaveNumber) + " "
	$EnterCave.visible = true
	$ShootCave.text = "Press 'Q' to shoot an arrow into cave " + str(connectingCaves[2].currentCaveNumber) + " "
	$ShootCave.visible = true


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
				PlayerData.numberTurns = PlayerData.numberTurns + 1
				$EnterCave.visible = false
				$ShootCave.visible = false
				$ShootCaveResult.visible = false
				updateCave(cave)
				new_cave_entered.emit()
				

func _on_player_shoot_arrow() -> void:
	# the cave the player is standing in front of
	var selectedCave:Cave
	
	if $ShootCave.visible == true:	
		# check which cave the player is standing in front of
		
		# iterates through each connecting cave and checks if that number is
		# in the ShootCave text because that is updated when a player enters
		# the area2D
		for cave in connectingCaves:
			if $ShootCave.text.contains(" " + str(cave.currentCaveNumber) + " "):
				# update numbers in scene and attributes on the object
				
				selectedCave = cave
				break
				
		$ShootCave.visible = false
		$EnterCave.visible = false
		$ShootCaveResult.visible = true
		
		if player.arrowCount > 0:
			player.arrowCount -= 1
			print("Shot an arrow, current count = " + player.arrowCount)
		else:
			print("No arrows left")
			$ShootCaveResult.text = "No arrows left to shoot!"
			return
			
		if selectedCave.hasWumpus:
			print("Wumpus hit! Starting minigame...")
			get_tree().change_scene_to_file("res://Scenes/shoot_arrow_game.tscn")
		else:
			$ShootCaveResult.text = "No Wumpus in that cave. Arrow lost."
			print("No Wumpus in that cave. Arrow lost.")


# called by game control once caveList is defined
func loadCave():
	caveList = get_parent().caveList

# checks the surrounding caves for special caves and lets the user know
func checkHazards():
	# if there is a bat nearby, let the user know
	for cave in connectingCaves:
		if cave.hasBat:
			$BatSound.play()
			$BatWarning.text = "You hear bats near you"
			$BatWarning.visible = true
			return
	
	# if there is a pit cave nearby, let the user know
	for cave in connectingCaves:
		if cave.hasPit:
			$PitWarning.text = "You feel a draft"
			$PitWarning.visible = true
			return
	
	# if there is a wumpus cave nearby, let the user know
	for cave in connectingCaves:
		if cave.hasWumpus:
			$PitWarning.text = "I smell a Wumpus"
			$PitWarning.visible = true
			return

func wait(seconds:float):
	await get_tree().create_timer(seconds).timeout
