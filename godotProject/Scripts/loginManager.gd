extends Node
class_name loginManager

var account_data: Dictionary = {}
var current_user: String = ""

func _ready():
	#clear_user_directory()
	load_accounts()

func load_accounts():
	var path = "user://accounts.save"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		account_data = file.get_var()
		file.close()
	else:
		account_data = {}

	print("Loaded accounts: ", account_data)

func save_accounts():
	var file = FileAccess.open("user://accounts.save", FileAccess.WRITE)
	file.store_var(account_data)
	file.close()

# Returns true if login successful or new account created.
func login(username: String, password: String) -> bool:
	if username in account_data:
		if account_data[username].password == password:
			current_user = username
			return true
		return false
	return false

# Returns false if username taken, otherwise creates account.
func signup(username: String, password: String) -> bool:
	print("Attempting signup for:", username)
	if username in account_data:
		return false
		
	account_data[username] = {
		"password": password,
		"gold": 0,
		"achievements": [],
		"settings": {}
	}
	
	current_user = username
	save_accounts()
	print("Signup successful. Account data now:", account_data)
	
	return true
	
func get_user_data() -> Dictionary:
	if current_user in account_data:
		return account_data[current_user]
	return {}
	
func update_user_data(new_data: Dictionary):
	if current_user in account_data:
		for key in new_data.keys():
			account_data[current_user][key] = new_data[key]
		save_accounts()

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
