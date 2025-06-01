extends Node2D
class_name Cave

var player : Node2D
var wumpus : Sprite2D
var trivia_popup : Control

# empty variable that is set later from game control
var caveList : Array[Cave] = []
var wumpusCave: Cave
var pitList: Array[Cave]
var batList: Array[Cave]
var playerSpawn: int

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

var pickup: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# define scenes
	player = get_parent().get_node("Player")
	wumpus = get_parent().get_node("Wumpus")
	trivia_popup = get_parent().get_node("Trivia") as TriviaPopup
	
	# hide trivia popup to start
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
		
# called by game control once caveList is defined, gets refrences for key
# variables
func loadCave():
	caveList = get_parent().caveList
	wumpusCave = get_parent().wumpusCave
	batList = get_parent().batList
	pitList = get_parent().pitList
	playerSpawn = get_parent().playerSpawn

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
			$Warnings/WumpusBackground/WumpusWarning.text = "You smell a Wumpus"
			$Warnings/WumpusBackground.visible = true

# newCave - the cave the player is being sent to
# Sets up the next cave that the player wants to go to.
# - Checks if there is a hazard, and updates hazard warnings
func updateCave(newCave:Cave):
	
	$OtherWarnings.visible = false
	
	# play the animation and freeze the player, also make sure the pause button
	# isn't available
	$"../OptionsButton".disabled = true
	player.can_move = false
	$"../AnimationPlayer".play("cave_transition")
	await wait(0.5)
	$"../Riddle".get_child(0).get_child(0).text = "Listening to the Caves..."
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
	WumpusData.currentRoomNumber = wumpusCave.currentCaveNumber
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
		$"../Riddle".visible = false
		
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
		$CpsMinigame/FallSound.play()
		await wait(1.0)
		
		
		$"Falling-2".visible = false
		$CpsMinigame.visible = true
		$"../Riddle".shownOnUpdate = false
		
		# if this is also a wumpus cave show it while playing the CPS minigame
		if hasWumpus:
			wumpus.position = Vector2(429,584)
			wumpus.visible = true
	
	# if the cave is a bat cave, pick up the player and drop at a random cave
	# and the player loses 5 gold
	if hasBat:
		pickup = true
		player.can_move = false

		# if it is also a wumpus cave show the wumpus but don't do trivia
		if hasWumpus:
			wumpus.visible = true
		
		$Bat.show()
		await wait(2.0)
		# if the player has the anti bat activate the minigame
		if PlayerData.hasAntiBatEffect:
			$"../Minigame".visible = true
			await $"../Minigame".get_node("Panel/game").game_finished
			$"../Minigame".visible = false
			# if you are not being picked up anymore you won the bat game and
			# will not get moved
			if !pickup:
				$OtherWarnings.text = "Your Anti-Bat potion has worked! The bats have run away to a new cave."
				$OtherWarnings.visible = true
				await wait(3.0)
				$OtherWarnings.visible = false
			
			# if you are being picked up, your anti-bat potion was used but
			# you are still goin to be picked up
			if pickup:
				$OtherWarnings.text = "Your Anti-Bat potion activated but was ineffective."
				$OtherWarnings.visible = true
				await wait(3.0)
				$OtherWarnings.visible = false
			PlayerData.hasAntiBatEffect = false
		
		# if the bat cave has been picked
		var caveBatPicked = false
		# if the player cave has been picked
		var cavePlayerPicked = false
		# the cave the bat will go to
		var randomBatCave : Cave
		# the cave the player will go to
		var randomPlayerCave : Cave
		
		# the bat cave will be different than this one so make this a normal
		# cave again
		hasBat = false
		newCave.hasBat = false
		# choose the cave the bat will go to, can't be another hazard and can't
		# be the current cave
		while not caveBatPicked:
			randomBatCave = caveList[randi_range(0, 29)]
			if randomBatCave.currentCaveNumber != currentCaveNumber:
				if randomBatCave.currentCaveNumber != currentCaveNumber:
					if randomBatCave.currentCaveNumber != pitList[0].currentCaveNumber and randomBatCave.currentCaveNumber != pitList[1].currentCaveNumber:
						if randomBatCave.currentCaveNumber != batList[0].currentCaveNumber and randomBatCave.currentCaveNumber != batList[1].currentCaveNumber:
							caveBatPicked = true
		
		# update that cave to be a bat cave and update batList
		var batIdx = batList.find(newCave)
		batList[batIdx] = randomBatCave
		randomBatCave.hasBat = true
		GameData.batList = batList
		
		# picking the place where the player will go, can't be current and can't
		# be another hazard 
		while not cavePlayerPicked:
			randomPlayerCave = caveList[randi_range(0, 29)]
			if randomPlayerCave.currentCaveNumber != currentCaveNumber:
				if randomPlayerCave.currentCaveNumber != currentCaveNumber:
					if randomPlayerCave.currentCaveNumber != pitList[0].currentCaveNumber and randomPlayerCave.currentCaveNumber != pitList[1].currentCaveNumber:
						if randomPlayerCave.currentCaveNumber != batList[0].currentCaveNumber and randomPlayerCave.currentCaveNumber != batList[1].currentCaveNumber:
							cavePlayerPicked = true
		
		# make the wumpus invisible if it was a wumpus and bat cave
		wumpus.visible = false
		$Bat.hide()
		
		# if the player was picked up by the bat, can avoid through anti-bat
		# and then winning the minigame
		if pickup:
			updateCave(randomPlayerCave)
			$Bat.hide()
			$OtherWarnings.text = "A bat picked you up, dropped you and robbed you."
			$OtherWarnings.visible = true
			await wait(3.0)
			$OtherWarnings.visible = false
			player.goldChange(-5)
		player.can_move = true
		$Warnings/BatBackground.visible = true
		
	
	# make wumpus visible
	if hasWumpus:
		
		# if the cave is another hazard don't activate the trivia for the 
		# wumpus cave
		if hasPit:
			return
		if hasBat:
			return
		
		wumpus.visible   = true
		$"../Riddle".visible = false
		player.can_move  = false
		player.visible   = false

		$Info.visible = true
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
		$"../Riddle"._generate_riddle(bestOption)
		if $"../Riddle".shownOnUpdate:
			$"../Riddle".visible = true
		
	# checking connecting caves for hazards to show -----------------------
	checkHazards()

