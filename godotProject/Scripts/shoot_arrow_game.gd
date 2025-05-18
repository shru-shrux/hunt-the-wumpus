extends Node2D

@onready var slider = $Slider
@onready var label = $Label
@onready var center_marker = $CenterMarker

var speed = 600.0  # pixels per second
var direction = 1  # 1 = right, -1 = left
var min_x = 356
var max_x = 809
var active = true

func _ready():
	slider.position.x = min_x
	label.text = "Shoot the Wumpus!\nPress SPACE when the slider is in the green."

func _process(delta):
	if active:
		slider.position.x += direction * speed * delta

		if slider.position.x < min_x:
			slider.position.x = min_x
			direction *= -1
		elif slider.position.x > max_x:
			slider.position.x = max_x
			direction *= -1

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if active:
			_stop_game()
		#else:
			# put code here to continue the game
			#_reset_game()


func _stop_game():
	active = false
	var slider_center = slider.global_position.x + slider.size.x / 2
	
	if slider_center >= 356 and slider_center < 438:
		# red - 0 damage
		label.text = "You missed! No damage was done to the Wumpus.\nPress SPACE to continue."
	elif slider_center >= 438 and slider_center < 501:
		# orange - 10% damage
		label.text = "Slight damage was done to the Wumpus.\nPress SPACE to continue."
	elif slider_center >= 501 and slider_center < 566:
		# yellow - 25 % damage
		label.text = "Medium damage was done to the Wumpus.\nPress SPACE to continue."
	elif slider_center >= 566 and slider_center < 613:
		# green - 50% damage
		label.text = "Bullseye! A lot of damage was done to the Wumpus.\nPress SPACE to continue."
	elif slider_center >= 613 and slider_center < 661:
		label.text = "Medium damage was done to the Wumpus.\nPress SPACE to continue."
	elif slider_center >= 661 and slider_center < 733:
		label.text = "Slight damage was done to the Wumpus.\nPress SPACE to continue."
	elif slider_center >= 733 and slider_center < 824:
		label.text = "You missed! No damage was done to the Wumpus.\nPress SPACE to continue."
	
	
	#var screen_center = (min_x + max_x) / 2
	#var distance = abs(slider_center - screen_center)
	#var score = max(0, 100 - int(distance))  # Score out of 100
	#label.text = "Distance from center: %.1f px\nScore: %d/100\nPress SPACE to continue." % [distance, score]

#func _reset_game():
	#slider.position.x = min_x
	#direction = 1
	#active = true
	#label.text = "Press SPACE when the slider is in the green."
