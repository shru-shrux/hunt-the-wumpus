extends Node2D

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 100 - PlayerData.numberTurns + PlayerData.goldCount + 5*PlayerData.arrowCount + PlayerData.wumpusKilled
	$YourScore.clear()
	$YourScore.add_text(str(score))
	show_leaderboard()


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
		leaderboard.add_child(label)

func load_high_scores() -> Array:
	var high_scores = []
	var file_path = "user://highscores.save"
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		high_scores = file.get_var()
		file.close()
	
	# Sort descending
	high_scores.sort_custom(self, "_sort_by_score")
	return high_scores

func _sort_by_score(a, b):
	return b["score"] - a["score"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
