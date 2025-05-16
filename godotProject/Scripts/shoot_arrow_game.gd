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
	label.text = "Press SPACE when the slider is in the green."

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
		else:
			_reset_game()

func _stop_game():
	active = false
	var slider_center = slider.global_position.x + slider.size.x / 2
	var screen_center = (min_x + max_x) / 2
	var distance = abs(slider_center - screen_center)
	var score = max(0, 100 - int(distance))  # Score out of 100
	label.text = "Distance from center: %.1f px\nScore: %d/100\nPress SPACE to retry." % [distance, score]

func _reset_game():
	slider.position.x = min_x
	direction = 1
	active = true
	label.text = "Press SPACE when the slider is in the green."
