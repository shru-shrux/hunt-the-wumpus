extends Button
signal minigameOver

# reference to the player
var player

# the amount of gold the player lost from this minigame
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
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# when the game is active calculate CPS and display it
	if gameActive:
		timer += delta
		# when the game is over
		if timer >= gameDuration:
			timer = gameDuration
			gameActive = false
			# can't click the button anymore
			disabled = true
			# signal to finish the game
			minigameOver.emit()
			return
		# calculates the clicks per second
		CPS = clicks / timer
		# changes the position of the player based on CPS
		# if the player reaches the last step of the ladder stay there
		if CPS > 7:
			player.position.y = 84
			player.position.x = 905.7
		# the bare minimum to get off the first step of the ladder
		elif CPS > 2:
			player.position.y = 534 - (floor(CPS-2)) * 90
			player.position.x = 844 + (floor(CPS-2)) * 12.34
		
	# rounds the CPS to nearest tenth and displays it
	$"../CPSCounter".text = "CPS: " + str(round(CPS*10)/10)
	

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
	
	# counts down from 3 to 0
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

# when the minigame ends update gold and ready player for normal cave
func _on_minigame_over() -> void:
	
	$"../TimesUp".visible = true
	await wait(1.0)
	$"../TimesUp".visible = false
	await wait (1.0)
	
	# determine how much gold is lost
	if CPS <= 2:
		goldLost = -30
	elif CPS >= 7:
		goldLost = 0
	else:
		goldLost = (floor(CPS) - 7) * 5
	
	print("You lost " + str(abs(goldLost)) + " gold from the Pit")
	# update how much gold the player has
	player.goldChange(goldLost)
	
	# hide the minigame and reset the player to spawn
	get_parent().visible = false
	player.falling = false
	player.can_move = true
	self.disabled = false
	player.position = Vector2(119,528)
	

func _on_cps_minigame_visibility_changed() -> void:
	# if the CpsMinigame Node is visible the game needs to be set up.
	# everything resets and a refrence to the player is defined
	if get_parent().visible:
		CPS = 0.0
		clicks = 0
		timer = 0.0
		gameActive = false
		player = get_parent().get_parent().get_parent().get_node("Player")
		player.falling = false
		player.can_move = false
		player.position = Vector2(844,534)
		player.get_child(0).flip_h = 0
