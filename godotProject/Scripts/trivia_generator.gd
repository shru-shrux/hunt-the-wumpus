extends Node
class_name TriviaGenerator

var http_request: HTTPRequest
var api_key: String
var on_trivia_ready: Callable = func(_data: Dictionary) -> void: pass

var is_requesting = false

# Simple fallback trivia list
var fallback_trivia: Array = [
	{
		"question": "What is the capital of France?",
		"correct": "Paris",
		"incorrect": ["Rome", "Berlin", "Madrid"]
	},
	{
		"question": "What is the smallest prime number?",
		"correct": "2",
		"incorrect": ["1", "0", "3"]
	},
	{
		"question": "Which element has the chemical symbol 'O'?",
		"correct": "Oxygen",
		"incorrect": ["Gold", "Osmium", "Oxide"]
	},
	{
		"question": "Who wrote the play 'Romeo and Juliet'?",
		"correct": "William Shakespeare",
		"incorrect": ["Charles Dickens", "Jane Austen", "Mark Twain"]
	},
	{
		"question": "Which planet is known as the Red Planet?",
		"correct": "Mars",
		"incorrect": ["Venus", "Jupiter", "Saturn"]
	},
	{
		"question": "How many continents are there on Earth?",
		"correct": "7",
		"incorrect": ["5", "6", "8"]
	},
	{
		"question": "What is the largest ocean on Earth?",
		"correct": "Pacific Ocean",
		"incorrect": ["Atlantic Ocean", "Indian Ocean", "Arctic Ocean"]
	},
	{
		"question": "In what year did the Titanic sink?",
		"correct": "1912",
		"incorrect": ["1905", "1918", "1925"]
	},
	{
		"question": "Which gas do plants use for photosynthesis?",
		"correct": "Carbon Dioxide",
		"incorrect": ["Oxygen", "Nitrogen", "Hydrogen"]
	},
	{
		"question": "What is the square root of 64?",
		"correct": "8",
		"incorrect": ["6", "7", "9"]
	},
	{
		"question": "Who painted the Mona Lisa?",
		"correct": "Leonardo da Vinci",
		"incorrect": ["Vincent van Gogh", "Pablo Picasso", "Michelangelo"]
	},
	{
		"question": "Which language is primarily spoken in Brazil?",
		"correct": "Portuguese",
		"incorrect": ["Spanish", "French", "English"]
	},
	{
		"question": "What is the main ingredient in guacamole?",
		"correct": "Avocado",
		"incorrect": ["Cucumber", "Zucchini", "Green Peas"]
	}
]

func _ready():
	randomize()
	api_key = load_api_key()

	# dynamically create and hook up HTTPRequest
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func load_api_key() -> String:
	const PATH = "res://openai_key.txt"
	if FileAccess.file_exists(PATH):
		var f = FileAccess.open(PATH, FileAccess.READ)
		return f.get_line().strip_edges()
	push_error("API key file not found at %s" % PATH)
	return ""

func generate_trivia(callback: Callable, difficulty: String) -> void:
	if is_requesting:
		push_error("Trivia request already in progress!")
		return
	
	is_requesting = true
	on_trivia_ready = callback

	if http_request == null:
		push_error("HTTPRequest not initialized!")
		_use_fallback_trivia()
		return

	var url = "https://api.openai.com/v1/chat/completions"
	var headers = ["Content-Type: application/json", "Authorization: Bearer %s" % api_key]
	var prompt = "Give me one %s difficulty multiple-choice trivia question with 1 correct answer and 3 incorrect answers on a randomly chosen topic (e.g. history, geography, literature, sports, pop culture, science, art). Format as JSON with keys 'question','correct','incorrect'." % difficulty
	var body = { "model":"gpt-4.1", 
					"messages":[{"role":"system","content":"You are a trivia generator."},{"role":"user","content":prompt}],
					"temperature":0.7}
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		push_error("Failed to send request: %s" % err)
		is_requesting = false
		_use_fallback_trivia()

func _on_request_completed(result, code, headers, body):
	#print("Request completed with code: ", code)
	is_requesting = false  # allow next request
	
	var txt = body.get_string_from_utf8()
	#print("Raw body response:\n", body.get_string_from_utf8())

	if code == 200:
		var parsed = JSON.parse_string(txt)
		if parsed and parsed.has("choices") and parsed["choices"].size() > 0:
			var content = parsed["choices"][0]["message"]["content"].strip_edges()
			# strip markdown fences if present…
			if content.begins_with("```"):
				var nl = content.find("\n")
				content = content.substr(nl+1, content.length())
				if content.ends_with("```"):
					content = content.substr(0, content.length()-3)
				content = content.strip_edges()
			#print("Parsed trivia content: ", content)
			
			var d = JSON.parse_string(content)
			if d is Dictionary and d.has("question") and d.has("correct") and d.has("incorrect"):
				on_trivia_ready.call(d)
				return
			else:
				push_error("Parsed trivia was not a valid dictionary or missing keys:\n%s" % content)
				_use_fallback_trivia()
				return
	else:
		push_error("HTTP error %d: %s" % [code, txt])
		_use_fallback_trivia()

func _use_fallback_trivia():
	if fallback_trivia.size() > 0:
		on_trivia_ready.call(fallback_trivia[randi()%fallback_trivia.size()])
	else:
		push_error("No fallback trivia left.")
		on_trivia_ready.call({ "question":"Unavailable","correct":"","incorrect":["","",""] })
