extends Node
class_name RiddleGenerator

@onready var http_request: HTTPRequest = HTTPRequest.new() # class/node to send HTTP requests
var api_key: String
var on_riddle_ready: Callable = func(_riddle: String) -> void: pass # callback function, argument to other function
var chosen_number: int

# if chatgpt fails, get riddle from this dictionary
var fallback_riddles = {
	1: ["", ""],
	2: ["", ""],
	3: ["", ""],
}

func _ready():
	randomize() # initialize random number generator
	
	# Load API key
	api_key = load_api_key()

	# Set up HTTPRequest
	add_child(http_request)
	
	 # Connect request_completed from http to function, so called when HTTP request finished
	http_request.request_completed.connect(_on_request_completed)


func load_api_key() -> String:
	const PATH = "res://openai_key.txt"
	if FileAccess.file_exists(PATH): # Check if exists
		var file := FileAccess.open(PATH, FileAccess.READ) # Open file
		return file.get_line().strip_edges() # Get 1st line + remove edge spaces
	else:
		push_error("API key file not found at %s" % PATH)
		return ""
		

func generate_riddle_for_number(number: int, callback: Callable) -> void:
	on_riddle_ready = callback # store callback function
	
	chosen_number = number
	var url := "https://api.openai.com/v1/chat/completions" # API endpoint to send request
	var headers := [
		"Content-Type: application/json", # JSON data
		"Authorization: Bearer %s" % api_key, # use API key
	]

	var prompt := "Give me a short, clever riddle whose answer is the number %d. Keep it under 2 sentences." % number

	var body := {
		"model": "gpt-3.5-turbo",
		"messages": [
			{ "role": "system", "content": "You are a riddle generator for a logic-based adventure game." }, # from system
			{ "role": "user", "content": prompt } # from user
		],
		"temperature": 0.8 # randomness
	}

	var json := JSON.stringify(body) # convert to JSON
	var error := http_request.request(url, headers, HTTPClient.METHOD_POST, json) # POST to send HTTP request

	
	if error != OK:
		push_error("Failed to send request to OpenAI: %s" % error)
		_use_fallback_riddle()


func _on_request_completed(result: HTTPRequest.Result, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200: # successful
		var json_text: String = body.get_string_from_utf8() # convert to string
		var parsed = JSON.parse_string(json_text) # parse into dictionary
		if parsed.error == OK and parsed.result.has("choices") and parsed.result["choices"].size() > 0: # if parsed successful
			var riddle: String = parsed.result["choices"][0]["message"]["content"]
			on_riddle_ready.call(riddle.strip_edges())
			return
		else:
			push_error("ChatGPT API Error %d, using fallback." % response_code)
	else:
		push_error("ChatGPT API Error %d:\n%s" % [response_code, body.get_string_from_utf8()])
	
	_use_fallback_riddle()

func _use_fallback_riddle() -> void:
	if fallback_riddles.has(chosen_number):
		var options = fallback_riddles[chosen_number]
		var pick = options[randi() % options.size()] # pick random riddle from array
		on_riddle_ready.call(pick)
	else:
		push_error("Failed to generate riddle.")
		on_riddle_ready.call("Failed to generate riddle.")
