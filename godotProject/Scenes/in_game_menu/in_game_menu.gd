extends Control

signal resume_pressed
@onready var shop_panel = $CanvasLayer/Shop
@onready var options_panel = $CanvasLayer2/Options
@onready var button_panel = $PanelContainer

func _ready() -> void:
	GameBgMusic.play_game_music()
	shop_panel.hide()
	options_panel.hide()
	$"../../Wumpus".visible = false

# when resume pressed, emit signal 
func _on_resume_pressed() -> void:
	emit_signal("resume_pressed")

# when shop button pressed in menu, show shop and hide menu
func _on_shop_pressed() -> void:
	button_panel.hide()
	shop_panel.show()
	# getting player data for shop
	var player = get_tree().current_scene.get_node("Player")
	if player == null:
		print("ERROR: Player not found in current scene!")
	else:
		print("Player found: ", player)
		shop_panel.set_player(player)	

# when options button pressed in menu, show options and hide menu
func _on_options_pressed() -> void:
	button_panel.hide()
	options_panel.show()

# when back button pressed in shop, hide shop and show menu
func _on_back_from_shop_pressed() -> void:
	shop_panel.hide()
	button_panel.show()

# when back button pressed in options, hide options and show menu
func _on_back_from_options_pressed() -> void:
	options_panel.hide()
	button_panel.show()

# when leave game button pressed, bring back to main menu scene
func _on_leave_game_pressed() -> void:
	Global.reset_game()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
