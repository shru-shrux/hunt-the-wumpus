extends Node2D
class_name Cave

#to do: make hazards for bottomless pit and wumpus. Figure out what will
# happen when a player enters a hazard cave (all three). Coordinate with
# Emily for in game menu (riddles, etc). 

var player : Node2D
var wumpus : Sprite2D
var trivia_popup : Control

# empty variable that is set later from game control
var caveList : Array[Cave] = []
var wumpusCave: Cave
var pitList: Array[Cave]
var batList: Array[Cave]
var playerLocation: int

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
	wumpus = get_parent().get_node("Wumpus")
	trivia_popup = get_parent().get_node("Trivia") as TriviaPopup

	trivia_popup.visible = false
	# connect the two signals with the 2-arg overload
	trivia_popup.connect("trivia_won",  Callable(self, "_on_trivia_won"))
	trivia_popup.connect("trivia_lost", Callable(self, "_on_trivia_lost"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot_arrow"):
		_on_player_shoot_arrow()
		
	if Input.is_action_just_pressed("Interact"):
		_on_player_interact()

# newCave - the cave the player is being sent to
# Sets up the next cave that the player wants to go to.
# - Checks if there is a hazard, and updates hazard warnings
func updateCave(newCave:Cave):
	
	# play the animation and freeze the player, also make sure the pause button
	# isn't available
	$"../OptionsButton".disabled = true
	player.can_move = false
	$"../AnimationPlayer".play("cave_transition")
	await wait(0.5)
	player.can_move = true
	$"../OptionsButton".disabled = false
	
	PlayerData.cavesVisited += 1
	
	print("wumpus----------------")
	print(wumpusCave.currentCaveNumber)
	
	# make warnings not visible in new cave
	$Warnings/PitBackground.visible = false
	$Warnings/BatBackground.visible = false
	$Warnings/WumpusBackground.visible = false
	$BatSound.stop()
	
	# updating attributes for the new cave
	roomGoldAmount = newCave.roomGoldAmount
	connectingCaves = newCave.connectingCaves
	bestOption = newCave.bestOption
	currentCaveNumber = newCave.currentCaveNumber
	hasBat = newCave.hasBat
	hasWumpus = newCave.hasWumpus
	hasPit = newCave.hasPit
	PlayerData.currentRoomNumber = currentCaveNumber
	$CaveNumber.text = str(currentCaveNumber)
	
	print("\nNew Room entered \n --------------------------------")
	print("This room has " + str(roomGoldAmount) + " gold")
	player.goldChange(roomGoldAmount)
	
	# player collision is enabled once game is ready
	player.get_node("CollisionShape2D").disabled = false
	
	# once entered the room now has no more gold
	newCave.roomGoldAmount = 0
	
	# set player position to spawn point
	player.position.x = 119
	
	# loops through the connecting caves and updates the numbers above the
	# cave entrances in the scene
	var i : int = 0
	for cave in connectingCaves:
		var path : String = str(i) + "/CaveNumber"
		get_node(path).text = str(cave.currentCaveNumber)
		i += 1
	
	# CHECK IF THIS IS A HAZARD CAVE -----------------------------------------
	
	# if the player enters a pit cave play a quick falling animation and
	# activate minigame
	if hasPit:
		
		player.can_move = false
		player.falling = true
		
		# lets a couple frames pass so position can be set after can_move is
		# set to false
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
		
		
		$"Falling-2".visible = false
		$CpsMinigame.visible = true
		$"../Riddle".shownOnUpdate = false
	
	# if the cave is a bat cave, pick up the player and drop at a random cave
	# and the player loses 5 gold
	if hasBat:
		$Bat.show()
		await wait(2.0)
		if PlayerData.hasAntiBatEffect:
			$Warnings/BatBackground/BatWarning.text = "Your Anti-Bat potion has worked! The bats have run away to a new cave."
			PlayerData.hasAntiBatEffect = false
		else: 
			print("you are in a bat cave")
			var cavePicked = false
			var randomCave : Cave
			while not cavePicked:
				randomCave = caveList[randi_range(0, 29)]
				if randomCave.currentCaveNumber != currentCaveNumber:
					cavePicked = true
			updateCave(randomCave)
			$Bat.hide()
			$Warnings/BatBackground/BatWarning.text = "A bat picked you up and dropped you"
			player.goldChange(-5)
			
		$Warnings/BatBackground.visible = true
		# TODO make sure bats run away to new cave
	
	# make wumpus visible
	if hasWumpus:
		wumpus.visible   = true
		$"../Riddle".visible = false
		player.can_move  = false
		player.visible   = false

		$Info.text = "The Wumpus has awoken..."
		await get_tree().create_timer(1.5).timeout
		$Info.text = "You must fight to stay alive..."
		await get_tree().create_timer(2.5).timeout
		$Info.text = "Press SPACE to start the trivia..."

		# wait for SPACE (ui_accept) once
		await wait_for_space()
		trivia_popup.start_trivia(5, 3)


		
		
	# generate bfs and riddle
	var start_idx = currentCaveNumber - 1
	var goal_idx = wumpusCave.currentCaveNumber - 1
	var path: Array = bfs_shortest_path(start_idx, goal_idx)
	if path.size() >= 2:
		bestOption = path[1]  # cave number (1-based) of the next step
	else:
		bestOption = currentCaveNumber

	# Only show riddle if NOT a Wumpus cave
	if not hasWumpus:
		if $"../Riddle".shownOnUpdate:
			$"../Riddle".visible = true
		$"../Riddle"._generate_riddle(bestOption)


	# checking connecting caves for hazards to show -----------------------
	checkHazards()

# helper function for wumpus cave
func wait_for_space():
	while not Input.is_action_just_pressed("ui_accept"):
		await get_tree().process_frame

# called when the player wins the trivia
func _on_trivia_won() -> void:
	$Info.text = "You outsmarted the Wumpus!"
	await get_tree().create_timer(1.5).timeout
	wumpus.visible = false
	player.can_move = true
	player.visible = true

	# Now allow the riddle to show
	if $"../Riddle".shownOnUpdate:
		$"../Riddle".visible = true
	$"../Riddle"._generate_riddle(bestOption)
	
	WumpusData.health = WumpusData.health - 5
	# game_control checks in process if wumpus dead
	
	wumpus.visible = false
	
	# change the wumpusCave to two random caves away from it 
	var picked = false
	wumpusCave.hasWumpus = false
	
	print("wumpus now: " + str(wumpusCave.currentCaveNumber))
	
	# change the wumpus 2 caves away randomly away from what is was
	# before. Makes sure that it doesn't go to a cave and then back.
	while not picked:
		var checkCave = wumpusCave.connectingCaves[randi() % 3]
		checkCave = wumpusCave.connectingCaves[(randi() % 3)]
		if wumpusCave != checkCave:
			wumpusCave = checkCave
			picked = true
	
	# set the new wumpus cave to have a wumpus
	wumpusCave.hasWumpus = true
	print("wumpus now: " + str(wumpusCave.currentCaveNumber))
	
	# update to current cave to reload the cave
	updateCave(caveList[currentCaveNumber-1])


# called when the player loses the trivia
func _on_trivia_lost() -> void:
	$Info.text = "The Wumpus feasts… Game Over."
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://Scenes/end_scene.tscn")
	# your lose logic here (reset, reduce life, etc.)

# if the player exists any of the 3 Area2D this runs
# it makes the text invisible again
func _on_area_exited(area: Area2D) -> void:
	
	$"0/HighlightedCave".visible = false
	$"1/HighlightedCave".visible = false
	$"2/HighlightedCave".visible = false
	
	$EnterCave.visible = false
	$ShootCave.visible = false
	$ShootCaveResult.visible = false

# if the player enters area2D of the cave on the left, show its number in the
# enter cave text

# side note: have to have that space at the end to resolve 27 containing 2 and 27
func _on_0_area_entered(area: Area2D) -> void:
	$"0/HighlightedCave".visible = true
	$EnterCave.text = "Press 'E' to enter cave " + str(connectingCaves[0].currentCaveNumber) + " "
	$EnterCave.visible = true
	$ShootCave.text = "Press 'Q' to shoot an arrow into cave " + str(connectingCaves[0].currentCaveNumber) + " "
	$ShootCave.visible = true


# if the player enters area2D of the cave in the middle, show its number in the
# enter cave text

# side note: have to have that space at the end to resolve 27 containing 2 and 27
func _on_1_area_entered(area: Area2D) -> void:
	$"1/HighlightedCave".visible = true
	$EnterCave.text = "Press 'E' to enter cave " + str(connectingCaves[1].currentCaveNumber) + " "
	$EnterCave.visible = true
	$ShootCave.text = "Press 'Q' to shoot an arrow into cave " + str(connectingCaves[1].currentCaveNumber) + " "
	$ShootCave.visible = true

# if the player enters area2D of the cave on the right, show its number in the
# enter cave text

# side note: have to have that space at the end to resolve 27 containing 2 and 27
func _on_2_area_entered(area: Area2D) -> void:
	$"2/HighlightedCave".visible = true
	$EnterCave.text = "Press 'E' to enter cave " + str(connectingCaves[2].currentCaveNumber) + " "
	$EnterCave.visible = true
	$ShootCave.text = "Press 'Q' to shoot an arrow into cave " + str(connectingCaves[2].currentCaveNumber) + " "
	$ShootCave.visible = true

# when the player presses 'E' for interact, moves player to cave they are
# standing in front of. If the player is not standing in front of a cave
# nothing happens
func _on_player_interact() -> void:
	
	# the cave the player is standing in front of
	var selectedCave:Cave
	
	# if the player is standing in front of a cave
	if $EnterCave.visible == true:	
		
		# check which cave the player is standing in front of
		
		# iterates through each connecting cave and checks if that number is
		# in the EnterCave text because that is updated when a player enters
		# the area2D
		for cave in connectingCaves:
			if $EnterCave.text.contains(" " + str(cave.currentCaveNumber) + " "):
				# update numbers in scene and attributes on the object
				$EnterCave.visible = false
				$ShootCave.visible = false
				$ShootCaveResult.visible = false
				updateCave(cave)

# when the player presses 'Q' for shoot arrow in front of a cave. If the player
# shoots into a wumpus cave, activate the shoot the wumpus minigame.
func _on_player_shoot_arrow() -> void:
	# the cave the player is standing in front of
	var selectedCave:Cave
	$"../Riddle".visible = false
	
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
			player.arrowChange(-1)
			print("Shot an arrow, current count = " + str(player.arrowCount))
		else:
			print("No arrows left")
			$ShootCaveResult.text = "No arrows left to shoot!"
			return
			
		if selectedCave.hasWumpus:
			print("Wumpus hit! Starting minigame...")
			#get_tree().change_scene_to_file("res://Scenes/shoot_arrow_game.tscn")
			
			$ShootArrowGame.visible = true
			# the wumpus runs two caves away if damaged but not dead
			
			# stops the player and resets the position
			player.can_move = false
			player.visible = false
			#player.position.x = 135
			
			# change the wumpusCave to two random caves away from it 
			var picked = false
			wumpusCave.hasWumpus = false
			
			print("wumpus now: " + str(wumpusCave.currentCaveNumber))
			
			# change the wumpus 2 caves away randomly away from what is was
			# before. Makes sure that it doesn't go to a cave and then back.
			while not picked:
				var checkCave = wumpusCave.connectingCaves[randi() % 3]
				checkCave = wumpusCave.connectingCaves[(randi() % 3)]
				if wumpusCave != checkCave:
					wumpusCave = checkCave
					picked = true
			
			# set the new wumpus cave to have a wumpus
			wumpusCave.hasWumpus = true
			print("wumpus now: " + str(wumpusCave.currentCaveNumber))
			$Warnings/WumpusBackground.visible = false
			# update to current cave to reload the cave
			updateCave(caveList[currentCaveNumber-1])
			
		else:
			$ShootCaveResult.text = "No Wumpus in that cave. Arrow lost."
			print("No Wumpus in that cave. Arrow lost.")
			# the wumpus runs to a connecting cave
			wumpusCave.hasWumpus = false
			wumpusCave = wumpusCave.connectingCaves[randi() % 3]
			wumpusCave.hasWumpus = true
			$Warnings/WumpusBackground.visible = false
			print("wumpus now: " + str(wumpusCave.currentCaveNumber))
			$"../Riddle".visible = true

# after the arrow game is done reset the cave and hide the minigame
func _on_shoot_arrow_game_arrow_game_done() -> void:
	$ShootArrowGame.visible = false
	player.can_move = true
	player.visible = true
	updateCave(caveList[currentCaveNumber-1])

# called by game control once caveList is defined, gets refrences for key
# variables
func loadCave():
	caveList = get_parent().caveList
	wumpusCave = get_parent().wumpusCave
	batList = get_parent().batList
	pitList = get_parent().pitList
	playerLocation = get_parent().playerLocation

# checks the surrounding caves for special caves and lets the user know
func checkHazards():
	# if there is a bat nearby, let the user know
	for cave in connectingCaves:
		if cave.hasBat:
			$BatSound.play()
			$Warnings/BatBackground/BatWarning.text = "You hear bats near you"
			$Warnings/BatBackground.visible = true
	
	# if there is a pit cave nearby, let the user know
	for cave in connectingCaves:
		if cave.hasPit:
			$Warnings/PitBackground/PitWarning.text = "You feel a draft"
			$Warnings/PitBackground.visible = true
	
	# if there is a wumpus cave nearby, let the user know
	for cave in connectingCaves:
		if cave.hasWumpus:
			$Warnings/WumpusBackground/WumpusWarning.text = "I smell a Wumpus"
			$Warnings/WumpusBackground.visible = true

# start_index - the starting point of the search
# goal_index - the ending point of the search
# finds the shortest path to the end point from the start point and returns
# the path
func bfs_shortest_path(start_index: int, goal_index: int) -> Array:
	var visited = []        # stores the nodes we've already dequeued
	var fringe = []         # queue: stores the nodes we still need to explore
	var parent = {}         # for each discovered node, who we came from

	# sanity check
	if start_index < 1 or start_index > caveList.size():
		print("Start not found")
		return []

	# BFS uses indices 0–29, but cave numbers are 1–30
	var start = start_index
	var goal = goal_index

	# initialize the queue
	fringe.append(start)

	# BFS loop
	while fringe.size() > 0:
		var current = fringe.pop_front()
		visited.append(current)

		# goal test
		if current == goal:
			# reconstruct path by walking parents backwards
			var path = []
			var step = goal
			while step != start:
				path.insert(0, step + 1)  # convert index back to cave number
				step = parent.get(step, -1)
				if step == -1:
					# something went wrong
					return []
			path.insert(0, start + 1)
			return path

		# enqueue all unvisited neighbors
		for neighbor_node in caveList[current].connectingCaves:
			var neighbor = caveList.find(neighbor_node)
			if neighbor == -1:
				continue
			if neighbor in visited or neighbor in fringe:
				continue

			parent[neighbor] = current
			fringe.append(neighbor)

	# if we exhaust the queue without finding the goal
	print("Doesn't Exist")
	return []

func _on_cps_minigame_cps_minigame_over() -> void:
	$"../Riddle".shownOnUpdate = true
	await wait(2.0)
	updateCave(caveList[playerLocation])

# helper function for animations
func wait(seconds:float):
	await get_tree().create_timer(seconds).timeout
