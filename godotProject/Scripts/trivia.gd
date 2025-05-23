extends Control

@onready var trivia_generator = TriviaGenerator.new()

var difficulty = get_parent().difficulty

func _ready():
	add_child(trivia_generator)  # Only works if TriviaGenerator extends Node
	_generate_trivia()

func _generate_trivia():
	print("🧪 Starting trivia generation test...")
	trivia_generator.generate_trivia(_on_trivia_ready, difficulty)

func _on_trivia_ready(data: Dictionary) -> void:
	print("✅ Trivia received:")
	
	var question = data.get("question")
	var correct_answer = data.get("correct")
	var incorrect_answers = data["incorrect"]
	var all_answers = incorrect_answers.duplicate()
	all_answers.append(correct_answer)
	
	$Panel/Question.text = question
	$Panel/GridContainer/Answer1.text = all_answers[0]
	$Panel/GridContainer/Answer2.text = all_answers[1]
	$Panel/GridContainer/Answer3.text = all_answers[2]
	$Panel/GridContainer/Answer4.text = all_answers[3]
	
	# Run basic assertions
	assert(data.has("question"), "❌ Missing 'question' key.")
	assert(data.has("correct"), "❌ Missing 'correct' key.")
	assert(data.has("incorrect"), "❌ Missing 'incorrect' key.")
	assert(typeof(data["incorrect"]) == TYPE_ARRAY, "❌ 'incorrect' is not an array.")
	assert(data["incorrect"].size() == 3, "❌ 'incorrect' must have exactly 3 items.")

	print("🎉 Trivia test passed.")
