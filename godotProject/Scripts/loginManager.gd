extends Node
class_name loginManager

var account_data: Dictionary = {}

func _ready():
	clear_user_directory()
	load_accounts()

func load_accounts():
	var path = "user://accounts.save"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		account_data = file.get_var()
		file.close()
	else:
		account_data = {}

func save_accounts():
	var file = FileAccess.open("user://accounts.save", FileAccess.WRITE)
	file.store_var(account_data)
	file.close()

# Returns true if login successful or new account created.
func login(username: String, password: String) -> bool:
	if username in account_data:
		return account_data[username] == password
	else:
		return false

# Returns false if username taken, otherwise creates account.
func signup(username: String, password: String) -> bool:
	if username in account_data:
		return false
	account_data[username] = password
	save_accounts()
	return true

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
