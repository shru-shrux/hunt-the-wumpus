extends Node

var profile_start_tab : String = "profile"

func _ready():
	initialize_high_scores()

func initialize_high_scores():
	var highscore_path = "user://highscores.save"
	
	if not FileAccess.file_exists(highscore_path):
		var default_scores = []
		var file = FileAccess.open(highscore_path, FileAccess.WRITE)
		file.store_var(default_scores)
		file.close()
		print("High score file created.")
	else:
		print("High score file already exists.")
