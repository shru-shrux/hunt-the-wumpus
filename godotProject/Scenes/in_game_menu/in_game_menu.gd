extends Control

signal resume_pressed
@onready var shop_panel = $CanvasLayer/Shop
@onready var options_panel = $CanvasLayer2/Options
@onready var button_panel = $PanelContainer
#var shop_instance: Node = null

func _ready() -> void:
	GameBgMusic.play_game_music()
	shop_panel.hide()
	options_panel.hide()
	$"../../Wumpus".visible = false

func _on_resume_pressed() -> void:
	emit_signal("resume_pressed")


func _on_shop_pressed() -> void:
	button_panel.hide()
	var player = get_tree().current_scene.get_node("Player")
	if player == null:
		print("ERROR: Player not found in current scene!")
	else:
		print("Player found: ", player)
		shop_panel.set_player(player)
	#if shop_instance == null:
		# Instance the Shop scene
	#	var shop_scene = preload("res://Scenes/in_game_menu/shop.tscn") # Path to your Shop scene
	#	shop_instance = shop_scene.instantiate()
		
		# Pass the player to the shop
	#	var player = get_tree().current_scene.get_node("Player") # Find player in the current scene
	#	shop_instance.set_player(player)
		# Add the Shop instance to the scene tree
	#	get_tree().current_scene.add_child(shop_instance)
	
	shop_panel.show()
	


func _on_options_pressed() -> void:
	button_panel.hide()
	options_panel.show()
	
func _on_back_from_shop_pressed() -> void:
	shop_panel.hide()
	button_panel.show()
	if shop_panel:
		shop_panel.queue_free() # Free the shop instance
		shop_panel = null # Clear reference

func _on_back_from_options_pressed() -> void:
	options_panel.hide()
	button_panel.show()


func _on_leave_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
