extends Control

signal toggle_time_visibility(visible: bool)

func _on_back_pressed() -> void:
	get_parent().get_parent()._on_back_from_options_pressed()


func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	pass # Replace with function body. - change the sfx volume


func _on_music_slider_drag_ended(value_changed: bool) -> void:
	pass # Replace with function body. - change the music volume


func _on_check_button_pressed() -> void:
	var visible = not $PanelContainer/VBoxContainer/VBoxContainer/CheckButton.button_pressed
	emit_signal("toggle_time_visibility", visible)
