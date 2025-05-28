extends Control

signal toggle_time_visibility(visible: bool)

# when back pressed, call function from in game menu
func _on_back_pressed() -> void:
	get_parent().get_parent()._on_back_from_options_pressed()

# when timer pressed, emit signal for game control
func _on_check_button_pressed() -> void:
	var visible = not $PanelContainer/VBoxContainer/VBoxContainer/CheckButton.button_pressed
	emit_signal("toggle_time_visibility", visible)
