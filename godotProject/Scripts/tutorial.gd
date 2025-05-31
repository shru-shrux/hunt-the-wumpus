extends Control

# images for the tutorial
var tutorial_images = [
	"res://Assets/Tutorial Screenshots/01Main Menu.png",
	"res://Assets/Tutorial Screenshots/02Main Menu Difficulty.png",
	"res://Assets/Tutorial Screenshots/03start_game.png",
	"res://Assets/Tutorial Screenshots/04riddle_off.png",
	"res://Assets/Tutorial Screenshots/05pause.png",
	"res://Assets/Tutorial Screenshots/06shop.png",
	"res://Assets/Tutorial Screenshots/07shop_hover.png",
	"res://Assets/Tutorial Screenshots/08pause.png",
	"res://Assets/Tutorial Screenshots/09options.png",
	"res://Assets/Tutorial Screenshots/10timer_off.png",
	"res://Assets/Tutorial Screenshots/11answer_riddle.png",
	"res://Assets/Tutorial Screenshots/12smell_wumpus.png",
	"res://Assets/Tutorial Screenshots/12riddle_wumpus.png",
	"res://Assets/Tutorial Screenshots/13shoot_arrow.png",
	"res://Assets/Tutorial Screenshots/14No wumpus in cave.png",
	"res://Assets/Tutorial Screenshots/15Bat cave.png",
	"res://Assets/Tutorial Screenshots/16pit_cave.png",
	"res://Assets/Tutorial Screenshots/17Wumpus cave.png",
	"res://Assets/Tutorial Screenshots/18Wumpus trivia.png",
	"res://Assets/Tutorial Screenshots/19end_scene.png",
]

# all the instructions for the game
var instructions = [
	"Welcome to the tutorial! Here, we can click new game to start",
	"Now, you can choose the difficulty of the riddles in the game",
	"This is how the game looks like when you start. You can see the player, the pause button, the timer, toggle riddle button,
	the current cave you are in, how many arrows and gold you have, and the Wumpus health indicator. If it is green, the Wumpus is healthy.
	If it is orange, the Wumpus is damaged. If it is red, the Wumpus is close to dying.",
	"By clicking toggle riddle, you can choose to see the riddle or have it hidden",
	"To pause the game, you can click the pause button. From the menu, you can access the shop",
	"Here, you are able to buy items for the game",
	"To see a description for each item, hover over the information. To go back, hit the x in the corner",
	"Additionally, you can access the options",
	"Here, you can change the volume of the music and sound effects",
	"You can also choose to have the timer hidden",
	"Back to the game, the riddles tell you the shortest path to the Wumpus. This can be very useful but
	beware, you might fall into a hazard. To enter a cave, hit the E key",
	"At the top, if a hazard is in one of the caves, a warning will pop up.",
	"If a Wumpus is nearby, you can use the riddle to figure out which cave it is in and click the Q key to shoot an arrow",
	"If the Wumpus is in the cave, you are directed to a game to see how much damage the Wumpus gets based on
	how accurate you shoot",
	"However, if you choose incorrectly, a message pops up at the bottom telling you and you lose the arrow. Also, the Wumpus
	changes caves everytime you shoot an arrow",
	"Additionally, there are the hazard caves such as the bat cave. The bat cave will take you to a random room and you lose gold
	unless you have the anti-bat effect which you can buy in shop",
	"and the pit cave. When you fall in, you must play a CPS game to determine how much gold you lose. You want to reach the top
	of the ladder to minimize losings.",
	"Lastly, if you enter the Wumpus cave, you must fight to stay alive",
	"There are 5 trivia questions you must answer. If you get 3/5 correct, you stay alive. If not, you lose",
	"Now, you are ready to play the game! Good luck!"
]
var current_index = 0

@onready var image_display = $Image
@onready var next_button = $NextButton
@onready var skip_button = $SkipButton
@onready var instructions_display = $Panel/Instructions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_image()

# updates the image to the next image
func update_image():
	var image = load(tutorial_images[current_index])
	image_display.texture = image
	instructions_display.text = instructions[current_index]
	$Panel.custom_minimum_size.y = instructions_display.get_minimum_size().y + 20
	if current_index == tutorial_images.size() - 1:
		next_button.text = "Back to Menu"
	else:
		next_button.text = "Next"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# goes to the next image
func _on_next_button_pressed() -> void:
	if current_index < tutorial_images.size() -1:
		current_index += 1
		update_image()
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# skips the tutorial
func _on_skip_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# goes back an image
func _on_back_button_pressed() -> void:
	if current_index > 0:
		current_index -= 1
		update_image()
