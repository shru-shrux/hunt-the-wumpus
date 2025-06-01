extends Control
class_name TriviaPopup

# signals to cave_default based on what happens
signal trivia_won
signal trivia_lost

var trivia_generator = TriviaGenerator.new() # generates trivia
@onready var question_label = $Panel/Question
@onready var answers_container = $Panel/GridContainer
@onready var player = get_parent().get_node("Player")

var difficulty : String # difficulty, get from parent later

var total_questions: int
var required_correct: int
var questions: Array = [] # dictionaries of questions
var seen_questions: Array = [] # questions seen during entire game
var seen_topics: Array = [] # topics seen during only one time cave

var current_index: int # location in questions array
var correct_count: int # correct so far
var current_correct: String # correct answer of current question

var pending_to_generate = 0 # how many questions left to generate
var waiting_for_next = false # track whether we're waiting for the next question to arrive


func _ready():
	# instantiate & add to scene so its _ready() fires
	trivia_generator = TriviaGenerator.new()
	add_child(trivia_generator)

	# wire up your buttons
	for btn in answers_container.get_children():
		btn.connect("pressed", Callable(self, "_on_answer_button_pressed").bind(btn))

	visible = false # start hidden
	
	# pull difficulty off parent
	difficulty = get_parent().difficulty

# new round of trivia 
func start_trivia(total: int = 5, required: int = 3) -> void:
	# reset values
	total_questions = total
	required_correct = required
	questions.clear()
	#seen_questions.clear() - don't want the same questions within a game
	current_index = 0
	correct_count = 0
	pending_to_generate = total_questions
	waiting_for_next = false
	seen_topics.clear()

	## generate them all - breaks because can't have multiple at once
	#for i in range(total_questions):
		#trivia_generator.generate_trivia(_on_single_ready, difficulty)
	
	# generate first question
	_generate_next_trivia()

# if questions left, generate another
func _generate_next_trivia():
	if pending_to_generate > 0:
		trivia_generator.generate_trivia(_on_single_ready, difficulty)

# callback from generate_trivia once data ready
func _on_single_ready(data: Dictionary) -> void:
	# if already seen this question text, discard it and fetch another
	var qtext = data.get("question", "") # extract question 
	var topic = _detect_topic(qtext) # detect topic based on keywords
	
	# it’s the same topic as had before, discard and ask again
	if topic in seen_topics:
		print("Discarded a '%s' question because we've already used that topic before." % topic)
		_generate_next_trivia()
		return
	
	# if already had question, discard and ask again
	if qtext in seen_questions:
		print("Discarded duplicate question: '%s'. Fetching a new one…" % qtext)
		_generate_next_trivia()
		return
	
	# update question tracking
	questions.append(data)
	seen_questions.append(qtext)
	if topic != "other": # lots of questions flagged other, so doens't count as topic
		seen_topics.append(topic)
	pending_to_generate -= 1 
	
	if questions.size() == 1:
		# first question in the list, show it right now
		_show_question(0)
		visible = true
	else:
		# if waiting for “next” (waiting_for_next = true) and now it’s available:
		if waiting_for_next and questions.size() > current_index:
			_show_question(current_index)
			waiting_for_next = false
			# visible is already true
		
		print("Queued a new unique trivia question.")

# display question number idx from questions array
func _show_question(idx: int) -> void:
	player.goldChange(-1) # takes 1 gold to do trivia
	
	current_index = idx
	var q = questions[idx]
	question_label.text = q.question # set question text
	
	# array of all answers then shuffle, so not always same button
	var answers = q.incorrect.duplicate()
	answers.append(q.correct)
	answers.shuffle()

	current_correct = q.correct # store correct answer
	
	# create button for each answer
	for i in range(answers_container.get_child_count()):
		var btn = answers_container.get_child(i)
		btn.text = answers[i]
		btn.set_meta("answer", answers[i])
		btn.disabled = false  # enable buttons

func _on_answer_button_pressed(btn: Button) -> void:
	# disable all buttons immediately, otherwise can answer same question multiple times
	for child in answers_container.get_children():
		child.disabled = true

	# check if answer correct
	if btn.get_meta("answer") == current_correct:
		correct_count += 1
		print("correct")
		PlayerData.triviaCorrect += 1
	else:
		print("wrong")

	current_index += 1  # move onto next question

	if current_index < total_questions: # if questions left
		if current_index < questions.size(): # next question ready
			_show_question(current_index)
			
			# kick off generating the next one in background if needed:
			if pending_to_generate > 0:
				_generate_next_trivia()
		else: # next question not ready yet
			# next question is not yet ready -> enter “waiting” mode
			print("Waiting for next trivia question to load...")
			waiting_for_next = true  # remember that we want to show index =current_index
			
			# kick off generating next if we haven’t already
			if pending_to_generate > 0:
				_generate_next_trivia()
		
	else: # showed all questions already
		visible = false
		print(correct_count)
		if correct_count >= required_correct: # got the needed amount of questions correct
			emit_signal("trivia_won")
		else:
			emit_signal("trivia_lost")

# guess topic based on keywords, so the same types of questions aren't asked over and over
func _detect_topic(qtext: String) -> String:
	var t = qtext.to_lower()

	# Check for “art” keywords:
	if t.find("paint") >= 0 or t.find("artist") >= 0 or t.find("mona lisa") >= 0 or t.find("van gogh") >= 0:
		return "art"

	# Check for “geography” keywords:
	if t.find("capital") >= 0 or t.find("continent") >= 0 or t.find("ocean") >= 0 or t.find("titanic") >= 0:
		return "geography"

	# Check for “literature” keywords:
	if t.find("play") >= 0 or t.find("author") >= 0 or t.find("shakespeare") >= 0 or t.find("romeo") >= 0:
		return "literature"

	# Check for “history” keywords:
	if t.find("year") >= 0 and t.find("sink") >= 0:  # e.g. “In what year did the Titanic sink?”
		return "history"
	if t.find("war") >= 0 or t.find("revolution") >= 0 or t.find("president") >= 0 or t.find("founding") >= 0:
		return "history"

	# Check for “math” keywords:
	if t.find("prime") >= 0 or t.find("square root") >= 0 or t.find("sum") >= 0 or t.find("product") >= 0:
		return "math"

	# Check for “sports” keywords:
	if t.find("ball") >= 0 or t.find("team") >= 0 or t.find("score") >= 0 or t.find("olympic") >= 0 or t.find("world cup") >= 0:
		return "sports"

	# Check for “pop culture” keywords:
	if t.find("movie") >= 0 or t.find("song") >= 0 or t.find("actor") >= 0 or t.find("singer") >= 0 or t.find("band") >= 0:
		return "pop culture"

	# Check for “science” keywords:
	if t.find("element") >= 0 or t.find("chemical") >= 0 or t.find("gas") >= 0 or t.find("oxygen") >= 0:
		return "science"

	# If none of the above matched, return “other”:
	return "other"
