class_name Profile
extends Control


func _ready():
	pass


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn") 
