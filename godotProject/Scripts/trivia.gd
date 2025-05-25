extends Control
class_name TriviaPopup

signal trivia_won
signal trivia_lost

@onready var trivia_generator = TriviaGenerator.new()
@onready var question_label    = $Panel/Question
@onready var answers_container = $Panel/GridContainer

var difficulty : String

var questions: Array = []
var total_questions: int
var required_correct: int

var current_index: int
var correct_count: int

var current_correct: String

func _ready():
	difficulty = get_parent().difficulty

	# connect each button ONCE, binding the button instance as an argument
	for btn in answers_container.get_children():
		var cb = Callable(self, "_on_answer_button_pressed").bind(btn)
		btn.connect("pressed", cb)

func start_trivia(total: int = 5, required: int = 3, difficulty_param: String = "medium") -> void:
	total_questions   = total           # ← make sure to store these!
	required_correct  = required
	difficulty        = difficulty_param

	questions.clear()
	current_index = 0
	correct_count = 0

	# generate all questions up front
	for i in range(total_questions):
		trivia_generator.generate_trivia(_on_single_ready, difficulty)

func _on_single_ready(data: Dictionary) -> void:
	questions.append(data)
	if questions.size() == total_questions:
		_show_question(0)

func _show_question(index: int) -> void:
	current_index = index
	var qdata = questions[index]

	question_label.text = qdata.question

	var all_answers = qdata.incorrect.duplicate()
	all_answers.append(qdata.correct)
	all_answers.shuffle()

	current_correct = qdata.correct

	var i = 0
	for btn in answers_container.get_children():
		btn.text = all_answers[i]
		btn.set_meta("answer", all_answers[i])
		i += 1

	visible = true

func _on_answer_button_pressed(btn: Button) -> void:
	var selected = btn.get_meta("answer") as String
	if selected == current_correct:
		correct_count += 1

	var next = current_index + 1
	if next < total_questions:
		_show_question(next)
	else:
		visible = false
		if correct_count >= required_correct:
			emit_signal("trivia_won")
		else:
			emit_signal("trivia_lost")
