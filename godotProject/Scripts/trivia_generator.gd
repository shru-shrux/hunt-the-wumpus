extends Node
class_name TriviaGenerator

var http_request: HTTPRequest
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
	on_trivia_ready = callback

	if http_request == null:
		push_error("HTTPRequest not initialized!")
		_use_fallback_trivia()
		return

	var url = "https://api.openai.com/v1/chat/completions"
	var headers = ["Content-Type: application/json", "Authorization: Bearer %s" % api_key]
	var prompt = "Give me one %s difficulty multiple-choice trivia question with 1 correct answer and 3 incorrect answers. Format as JSON with keys 'question','correct','incorrect'." % difficulty
	var body = { "model":"gpt-3.5-turbo", 
					"messages":[{"role":"system","content":"You are a trivia generator."},{"role":"user","content":prompt}],
					"temperature":0.7 }
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		push_error("Failed to send request: %s" % err)
		_use_fallback_trivia()

func _on_request_completed(result, code, headers, body):
	var txt = body.get_string_from_utf8()
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
			var d = JSON.parse_string(content)
			if typeof(d) == TYPE_DICTIONARY and d.has("question") and d.has("correct") and d.has("incorrect"):
				return on_trivia_ready.call(d)
		push_error("Invalid trivia format or missing keys.")
	else:
		push_error("HTTP error %d: %s" % [code, txt])
		_use_fallback_trivia()

func _use_fallback_trivia():
	if fallback_trivia.size() > 0:
		on_trivia_ready.call(fallback_trivia[randi()%fallback_trivia.size()])
	else:
		push_error("No fallback trivia left.")
		on_trivia_ready.call({ "question":"Unavailable","correct":"","incorrect":["","",""] })
