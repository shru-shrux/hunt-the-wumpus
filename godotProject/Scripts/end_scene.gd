extends Node2D

var base_score = 0
var score = 0
var last_score_entry = {"username": "placeholder", "score": 0}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var user_data = LoginManager.get_user_data()
	
	# Make sure user is logged in
	if user_data.is_empty():
		print("No user logged in.")
		return
	
	# displays whether you won or lsot
	var wumpusScore = 0
	if PlayerData.wumpusKilled == true:
		wumpusScore = 50
		$Result.text = "You Win!"
	else:
		$Result.text = "You Lose"
		
	var timeBonus = 0
	if PlayerData.timeTaken < 120:
		timeBonus = 50
		
	# calculates the score
	base_score = 100 - PlayerData.cavesVisited + PlayerData.goldCount + 5*PlayerData.arrowCount + wumpusScore + timeBonus
	
	var difficulty_multiplier 
	
	# score gets multiplied by a multiplier based on difficulty of the game
	if Global.difficulty == "easy":
		score = base_score
		difficulty_multiplier = 1.0
	elif Global.difficulty == "medium":
		score = base_score * 1.1
		difficulty_multiplier = 1.1
	elif Global.difficulty == "hard":
		score = base_score * 1.2
		difficulty_multiplier = 1.2
	$YourScore.clear()
	$YourScore.add_text(str(score))
	
	# displays the score breakdown
	#if PlayerData.wumpusKilled:
		#$ScoreBreakdown.text = "100 - " + str(PlayerData.cavesVisited) + " (Caves Visited)\n" + "+ " + str(PlayerData.goldCount) + " (Gold Count)\n" + "5 * " + str(PlayerData.arrowCount) + " (Arrow Count)\n" + "50 (Wumpus Killed)\n= " + str(base_score) + " * " + str(difficulty_multiplier) + " (Difficulty Multiplier)" 
	#else:
		#$ScoreBreakdown.text = "100 - " + str(PlayerData.cavesVisited) + " (Caves Visited)\n" + "+ " + str(PlayerData.goldCount) + " (Gold Count)\n" + "5 * " + str(PlayerData.arrowCount) + " (Arrow Count)\n= " + str(base_score) + " * " + str(difficulty_multiplier) + " (Difficulty Multiplier)" 
	if PlayerData.wumpusKilled:
		if PlayerData.timeTaken < 120:
			$ScoreBreakdown.text = "100\n" + str(PlayerData.cavesVisited) + "\n" + str(PlayerData.goldCount) + "\n" + "5 x " + str(PlayerData.arrowCount) + "\n" + "50 \n" + "50 \n " + "x " + str(difficulty_multiplier)
		else:
			$ScoreBreakdown.text = "100\n" + str(PlayerData.cavesVisited) + "\n" + str(PlayerData.goldCount) + "\n" + "5 x " + str(PlayerData.arrowCount) + "\n" + "50 \n" + "0 \n " + "x " + str(difficulty_multiplier)
	else:
		if PlayerData.timeTaken < 120:
			$ScoreBreakdown.text = "100\n" + str(PlayerData.cavesVisited) + "\n" + str(PlayerData.goldCount) + "\n" + "5 x " + str(PlayerData.arrowCount) + "\n" + "0 \n" + "50 \n " + "x " + str(difficulty_multiplier)
		else:
			$ScoreBreakdown.text = "100\n" + str(PlayerData.cavesVisited) + "\n" + str(PlayerData.goldCount) + "\n" + "5 x " + str(PlayerData.arrowCount) + "\n" + "0 \n" + "0 \n " + "x " + str(difficulty_multiplier)
	
	# displays the reason the game ended
	if PlayerData.howEnded == 0:
		$EndReason.text = "Congratulations! You have slain the Wumpus and lived another day."
	elif PlayerData.howEnded == 1:
		$EndReason.text = "Try again. You have been defeated by the Wumpus."
	elif PlayerData.howEnded == 2:
		$EndReason.text = "Try again. You lost too many coins to continue."
	
	# gets the username of the player
	var username = "placeholder"
	if LoginManager.get_user_data() != null:
		username = user_data.get("username")
		
	var difficulty = Global.difficulty
	
	last_score_entry = {"username": str(username), "score": int(score), "difficulty": str(difficulty)}
	save_new_score(last_score_entry["username"], last_score_entry["score"], last_score_entry["difficulty"])
	
	show_leaderboard()
	
	# Update achievements
	if typeof(user_data["achievements"]) != TYPE_DICTIONARY:
		print("Corrupted or missing achievements. Resetting...")
		user_data["achievements"] = {
			"score": 0,
			"wins": 0,
			"triviaCorrect": 0,
			"cavesVisited": 0
		}
	
	user_data["achievements"]["score"] += score
	if PlayerData.wumpusKilled:
		user_data["achievements"]["wins"] += 1
	user_data["achievements"]["trivia"] += PlayerData.triviaCorrect
	user_data["achievements"]["caves"] += PlayerData.cavesVisited
	LoginManager.update_user_data(user_data)
	
	Global.reset_game()

# saves the new soore to the high score file
# saves the username, score, and difficulty
func save_new_score(username: String, score: int, difficulty: String):
	var file_path = "user://highscores.save"
	var high_scores = []

	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		high_scores = file.get_var()
		file.close()

	high_scores.append({"username": username, "score": score, "difficulty": difficulty})

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_var(high_scores)
	file.close()

# shows the top 10 current high scores from the high scores file 
func show_leaderboard():
	var high_scores = load_high_scores()
	var leaderboard = $Leaderboard
	
	
	# Handle empty case
	if high_scores.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No high scores yet!"
		var font = load("res://Assets/Fonts/ThaleahFat.ttf")
		empty_label.add_theme_font_override("font", font)
		empty_label.add_theme_font_size_override("font_size", 30)
		empty_label.add_theme_color_override("font_color", Color(168.0, 179.0, 216.0))
		leaderboard.add_child(empty_label)
		return

	for child in leaderboard.get_children():
		child.queue_free()
	
	for i in range(min(high_scores.size(), 10)):
		var entry = high_scores[i]
		var label = Label.new()
		label.text = str(i + 1) + ". " + entry["username"] + " - " + str(entry["score"])
		var font = load("res://Assets/Fonts/ThaleahFat.ttf")
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 30)
		label.add_theme_color_override("font_color", Color(168.0, 179.0, 216.0))
			
		## Highlight if it's the last score just added
		#if entry["username"] == last_score_entry["username"] and entry["score"] == last_score_entry["score"]:
			#label.add_theme_color_override("font_color", Color.WHITE)  # Highlight color
		#else:
			#label.add_theme_color_override("font_color", Color.GRAY)
			
		leaderboard.add_child(label)

# loads the high scores from the high scores file and sorts descending
func load_high_scores() -> Array:
	var high_scores = []
	var file_path = "user://highscores.save"
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		high_scores = file.get_var()
		file.close()
	
	if high_scores.size() > 0:
		high_scores.sort_custom(Callable(self, "_sort_by_score"))
	
	return high_scores

# sorts descending scores
func _sort_by_score(a, b) -> bool:
	return a["score"] > b["score"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# brings you to the main menu
func _on_home_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
