extends Node
class_name RiddleGenerator

@onready var http_request: HTTPRequest = HTTPRequest.new() # node to send API calls
var api_key: String # loads api from secret file
var chosen_number: int # number need riddle for

# callback function, argument to other function
# called once API/fallback ready
var on_riddle_ready: Callable = func(_riddle: String) -> void: pass

# if chatgpt fails, get riddle from this dictionary
# used if no internet connection
var fallback_riddles = {
	1: ["Not zero, but the start of all, I rise alone, both short and tall.", 
	"When you’re all by yourself, how many people are there?"],
	2: ["When one has company, I arrive— A perfect count when friends survive.", 
	"If you see a pair of eyes, how many are looking at you?"],
	3: ["I’m how many strikes it takes to get out in baseball.", 
	"How many sides does a triangle have?"],
	4: ["Most animals with hooves leave this many tracks.", 
	"I'm lucky to find, with leaves not three but more. Count them all — what number’s in store?"],
	5: ["If you give someone a high five, how many fingers touch?", 
	"This is how many senses you’d use to explore a new place."],
	6: ["How many eggs are in half a dozen?", "I’m what you get when you add two threes."],
	7: ["Snow White had this many dwarfs.", "This is how many days it takes for the same day to return."],
	8: ["How many legs does a spider have?", "An octopus can grab with how many arms?"],
	9: ["Multiply three by three and you’ll land on me.", "I come just before double digits begin."],
	10: ["Count your fingers—how many are there in total?", 
	"This is how many pins are set up in a bowling game."],
	11: ["You knock on every door down one side of the street. There are five houses on your left 
	and five on your right, but one house is at the very end, all by itself. How many doors did you knock on?", 
	"One soccer team walks onto the field, including the goalie. How many players are ready to play?"],
	12: ["There are this many months in a year.", 
	"If every egg in a carton is a different color, how many eggs are there?"],
	13: ["Some people avoid me on Fridays.", "I follow twelve but don’t quite feel lucky."],
	14: ["You open a calendar to February and see a tiny heart drawn on a day that’s famous for 
	cards, candy, and secret admirers. What day is it?", 
	"Between unlucky and halfway through the month, I wait with chocolates and notes. What number am I?"],
	15: ["How many minutes are in a quarter of an hour?", 
	"If you invite five friends and they each bring two more, how many people show up?"],
	16: ["How many socks are in your drawer if you have four neat pairs?", 
	"A spider weaves two webs, each with eight lines—how many strands?"],
	17: ["I’m a tricky prime between sweet sixteen and legal voting age.", "She opened the final page of her diary. 
	The entry started: “One year ago today, I turned sweet sixteen…” What birthday is she writing about now?"],
	18: ["This is how old you have to be to vote in many places.", "The last page of the teen magazine says: 
		“Next issue: Adulthood begins!” What’s the age on that cover?"],
	19: ["This is how many candles are on the cake just one year before twenty.", 
	"A poem has 20 lines. You read all but the last. How many did you read?"],
	20: ["You open an old time capsule labeled “Class of 2000.” Inside is a note that says: “See you in two decades.” 
	What year is it?", "You’re at a masquerade. The host wears a pin that says “Vision is perfect tonight.” 
	What number is the joke referring to?"],
	21: ["This number wins in blackjack.", "You're old enough now to legally drink."],
	22: ["You’re watching a spy movie. The agent’s codename is “Double Two.” What number is stamped on his ID badge?", 
	"The game show host spins the wheel. It lands between 21 and 23, right on the lucky spot. What number did it hit?"],
	23: ["A delivery arrives with a label reading “Apartment: second building, third door from the right.” 
	You trace the path exactly. What number is on the apartment?", "What is the sum of 16 and 17?"],
	24: ["If you watch eight 3-hour movies in a row, how many hours pass?", 
	"A full day has this many hours to dream, play, and rest."],
	25: ["I’m one quarter of a hundred.", 
	"You find a box labeled “quarter-century memories.” How many years are inside?"],
	26: ["This is how many letters are in the alphabet.", "The unlucky number doubled makes me."],
	27: ["I’m what you get when you cube three.", "I am a cube of a number between 1 and 5. What number am I?"],
	28: ["A non-leap year February has this many days.", 
	"You bake four trays of cookies with seven on each. How many cookies cool on the counter?"],
	29: ["Just one more and this month would have reached thirty. What day is it now?", 
	"The calendar shows February, and this year, it’s acting odd. There’s one extra day—sneaky and rare. What day is it?"],
	30: ["The candles are lit, the cake is tall, and someone says, “Welcome to your thirties.” What birthday are they celebrating?", 
	"What is half of an hour?"],
}

func _ready():
	randomize() # initialize random number generator
	api_key = load_api_key() # load API key from secret/local file
	add_child(http_request) # set up HTTPRequest, so able to send requests
	
	# connect request_completed from http to function, so called when HTTP request finished
	http_request.request_completed.connect(_on_request_completed)

# load API key from txt file
func load_api_key() -> String:
	const PATH = "res://openai_key.txt"
	if FileAccess.file_exists(PATH): # check if exists
		var file := FileAccess.open(PATH, FileAccess.READ) # Open file
		return file.get_line().strip_edges() # get 1st line + remove edge spaces
	else:
		push_error("API key file not found at %s" % PATH)
		return ""

# generate riddle for specific number
# callable = function recieves final riddle string
func generate_riddle_for_number(number: int, callback: Callable, difficulty: String) -> void:
	on_riddle_ready = callback # store callback function
	chosen_number = number # store number making riddle for
	
	# prepare OpenAI endpoint + header
	var url := "https://api.openai.com/v1/chat/completions" # API endpoint to send request
	var headers := [
		"Content-Type: application/json", # JSON data
		"Authorization: Bearer %s" % api_key, # use API key
	]
	
	var prompt: String
	
	# make prompt based on difficulty
	match difficulty:
		"easy":
			prompt = "Give me a very simple, clever riddle whose answer is the number %d. 
			Don't use prime numbers in the riddle. It doesn't need to use math in the riddle. Use a 
			statement that only fits this number exactly; do not reference ranges or properties 
			shared by other numbers. Keep it 1 sentence and on one line." % number
		"medium":
			prompt = "Give me a clever riddle whose answer is the number %d. Don't use prime numbers 
			in the riddle. It doesn't need to use math in the riddle. Ensure the clue is specific 
			so no other number satisfies it; do not mention ranges. Keep it 1 sentence and on one line." % number
		"hard":
			prompt = "Give me a tricky and challenging riddle whose answer is the number %d. Don't use prime numbers 
			in the riddle. It doesn't need to use math in the riddle. Include a unique property that 
			only applies to this number; avoid using ranges or ambiguous clues. Keep it 1 sentence and on one line." % number
		_: # default prompt if no difficulty found
			prompt = "Give me a short, clever riddle whose answer is the number %d. Make sure no other number fits; 
			do not use ranges. Keep it 1 sentence and on one line." % number
	
	# construct JSON body
	var body := {
		"model": "gpt-4.1",
		"messages": [
			{ "role": "system", "content": "You are a riddle generator for a logic-based adventure game." },
			{ "role": "user", "content": prompt }
		],
		"temperature": 0.8 # randomness
	}
	
	var json := JSON.stringify(body) # convert dictionary to JSON
	
	# Send the HTTP POST request
	# fails -> fallback to a local riddle
	var error := http_request.request(url, headers, HTTPClient.METHOD_POST, json)
	if error != OK:
		push_error("Failed to send request to OpenAI: %s" % error)
		_use_fallback_riddle()

# called when HTTP request finished
func _on_request_completed(result: HTTPRequest.Result, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Request completed.")
	print("HTTP Result Enum:", result)
	print("HTTP Response Code:", response_code)

	var body_text := body.get_string_from_utf8() # convert to string for parsing
	#print("Raw body:", body_text)

	if response_code == 200: # 200 = success
		var parsed = JSON.parse_string(body_text) # parse
		
		# extract content
		if parsed and parsed.has("choices") and parsed["choices"].size() > 0:
			var riddle: String = parsed["choices"][0]["message"]["content"]
			print("Riddle from ChatGPT:", riddle)
			on_riddle_ready.call(riddle.strip_edges()) # call callback
			return
		else:
			push_error("ChatGPT response format unexpected.")
	else:
		push_error("HTTP error %d: %s" % [response_code, body_text])
	
	_use_fallback_riddle() # anything went wrong -> use a fallback riddle

# select fallback from dictionary above
func _use_fallback_riddle() -> void:
	if fallback_riddles.has(chosen_number):
		var options = fallback_riddles[chosen_number]
		var pick = options[randi() % options.size()] # pick random riddle from array
		on_riddle_ready.call(pick)
	else:
		push_error("Failed to generate riddle.")
		on_riddle_ready.call("Failed to generate riddle.")
