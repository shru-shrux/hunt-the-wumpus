extends Control

func resume():
	get_tree().paused = false
	
func pause():
	get_tree().paused = true
	
# need function for when button is pressed.
	# call pause()

func _on_resume_pressed() -> void:
	resume()


func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/in_game_menu/shop.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/in_game_menu/options.tscn")


func _on_leave_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