# helper function for wumpus cave
func wait_for_space():
	while not Input.is_action_just_pressed("ui_accept"):
		if not is_inside_tree():
			return
		await get_tree().process_frame

# called when the player wins the trivia
func _on_trivia_won() -> void:
	$Info.text = "You outsmarted the Wumpus!"
	$Info.visible = true
	await get_tree().create_timer(1.5).timeout
	$Info.visible = false
	
	# becomes normal room/gameplay again
	wumpus.visible = false
	player.can_move = true
	player.visible = true

	# Now allow the riddle to show
	$"../Riddle"._generate_riddle(bestOption)
	if $"../Riddle".shownOnUpdate:
		$"../Riddle".visible = true
	
	# change wumpus health
	WumpusData.health = WumpusData.health - 5
	# game_control checks in process if wumpus dead
	
	# change the wumpusCave to two random caves away from it 
	var picked = false
	wumpusCave.hasWumpus = false
	
	# print new wumpus cave to keep track
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
	
	GameData.wumpusCave = wumpusCave
	WumpusData.currentRoomNumber = wumpusCave.currentCaveNumber
	
	# update to current cave to reload the cave
	updateCave(caveList[currentCaveNumber-1])

# called when the player loses the trivia -> game ends
func _on_trivia_lost() -> void:
	$Info.text = "The Wumpus feasts… Game Over."
	await get_tree().create_timer(1.5).timeout
	PlayerData.howEnded = 1
	PlayerData.timeTaken = get_parent().get_node("Timer").time
	get_tree().change_scene_to_file("res://Scenes/end_scene.tscn")

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
				
				selectedCave = cave
				break
		
		$ShootCave.visible = false
		$EnterCave.visible = false
		$ShootCaveResult.visible = true
		
		# check the player's arrow count either subtract or reject action
		if player.arrowCount > 0:
			player.arrowChange(-1)
			print("Shot an arrow, current count = " + str(player.arrowCount))
		else:
			print("No arrows left")
			$ShootCaveResult.text = "No arrows left to shoot!"
			await wait(1.0)
			$EnterCave.visible = true
			$ShootCave.visible = true
			return
			
		if selectedCave.hasWumpus:
			print("Wumpus hit! Starting minigame...")
			
			$ShootArrowGame.visible = true
			$"../Riddle".visible = false
			# the wumpus runs two caves away if damaged but not dead
			
			# stops the player and hides the player
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
				checkCave = checkCave.connectingCaves[(randi() % 3)]
				if wumpusCave != checkCave:
					wumpusCave = checkCave
					picked = true
			
			# set the new wumpus cave to have a wumpus
			wumpusCave.hasWumpus = true
			print("wumpus now: " + str(wumpusCave.currentCaveNumber))
			GameData.wumpusCave = wumpusCave
			
			# regenerate riddle
			$"../Riddle"._generate_riddle(bestOption)
			
			$Warnings/WumpusBackground.visible = false
			$ShootCaveResult.text = "You damaged the Wumpus!"
			WumpusData.currentRoomNumber = wumpusCave.currentCaveNumber
		else:
			$ShootCaveResult.text = "No Wumpus in that cave. Arrow lost."
			print("No Wumpus in that cave. Arrow lost.")
			# the wumpus runs to a connecting cave
			wumpusCave.hasWumpus = false
			wumpusCave = wumpusCave.connectingCaves[randi() % 3]
			wumpusCave.hasWumpus = true
			$Warnings/WumpusBackground.visible = false
			print("wumpus now: " + str(wumpusCave.currentCaveNumber))
			$"../Riddle"._generate_riddle(bestOption) # regenerate riddle
			$"../Riddle".visible = true
			GameData.wumpusCave = wumpusCave
			WumpusData.currentRoomNumber = wumpusCave.currentCaveNumber
			
		await wait(2.5)
		$ShootCaveResult.visible = false
		$EnterCave.visible = true
		$ShootCave.visible = true
		checkHazards()
		$"../Riddle".visible = true

