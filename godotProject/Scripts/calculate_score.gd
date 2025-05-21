extends Node

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 100 - PlayerData.numberTurns + PlayerData.goldCount + 5*PlayerData.arrowCount + PlayerData.wumpusKilled


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
