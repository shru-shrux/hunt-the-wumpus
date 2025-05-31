extends Node
class_name loginManager

var account_data: Dictionary = {} # hold all user account
var current_user: String = "" # username

func _ready():
	#clear_user_directory()
	load_accounts() 

func load_accounts():
	# Attempt to load the "accounts.save" file from the user data folder
	var path = "user://accounts.save"
	if FileAccess.file_exists(path):
		# If the file exists, open it for reading and deserialize the Dictionary
		var file = FileAccess.open(path, FileAccess.READ)
		account_data = file.get_var()
		file.close()
	else:
		# If the file doesn't exist, start with an empty Dictionary
		account_data = {}
	
	# print for debugging
	#print("Loaded accounts: ", account_data)

func save_accounts():
	# Open/create the "accounts.save" file for user data folder
	var file = FileAccess.open("user://accounts.save", FileAccess.WRITE)
	
	# serialize the account_data dictionary and write it to disk
	file.store_var(account_data)
	file.close()

# returns true if login successful or new account created
func login(username: String, password: String) -> bool:
	if username in account_data: # check if username exists
		if account_data[username].password == password: # check if correct password
			current_user = username # set username
			return true
		return false # password didn't match
	return false # username not found

# returns false if username taken, otherwise creates account
func signup(username: String, password: String) -> bool:
	print("Attempting signup for:", username)
	
	# username exits -> fails
	if username in account_data:
		return false
	
	# new dictionary w/ default values
	account_data[username] = {
		"username": username,
		"password": password,
		"gold": 0,
		"achievements": {
			"score": 0,
			"wins": 0,
			"trivia": 0,
			"caves": 0
		},
		"inventory": [],
		"settings": {},
		"high-score": 0
	}
	
	current_user = username # set username
	save_accounts() # add to disk
	print("Signup successful. Account data now:", account_data)
	
	return true

# returns the dictionary of data of current user
# if no user is logged in or the username is not found, returns an empty dictionary
func get_user_data() -> Dictionary:
	if current_user in account_data:
		print("user found")
		return account_data[current_user]
	print("user not found")
	return {}

# updates the stored data for the current user with keys/values from new_data
# saves all accounts to disk
func update_user_data(new_data: Dictionary):
	if current_user in account_data:
		for key in new_data.keys():
			account_data[current_user][key] = new_data[key]
		save_accounts()

# completely clears the entire user:// directory (all files in it).
# this deletes EVERY file in user://, including accounts.save
# CAREFUL USING
func clear_user_directory():
	var dir = DirAccess.open("user://")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				dir.remove(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
