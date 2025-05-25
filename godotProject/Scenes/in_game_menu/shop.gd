extends Control

var player : Node2D

func set_player(p : Node2D):
	player = p
	for card in get_node("VBoxContainer").get_children():
		if card.has_method("set_player"):
			card.set_player(player)

func _ready():
	if player == null:
		print("Error: Player not set!")
	else:
		print("Player is now set!")

func _on_back_pressed() -> void:
	get_parent().get_parent()._on_back_from_shop_pressed()
