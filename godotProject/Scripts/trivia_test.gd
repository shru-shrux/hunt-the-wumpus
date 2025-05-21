extends Node

@onready var trivia_generator = TriviaGenerator.new()

func _ready():
	add_child(trivia_generator)  # Only works if TriviaGenerator extends Node
	print("🧪 Starting trivia generation test...")
	trivia_generator.generate_trivia(_on_trivia_ready)

func _on_trivia_ready(data: Dictionary) -> void:
	print("✅ Trivia received:")
	print("Question: %s" % data.get("question"))
	print("Correct Answer: %s" % data.get("correct"))
	print("Incorrect Answers: %s" % str(data["incorrect"]))

	# Run basic assertions
	assert(data.has("question"), "❌ Missing 'question' key.")
	assert(data.has("correct"), "❌ Missing 'correct' key.")
	assert(data.has("incorrect"), "❌ Missing 'incorrect' key.")
	assert(typeof(data["incorrect"]) == TYPE_ARRAY, "❌ 'incorrect' is not an array.")
	assert(data["incorrect"].size() == 3, "❌ 'incorrect' must have exactly 3 items.")

	print("🎉 Trivia test passed.")