# after the arrow game is done reset the cave and hide the minigame
func _on_shoot_arrow_game_arrow_game_done() -> void:
	$ShootArrowGame.visible = false
	player.can_move = true
	player.visible = true
	$Warnings/WumpusBackground.visible = false
	#updateCave(caveList[currentCaveNumber-1])

# start_index - the starting point of the search
# goal_index - the ending point of the search
# finds the shortest path to the end point from the start point and returns
# the path
func bfs_shortest_path(start_index: int, goal_index: int) -> Array:
	var visited = []        # stores the nodes we've already dequeued
	var fringe = []         # queue: stores the nodes we still need to explore
	var parent = {}         # for each discovered node, who we came from

	# sanity check
	if start_index < 0 or start_index > caveList.size():
		print("Start not found")
		return []

	# BFS uses indices 0–29, but cave numbers are 1–30
	var start = start_index
	var goal = goal_index

	# initialize the queue
	fringe.append(start)

	# BFS loop
	# while still rooms able to be checked
	while fringe.size() > 0:
		var current = fringe.pop_front() # get room at front of list
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

# when the minigame is done, reset the game
func _on_cps_minigame_cps_minigame_over() -> void:
	$"../Riddle".shownOnUpdate = true
	# if the pit was in the same room as the wumpus reset the wumpus as well
	if hasWumpus:
		wumpus.visible = false
		wumpus.position = Vector2(733,498)
	await wait(2.0)
	updateCave(caveList[playerSpawn])

# Shortcuts to experience game -------------------------------------------------


