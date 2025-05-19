extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Info.text = "The Wumpus has awoken..."
	await get_tree().create_timer(2.0).timeout
	$Info.text = "You must fight to stay alive and avoid being eaten..."
	await get_tree().create_timer(2.0).timeout
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
