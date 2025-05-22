extends Control

@onready var tab_container = $TabContainer
@onready var leaderboard_tab = $TabContainer/Leaderboard
@onready var achievements_vbox = $TabContainer/Achievements/MarginContainer/ScrollContainer/VBoxContainer

# Achievement metadata: icon path and description format
const ACHIEVEMENT_META = {
	"score": {
		"icon": "res://assets/ach_score.png",
		"description": "Reach %d points"
	},
	"wins": {
		"icon": "res://assets/ach_wins.png",
		"description": "Win %d games"
	},
	"trivia": {
		"icon": "res://assets/ach_trivia.png",
		"description": "Answer %d questions correctly"
	},
	"caves": {
		"icon": "res://assets/ach_caves.png",
		"description": "Explore %d caves"
	}
}

# Achievement thresholds by key
const ACHIEVEMENT_THRESHOLDS = {
	"score":  [50, 100, 250, 500],
	"wins":   [1, 5, 10, 20],
	"trivia": [10, 25, 50, 100],
	"caves":  [1, 3, 5, 10]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.profile_start_tab == "profile":
		tab_container.current_tab = 2
	elif Global.profile_start_tab == "options":
		tab_container.current_tab = 3
	elif Global.profile_start_tab == "leaderboard":
		tab_container.current_tab = 0
	elif Global.profile_start_tab == "achievements":
		tab_container.current_tab = 1


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
	high_scores.sort_custom(_sort_by_score)
	return high_scores
	
func _sort_by_score(a, b) -> bool:
	return a["score"] > b["score"]


func show_achievements():
	var user_data = LoginManager.get_user_data()
	var progress = user_data.get("achievements", {})

	# Clear old entries
	for child in achievements_vbox.get_children():
		child.queue_free()

	# Empty state
	if progress.empty():
		var lbl = Label.new()
		lbl.text = "No achievements unlocked yet."
		style_label(lbl)
		achievements_vbox.add_child(lbl)
		return

	# Create one row per achievement
	for key in ACHIEVEMENT_META.keys():
		var meta = ACHIEVEMENT_META[key]
		var thresholds = ACHIEVEMENT_THRESHOLDS[key]
		var value = progress.get(key, 0)

		# Determine current level
		var level = 0
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

		var icon = TextureRect.new()
		icon.texture = load(meta["icon"])
		icon.custom_minimum_size = Vector2(64, 64)
		row.add_child(icon)

		var text_vbox = VBoxContainer.new()
		var desc_label = Label.new()
		desc_label.text = meta["description"] % next_target
		var status_label = Label.new()
		status_label.text = "Progress: %d / %d" % [value, next_target]
		text_vbox.add_child(desc_label)
		text_vbox.add_child(status_label)
		row.add_child(text_vbox)

		achievements_vbox.add_child(row)

func style_label(lbl: Label):
	lbl.add_theme_color_override("font_color", Color.GRAY)
	lbl.add_theme_font_size_override("font_size", 20)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tab_container_tab_changed(tab: int) -> void:
	if tab == 0:
		show_leaderboard()
