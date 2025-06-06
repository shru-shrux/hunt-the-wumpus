extends Node

# global variables for parts of the game
var profile_start_tab : String = "achievements"
var difficulty: String

func _ready():
	initialize_high_scores()
	#clear_high_scores()

# create a high scores file unless it already exists (should only be made first time running this game)
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
		

# clear the high score list, can be called as needed
func clear_high_scores():
	var highscore_path = "user://highscores.save"
	var file = FileAccess.open(highscore_path, FileAccess.WRITE)
	file.store_var([])  # Store an empty array to clear the scores
	file.close()
	print("High scores cleared.")

# resets the game so it can be replayed
func reset_game() -> void:
	WumpusData.health = 100
	PlayerData.arrowCount = 3
	PlayerData.goldCount = 0
	PlayerData.wumpusKilled = false
	PlayerData.hasAntiBatEffect = false
	PlayerData.cavesVisited = 0
	PlayerData.triviaCorrect = 0
