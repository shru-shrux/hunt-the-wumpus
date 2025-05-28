extends Node2D

var score = 0
var last_score_entry = {"username": "placeholder", "score": 0}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var wumpusScore = 0
	if PlayerData.wumpusKilled == true:
		wumpusScore = 50
		$Result.text = "You Win!"
	else:
		$Result.text = "You Lose"
	score = 100 - PlayerData.cavesVisited + PlayerData.goldCount + 5*PlayerData.arrowCount + wumpusScore
	$YourScore.clear()
	$YourScore.add_text(str(score))
	
	var username = "placeholder"
	if LoginManager.get_user_data() == null:
		username = "placeholder"
	else:
		var user_data = LoginManager.get_user_data()
		username = user_data.get("username")
	
	last_score_entry = {"username": username, "score": score}
	save_new_score(last_score_entry["username"], last_score_entry["score"])
	
	show_leaderboard()

func save_new_score(username: String, score: int):
	var file_path = "user://highscores.save"
	var high_scores = []

	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		high_scores = file.get_var()
		file.close()

	high_scores.append({"username": username, "score": score})

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_var(high_scores)
	file.close()


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
		empty_label.add_theme_color_override("font_color", Color.GRAY)
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
		label.add_theme_color_override("font_color", Color.GRAY)
			
		## Highlight if it's the last score just added
		#if entry["username"] == last_score_entry["username"] and entry["score"] == last_score_entry["score"]:
			#label.add_theme_color_override("font_color", Color.WHITE)  # Highlight color
		#else:
			#label.add_theme_color_override("font_color", Color.GRAY)
			
		leaderboard.add_child(label)

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

func _sort_by_score(a, b) -> bool:
	return a["score"] > b["score"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_home_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
