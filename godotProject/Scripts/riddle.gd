extends Node

@onready var riddle_gen : Node = preload("res://Scripts/riddle_generator.gd").new()

var difficulty : String # easy, medium, hard - load later
var shownOnUpdate = true # used in cave_default to determine if shown on update cave

func _ready():
	difficulty = get_parent().difficulty # get difficulty from main
	add_child(riddle_gen) # add riddle generator

func _generate_riddle(room):
	print("🔍 Testing riddle generation...")

	# called when riddle ready, uses local function reference
	var my_callback := func(riddle: String) -> void:
		print("✅ Riddle received:")
		print(room)
		print(riddle)
		
		var question_label = $Panel/Question
		$Panel/Question.text = riddle # show riddle
		
		# panel's size changes based on question's to fit entire label + padding
		$Panel.custom_minimum_size.y = question_label.get_minimum_size().y + 20 
	
	# generate riddle at room
	# once HTTP request/fallback complete calls my_callback function
	riddle_gen.generate_riddle_for_number(room, my_callback, difficulty)

	print("done")

# hides riddle when "X" clicked
func _on_button_button_up() -> void:
	$".".visible = false
