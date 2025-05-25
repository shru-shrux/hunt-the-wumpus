extends Control

@onready var main = $"../../"

func _ready() -> void:
	GameBgMusic.play_game_music()

func _on_resume_pressed() -> void:
	main.in_game_menu()


func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/in_game_menu/shop.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/in_game_menu/options.tscn")


func _on_leave_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
