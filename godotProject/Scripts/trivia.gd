extends Control
class_name TriviaPopup

signal trivia_won
signal trivia_lost

var trivia_generator = TriviaGenerator.new()
@onready var question_label = $Panel/Question
@onready var answers_container = $Panel/GridContainer
@onready var player = get_parent().get_node("Player")

var difficulty : String

var total_questions: int
var required_correct: int
var questions: Array = []
var current_index: int
var correct_count: int
var current_correct: String
var pending_to_generate = 0

# Track whether we're waiting for the next question to arrive
var waiting_for_next = false

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

func start_trivia(total: int = 5, required: int = 3) -> void:
	#visible = true
	total_questions = total
	required_correct = required
	questions.clear()
	current_index = 0
	correct_count = 0
	pending_to_generate = total_questions
	waiting_for_next = false

	## generate them all - breaks because can't have multiple at once
	#for i in range(total_questions):
		#trivia_generator.generate_trivia(_on_single_ready, difficulty)
		
	# Start the first one
	_generate_next_trivia()

func _generate_next_trivia():
	if pending_to_generate > 0:
		trivia_generator.generate_trivia(_on_single_ready, difficulty)
		
func _on_single_ready(data: Dictionary) -> void:
	questions.append(data)
	pending_to_generate -= 1 

	if questions.size() == 1:
		_show_question(0)
		visible = true
	else:
		# If we were waiting for "next" (waiting_for_next = true),
		# and now there is one more question in `questions`, show it.
		if waiting_for_next and questions.size() > current_index:
			_show_question(current_index)
			waiting_for_next = false
			# No need to adjust visible (already visible)

		print("Queued trivia question ready.")


func _show_question(idx: int) -> void:
	player.goldChange(-1)
	
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
		btn.disabled = false  # enable buttons

func _on_answer_button_pressed(btn: Button) -> void:
	for child in answers_container.get_children():
		child.disabled = true

	if btn.get_meta("answer") == current_correct:
		correct_count += 1
		print("correct")
		PlayerData.triviaCorrect += 1
	else:
		print("wrong")

	current_index += 1  # move this down

	if current_index < total_questions:
		if current_index < questions.size():
			_show_question(current_index)
			
			# Kick off generating the next one in background if needed:
			if pending_to_generate > 0:
				_generate_next_trivia()
		else:
			# Next question is not yet ready → enter “waiting” mode:
			print("Waiting for next trivia question to load...")
			waiting_for_next = true  # remember that we want to show index =current_index
			# Kick off generating next if we haven’t already:
			
			if pending_to_generate > 0:
				_generate_next_trivia()
			# We will re-enable buttons when _on_single_ready() actually shows it.
			
	else:
		visible = false
		print(correct_count)
		if correct_count >= required_correct:
			emit_signal("trivia_won")
		else:
			emit_signal("trivia_lost")