# when the tester wants to experience the bat cave put them in a cave that is
# next to it and tell which cave to go into
func _on_player_go_to_bat() -> void:
	
	var transferCave : Cave
	var pickedTransferCave = false
	while !pickedTransferCave:
		transferCave = batList[0].connectingCaves[randi_range(0,2)]
		if transferCave.currentCaveNumber != currentCaveNumber:
			if transferCave.currentCaveNumber != pitList[0].currentCaveNumber and transferCave.currentCaveNumber != pitList[1].currentCaveNumber:
				if transferCave.currentCaveNumber != batList[0].currentCaveNumber and transferCave.currentCaveNumber != batList[1].currentCaveNumber:
					if transferCave.currentCaveNumber != wumpusCave.currentCaveNumber:
						pickedTransferCave = true
	
	updateCave(transferCave)
	
	$OtherWarnings.text = (
		"Go into cave " + str(batList[0].currentCaveNumber) + " to test the " + 
		"Bat Cave"
	)	
	$OtherWarnings.visible = true

# when the tester wants to experience the pit cave put them in a cave adjacent
# to it and tell them which cave to enter
func _on_player_go_to_pit() -> void:
	var transferCave : Cave
	var pickedTransferCave = false
	while !pickedTransferCave:
		transferCave = pitList[0].connectingCaves[randi_range(0,2)]
		if transferCave.currentCaveNumber != currentCaveNumber:
			if transferCave.currentCaveNumber != pitList[0].currentCaveNumber and transferCave.currentCaveNumber != pitList[1].currentCaveNumber:
				if transferCave.currentCaveNumber != batList[0].currentCaveNumber and transferCave.currentCaveNumber != batList[1].currentCaveNumber:
					if transferCave.currentCaveNumber != wumpusCave.currentCaveNumber:
						pickedTransferCave = true
	
	updateCave(transferCave)
	
	$OtherWarnings.text = (
		"Go into cave " + str(pitList[0].currentCaveNumber) + " to test the " + 
		"Pit Cave"
	)
	$OtherWarnings.visible = true

# when the tester wants to experience the wumpus cave put them in a cave that is
# next to it and tell which cave to go into
func _on_player_go_to_wumpus() -> void:
	
	# give them an extra arrow to fight
	if player.arrowCount == 0:
		player.arrowChange(1)
	
	var transferCave : Cave
	var pickedTransferCave = false
	while !pickedTransferCave:
		transferCave = wumpusCave.connectingCaves[randi_range(0,2)]
		if transferCave.currentCaveNumber != currentCaveNumber:
			if transferCave.currentCaveNumber != pitList[0].currentCaveNumber and transferCave.currentCaveNumber != pitList[1].currentCaveNumber:
				if transferCave.currentCaveNumber != batList[0].currentCaveNumber and transferCave.currentCaveNumber != batList[1].currentCaveNumber:
					if transferCave.currentCaveNumber != wumpusCave.currentCaveNumber:
						pickedTransferCave = true
	
	updateCave(transferCave)
	
	
	$OtherWarnings.text = (
		"Go into cave " + str(wumpusCave.currentCaveNumber) + " to test the " +
		"Wumpus Escape or press 'Q' to test the Shoot Arrow experience"
	)
	$OtherWarnings.visible = true

# when the tester wants to experience the bat cave with the anit bat effect
# put them in a cave that is next to it and tell which cave to go into
func _on_player_go_to_anti_bat() -> void:
	
	player.changeAntiBat(true)
	
	var transferCave : Cave
	var pickedTransferCave = false
	while !pickedTransferCave:
		transferCave = batList[0].connectingCaves[randi_range(0,2)]
		if transferCave.currentCaveNumber != currentCaveNumber:
			if transferCave.currentCaveNumber != pitList[0].currentCaveNumber and transferCave.currentCaveNumber != pitList[1].currentCaveNumber:
				if transferCave.currentCaveNumber != batList[0].currentCaveNumber and transferCave.currentCaveNumber != batList[1].currentCaveNumber:
					if transferCave.currentCaveNumber != wumpusCave.currentCaveNumber:
						pickedTransferCave = true
	
	updateCave(transferCave)
	
	$OtherWarnings.text = (
		"Go into cave " + str(batList[0].currentCaveNumber) + " to test the " + 
		"Bat Cave"
	)	
	$OtherWarnings.visible = true
	
# helper function for animations
func wait(seconds:float):
	await get_tree().create_timer(seconds).timeout
