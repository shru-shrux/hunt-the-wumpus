extends Control

@onready var difficulty_menu = $game_start_difficulty

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MainMenuBgMusic.play_main_music()
	difficulty_menu.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# shows the menu to select the difficulty of the game
func _on_new_game_pressed() -> void:
	difficulty_menu.visible = true

# shows the options tab of the profile scene
func _on_options_pressed() -> void:
	Global.profile_start_tab = "options"
	get_tree().change_scene_to_file("res://Scenes/profile/profile.tscn") 

# shows the achievements tab of the profile scene
func _on_achievements_pressed() -> void:
	Global.profile_start_tab = "achievements"
	get_tree().change_scene_to_file("res://Scenes/profile/profile.tscn")

# quits the entire game
func _on_quit_pressed() -> void:
	get_tree().quit()

# starts the game while setting the difficulty variable to the difficulty chosen
func _on_easy_pressed() -> void:
	Global.difficulty = "easy"
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_medium_pressed() -> void:
	Global.difficulty = "medium"
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_hard_pressed() -> void:
	Global.difficulty = "hard"
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

# starts tutorial
func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")
