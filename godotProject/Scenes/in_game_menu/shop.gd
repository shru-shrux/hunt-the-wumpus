extends Control

var player : Node2D

func set_player(p : Node2D):
	player = p
	var vbox = get_node("PanelContainer/VBoxContainer2/HBoxContainer2/ScrollContainer/VBoxContainer")

	for hbox in vbox.get_children():
		if hbox is HBoxContainer:
			for panel in hbox.get_children():
				if panel.has_method("set_player"):
					panel.set_player(player)
					print(panel.name, " assigned player: ", player)

func _ready():
	if player == null:
		print("Error: Player not set!")
	else:
		print("Player is now set!")

func _on_back_pressed() -> void:
	get_parent().get_parent()._on_back_from_shop_pressed()
