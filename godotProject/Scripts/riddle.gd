extends Node

@onready var riddle_gen : Node = preload("res://Scripts/riddle_generator.gd").new()

var difficulty : String
var shownOnUpdate = true

func _ready():
	difficulty = get_parent().difficulty
	add_child(riddle_gen)

func _generate_riddle(room):
	print("🔍 Testing riddle generation...")


	var my_callback := func(riddle: String) -> void:
		print("✅ Riddle received:")
		print(room)
		print(riddle)
		$Panel/Question.text = riddle

	riddle_gen.generate_riddle_for_number(room, my_callback, difficulty)

	print("done")


func _on_button_button_up() -> void:
	$".".visible = false
