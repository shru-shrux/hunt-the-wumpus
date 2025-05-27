extends Node
class_name TriviaGenerator

@onready var http_request: HTTPRequest = HTTPRequest.new()
var api_key: String
var on_trivia_ready: Callable = func(_data: Dictionary) -> void: pass

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
	}
]

func _ready():
	randomize()
	api_key = load_api_key()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func load_api_key() -> String:
	const PATH = "res://openai_key.txt"
	if FileAccess.file_exists(PATH):
		var file := FileAccess.open(PATH, FileAccess.READ)
		return file.get_line().strip_edges()
	else:
		push_error("API key file not found at %s" % PATH)
		return ""

func generate_trivia(callback: Callable, difficulty: String) -> void:
	on_trivia_ready = callback

	var url := "https://api.openai.com/v1/chat/completions"
	var headers := [
		"Content-Type: application/json",
		"Authorization: Bearer %s" % api_key,
	]

	var prompt := "Give me one %s difficulty multiple-choice trivia question with 1 correct answer and 3 incorrect answers. Format the response as JSON with keys: 'question', 'correct', and 'incorrect' (as an array of 3)." % difficulty

	var body := {
		"model": "gpt-3.5-turbo",
		"messages": [
			{ "role": "system", "content": "You are a trivia generator for a quiz game." },
			{ "role": "user", "content": prompt }
		],
		"temperature": 0.7
	}

	var json := JSON.stringify(body)
	var error := http_request.request(url, headers, HTTPClient.METHOD_POST, json)

	if error != OK:
		push_error("Failed to send request to OpenAI: %s" % error)
		_use_fallback_trivia()

func _on_request_completed(result: HTTPRequest.Result, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var body_text := body.get_string_from_utf8()
	print("📄 Raw body:", body_text)

	if response_code == 200:
		var parsed = JSON.parse_string(body_text)
		if parsed and parsed.has("choices") and parsed["choices"].size() > 0:
			var content = parsed["choices"][0]["message"]["content"]
			content = content.strip_edges()
			
			# Strip triple backticks with optional language specifier (like ```json)
			if content.begins_with("```"):
				# Find first newline after ```
				var first_newline_idx = content.find("\n")
				if first_newline_idx != -1:
					# Remove the first line (```json or just ```)
					content = content.substr(first_newline_idx + 1, content.length())
				# Remove trailing ```
				if content.ends_with("```"):
					content = content.substr(0, content.length() - 3)
				
				content = content.strip_edges()
			
			var trivia_json = JSON.parse_string(content)
			if typeof(trivia_json) == TYPE_DICTIONARY and trivia_json.has("question") and trivia_json.has("correct") and trivia_json.has("incorrect"):
				on_trivia_ready.call(trivia_json)
				return
			else:
				push_error("Trivia format invalid or missing keys.")
		else:
			push_error("ChatGPT response missing expected structure.")
	else:
		push_error("HTTP error %d: %s" % [response_code, body_text])

	_use_fallback_trivia()

func _use_fallback_trivia() -> void:
	if fallback_trivia.size() > 0:
		var pick = fallback_trivia[randi() % fallback_trivia.size()]
		on_trivia_ready.call(pick)
	else:
		push_error("No fallback trivia available.")
		on_trivia_ready.call({
			"question": "Trivia unavailable.",
			"correct": "",
			"incorrect": ["", "", ""]
		})
