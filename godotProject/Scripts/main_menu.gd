extends Control

@onready var difficulty_menu = $game_start_difficulty

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	difficulty_menu.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_pressed() -> void:
	difficulty_menu.visible = true


func _on_options_pressed() -> void:
	Global.profile_start_tab = "options"
	get_tree().change_scene_to_file("res://Scenes/profile/profile.tscn") 


func _on_profile_pressed() -> void:
	Global.profile_start_tab = "profile"
	get_tree().change_scene_to_file("res://Scenes/profile/profile.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_easy_pressed() -> void:
	pass # Replace with function body.


func _on_medium_pressed() -> void:
	pass # Replace with function body.


func _on_hard_pressed() -> void:
	pass # Replace with function body.
