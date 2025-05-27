extends Control
class_name TriviaPopup

signal trivia_won
signal trivia_lost

var trivia_generator = TriviaGenerator.new()
@onready var question_label    = $Panel/Question
@onready var answers_container = $Panel/GridContainer

var difficulty : String

var total_questions: int
var required_correct: int
var questions: Array = []
var current_index: int
var correct_count: int
var current_correct: String

func _ready():
	# 1) instantiate & add to scene so its _ready() fires
	trivia_generator = TriviaGenerator.new()
	add_child(trivia_generator)

	# 2) wire up your buttons
	for btn in answers_container.get_children():
		btn.connect("pressed", Callable(self, "_on_answer_button_pressed").bind(btn))

	visible = false
	
	# pull difficulty off parent
	difficulty = get_parent().difficulty

func start_trivia(total: int = 5, required: int = 3, difficulty_param: String = "medium") -> void:
	visible = true
	total_questions  = total
	required_correct = required
	questions.clear()
	current_index = 0
	correct_count = 0

	# generate them all
	for i in range(total_questions):
		trivia_generator.generate_trivia(_on_single_ready, difficulty_param)

func _on_single_ready(data: Dictionary) -> void:
	questions.append(data)
	if questions.size() == total_questions:
		_show_question(0)

func _show_question(idx: int) -> void:
	current_index = idx
	var q = questions[idx]
	question_label.text = q.question

	var answers = q.incorrect.duplicate()
	answers.append(q.correct)
	answers.shuffle()

	current_correct = q.correct
	for i in range(answers_container.get_child_count()):
		var btn = answers_container.get_child(i)
		btn.text = answers[i]
		btn.set_meta("answer", answers[i])

func _on_answer_button_pressed(btn: Button) -> void:
	if btn.get_meta("answer") == current_correct:
		correct_count += 1
		print("correct")
		PlayerData.triviaCorrect += 1

	var next = current_index + 1
	if next < total_questions:
		_show_question(next)
	else:
		visible = false
		print(correct_count)
		if correct_count >= required_correct:
			emit_signal("trivia_won")
		else:
			emit_signal("trivia_lost")
