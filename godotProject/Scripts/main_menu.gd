extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_pressed() -> void:
	pass # Replace with function body.
	# figure out how to change the attribue of margincontainer2 visibility to on (start with it off)


func _on_options_pressed() -> void: # currently does the same as profile but can be changed
	get_tree().change_scene_to_file("res://Scenes/profile.tscn")


func _on_profile_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/profile.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
