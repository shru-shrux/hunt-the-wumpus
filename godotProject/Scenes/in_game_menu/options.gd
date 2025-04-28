extends Control



func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/in_game_menu/in_game_menu.tscn")
