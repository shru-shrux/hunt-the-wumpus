extends Node2D
signal arrowGameDone

@onready var slider = $Slider
@onready var label = $Label
@onready var center_marker = $CenterMarker

var speed = 500.0  # pixels per second
var direction = 1  # 1 = right, -1 = left
var min_x = 356
var max_x = 809
var active = false

# starting game position when you enter the scene
func _ready():
	slider.position.x = min_x
	label.text = "Shoot the Wumpus!\nPress SPACE when the slider is in the green."
	
	# set speed based on difficulty of the game
	if Global.difficulty == "easy":
		speed = 500.0
	elif Global.difficulty == "medium":
		speed = 600.0
	elif Global.difficulty == "hard":
		speed = 700.0

# moving the slider back and forth
func _process(delta):
	if active:
		slider.position.x += direction * speed * delta

		if slider.position.x < min_x:
			slider.position.x = min_x
			direction *= -1
		elif slider.position.x > max_x:
			slider.position.x = max_x
			direction *= -1

# when the space key is hit, slider stops if minigame is active, otherwise moves back to the game
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if active:
			_stop_game()
			
			# if the wumpus is at or below 0 health the game is over
			if WumpusData.health <= 0:
				# maybe do a cut scene to wumpus dying
				PlayerData.wumpusKilled = true
				get_tree().change_scene_to_file("res://Scenes/end_scene.tscn")
		if not active and $".".visible:
			if WumpusData.health <= 0:
				return
			arrowGameDone.emit()

# calculating the result of the game when the minigame is stopped from position of the slider
func _stop_game():
	active = false
	var slider_center = slider.global_position.x + slider.size.x / 2
	var curHealth = WumpusData.health
	
	if slider_center >= 356 and slider_center < 438:
		# red - 0 damage
		label.text = "You missed! No damage was done to the Wumpus.\nPress SPACE to continue."
	elif slider_center >= 438 and slider_center < 501:
		# orange - 10% damage
		label.text = "Slight damage was done to the Wumpus.\nPress SPACE to continue."
		WumpusData.health = curHealth - 10
	elif slider_center >= 501 and slider_center < 566:
		# yellow - 25 % damage
		label.text = "Medium damage was done to the Wumpus.\nPress SPACE to continue."
		WumpusData.health = curHealth - 25
	elif slider_center >= 566 and slider_center < 613:
		# green - 50% damage
		label.text = "Bullseye! A lot of damage was done to the Wumpus.\nPress SPACE to continue."
		WumpusData.health = curHealth - 50
	elif slider_center >= 613 and slider_center < 661:
		label.text = "Medium damage was done to the Wumpus.\nPress SPACE to continue."
		WumpusData.health = curHealth- 25
	elif slider_center >= 661 and slider_center < 733:
		label.text = "Slight damage was done to the Wumpus.\nPress SPACE to continue."
		WumpusData.health = curHealth - 10
	elif slider_center >= 733 and slider_center < 824:
		label.text = "You missed! No damage was done to the Wumpus.\nPress SPACE to continue."
	
	print(curHealth)
	print(WumpusData.health)
	
	
	#var screen_center = (min_x + max_x) / 2
	#var distance = abs(slider_center - screen_center)
	#var score = max(0, 100 - int(distance))  # Score out of 100
	#label.text = "Distance from center: %.1f px\nScore: %d/100\nPress SPACE to continue." % [distance, score]

# resets the game to be playable again
func _reset_game():
	slider.position.x = min_x
	direction = 1
	active = true
	label.text = "Press SPACE when the slider is in the green."

func _on_visibility_changed() -> void:
	
	if visible:
		_reset_game()
