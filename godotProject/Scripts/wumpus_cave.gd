extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Info.text = "The Wumpus has awoken..."
	await get_tree().create_timer(1.5).timeout
	$Info.text = "You must fight to stay alive and avoid being eaten..."
	await get_tree().create_timer(2.5).timeout
	$Info.text = "Answer 3 out of 5 trivia questions correctly\nPress SPACE to continue..."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		pass
		# go to the riddle game generator thing
		# need somewhere if win -> see if wumpus dead if not it runs away 2-4 caves away if yes end game calculate score
		# if lose -> end game calculate score (lose scene)
		# all need to save to leaderboard after score calculated
