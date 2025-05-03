extends Node

@onready var riddle_gen : Node = preload("res://Scripts/riddle_generator.gd").new()

func _ready():
	add_child(riddle_gen)
	print("🔍 Testing riddle generation...")

	var test_number := 3  # Replace with any number you'd like to test

	riddle_gen.generate_riddle_for_number(test_number, func(riddle: String):
		print("✅ Riddle received:")
		print(riddle)
	)
