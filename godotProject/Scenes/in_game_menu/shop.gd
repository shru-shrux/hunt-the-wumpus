extends Control


func _on_back_pressed() -> void:
	get_parent().get_parent()._on_back_from_shop_pressed()
