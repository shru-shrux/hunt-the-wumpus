extends Control

var player : Node2D

func _ready():
	player = get_tree().current_scene.get_node("/ma")

func _on_back_pressed() -> void:
	get_parent().get_parent()._on_back_from_shop_pressed()
