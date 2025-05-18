extends Button
signal minigameOver

# reference to the player
var player

var goldLost : int

# clicks per second
var CPS : float
# total clicks
var clicks : int
# time elapsed
var timer : float
# duration of CPS game
var gameDuration = 5.0
# if it is counting clicks or not
var gameActive = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CPS = 0.0
	clicks = 0
	timer = 0.0
	gameActive = false
	player = $"../Player"
	player.can_move = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# when the game is active calculate CPS and display it
	if gameActive:
		timer += delta
		# when the game is over
		if timer >= gameDuration:
			timer = gameDuration
			gameActive = false
			disabled = true
			minigameOver.emit()
		CPS = clicks / timer
		# changes the position of the player based on CPS
		# if the player reaches the last step of the ladder stay there
		if CPS > 7:
			$"../Player".position.y = 84
			$"../Player".position.x = 905.7
		# the bare minimum to get off the first step of the ladder
		if CPS > 2:
			$"../Player".position.y = 534 - (floor(CPS-2)) * 90
			$"../Player".position.x = 844 + (floor(CPS-2)) * 12.34
		
	# rounds the CPS to nearest tenth and displays it
	$"../Label".text = "CPS: " + str(round(CPS*10)/10)
	

func _on_button_down() -> void:
	# when the game is going add clicks and play sound
	if gameActive == true:
		clicks += 1
		$"../PopSound".play()
	# first click starts the countdown
	else:
		countdown()

# helper function
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

# countsdown from 3 to start the game
func countdown():
	# disables the button so a new countdown doesn't start
	disabled = true
	
	$"../Countdown".visible = true
	$"../Countdown".text = "3"
	await wait(1.0)
	$"../Countdown".text = "2"
	await wait(1.0)
	$"../Countdown".text = "1"
	await wait(1.0)
	$"../Countdown".visible = false
	# enables the button and starts the game
	disabled = false
	gameActive = true

# when the minigame ends update gold and send back to main
func _on_minigame_over() -> void:
	if CPS <= 2:
		goldLost = -30
	else:
		goldLost = (floor(CPS) - 7) * 5
	
	print("You lost " + str(abs(goldLost)) + " gold from the Pit")
	player.goldChange(goldLost)
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
