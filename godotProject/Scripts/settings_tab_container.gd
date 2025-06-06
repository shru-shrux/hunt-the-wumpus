extends Control

@onready var tab_container = $TabContainer
@onready var leaderboard_tab = $TabContainer/Leaderboard

# achievement metadata: icon path and description format
const ACHIEVEMENT_META = {
	"score": {
		"icon": "res://Assets/Coins/gold/gold.png",
		"description": "Reach %d points"
	},
	"wins": {
		"icon": "res://Assets/Art/wumpus pixel art.png",
		"description": "Win %d games"
	},
	"trivia": {
		"icon": "res://Assets/Art/trivia.png",
		"description": "Answer %d questions correctly"
	},
	"caves": {
		"icon": "res://Assets/Art/cave.png",
		"description": "Explore %d caves"
	}
}

# achievement thresholds by key/different amounts needed for levels
const ACHIEVEMENT_THRESHOLDS = {
	"score":  [100, 500, 1000, 2000, 5000, 10000],
	"wins":   [1, 5, 10, 20, 50, 100, 200],
	"trivia": [10, 25, 50, 100, 150, 200],
	"caves":  [1, 25, 50, 100, 150, 200, 250, 300]
}

# figure out what tab to start with
func _ready() -> void:
	if Global.profile_start_tab == "options":
		tab_container.current_tab = 2
	elif Global.profile_start_tab == "leaderboard":
		tab_container.current_tab = 0
	elif Global.profile_start_tab == "achievements":
		tab_container.current_tab = 1

# shows the leaderboard
# loads the top 10 scores from the high scores file and displays them
func show_leaderboard():
	var high_scores = load_high_scores()
	var leaderboard = $TabContainer/Leaderboard/MarginContainer/LeaderboardVBox
	
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
	
	# remove all children to start
	for child in leaderboard.get_children():
		child.queue_free()
	
	# fill up leaderboard
	for i in range(min(high_scores.size(), 10)):
		var entry = high_scores[i]
		var label = Label.new()
		label.text = str(i + 1) + ". " + entry["username"] + " - " + str(entry["score"]) + " - " + str(entry["difficulty"])
		var font = load("res://Assets/Fonts/ThaleahFat.ttf")
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 30)
		label.add_theme_color_override("font_color", Color.GRAY)
		leaderboard.add_child(label)

# loads the high scores file
func load_high_scores() -> Array:
	var high_scores = []
	var file_path = "user://highscores.save"
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		high_scores = file.get_var()
		file.close()
	
	# Sort descending
	high_scores.sort_custom(_sort_by_score)
	return high_scores

# sorts scores descending
func _sort_by_score(a, b) -> bool:
	return a["score"] > b["score"]

# shows and displays achievements from the achievement metadata
func show_achievements():
	# load user data and pull achievements dictionary
	var user_data = LoginManager.get_user_data()
	var progress = user_data.get("achievements", {})
	#print(progress)

	# clear old entries
	for child in $TabContainer/Achievements/MarginContainer/ScrollContainer/VBoxContainer.get_children():
		child.queue_free()

	# Empty state
	#if progress.empty():
		#var lbl = Label.new()
		#lbl.text = "No achievements unlocked yet."
		#achievements_vbox.add_child(lbl)

	# Create one row per achievement
	for key in ACHIEVEMENT_META.keys():
		var meta = ACHIEVEMENT_META[key] # icon and description
		var thresholds = ACHIEVEMENT_THRESHOLDS[key] # array of values
		var value = progress.get(key, 0) # user's progress, 0 if none

		# Determine current level
		var level = 0
		print(thresholds.size())
		for i in thresholds.size():
			if value >= thresholds[i]:
				level = i + 1
		
		# Determine next target (or last threshold if maxed)
		var next_target: int
		if level < thresholds.size():
			next_target = thresholds[level]
		else:
			next_target = thresholds[thresholds.size() - 1]

		# UI elements
		var row = HBoxContainer.new()
		$TabContainer/Achievements/MarginContainer/ScrollContainer/VBoxContainer.add_child(row)

		# icon
		var icon = TextureRect.new()
		icon.texture = load(meta["icon"])
		icon.custom_minimum_size = Vector2(64, 64)
		icon.expand_mode = 2
		row.add_child(icon)
		
		# text vbox
		var text_vbox = VBoxContainer.new()
		row.add_child(text_vbox)
		
		# achievement name label
		var ach_label = Label.new()
		# display level or max
		if level == thresholds.size():
			ach_label.text = key + " (max)"
		else:
			ach_label.text = key + " (%d)" % level
		ach_label.add_theme_font_size_override("font_size", 30)
		format_labels(ach_label)
		text_vbox.add_child(ach_label)

		# description label
		var desc_label = Label.new()
		desc_label.text = meta["description"] % next_target
		desc_label.add_theme_font_size_override("font_size", 20)
		format_labels(desc_label)
		text_vbox.add_child(desc_label)
		
		# status label/progress on level of achievement
		var status_label = Label.new()
		status_label.text = "Progress: %d / %d" % [value, next_target]
		desc_label.add_theme_font_size_override("font_size", 15)
		format_labels(status_label)
		text_vbox.add_child(status_label)

# format all the labels
func format_labels(lbl: Label):
	lbl.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	lbl.custom_minimum_size.x = 400
	lbl.add_theme_font_override("font", load("res://Assets/Fonts/Symtext.ttf"))

# change tabs
func _on_tab_container_tab_changed(tab: int) -> void:
	if tab == 0:
		show_leaderboard()
	if tab == 1:
		show_achievements()
