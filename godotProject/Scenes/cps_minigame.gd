extends Node2D
signal cpsMinigameOver

func _on_button_minigame_over() -> void:
	cpsMinigameOver.emit()

func _ready() -> void:
	pass
