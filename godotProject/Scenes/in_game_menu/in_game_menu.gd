extends Control

signal resume_pressed
@onready var shop_panel = $CanvasLayer/Shop
@onready var options_panel = $CanvasLayer2/Options
@onready var button_panel = $PanelContainer

func _ready() -> void:
	GameBgMusic.play_game_music()
	shop_panel.hide()
	options_panel.hide()

func _on_resume_pressed() -> void:
	emit_signal("resume_pressed")


func _on_shop_pressed() -> void:
	button_panel.hide()
	shop_panel.show()


func _on_options_pressed() -> void:
	button_panel.hide()
	options_panel.show()
	
func _on_back_from_shop_pressed() -> void:
	shop_panel.hide()
	button_panel.show()

func _on_back_from_options_pressed() -> void:
	options_panel.hide()
	button_panel.show()


func _on_leave_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
