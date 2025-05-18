extends Button

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
		CPS = clicks / timer
		# changes the position of the player based on CPS
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
	
	
