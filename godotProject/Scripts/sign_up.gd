extends Panel

@onready var username_field = $VBoxContainer/Username/TextEdit
@onready var password_field = $VBoxContainer/Password/TextEdit
@onready var password_check_field = $VBoxContainer/ConfirmPassword/TextEdit
@onready var error_label = $Error
var login_manager = LoginManager

func _ready():
	LoginManager.load_accounts() # load accounts
	$SignInButton.pressed.connect(_on_sign_in_button_button_down) # connect button to function
	
	connect("visibility_changed", Callable(self, "_on_visibility_changed")) # connect visibility to function
	visible = false # start hidden

# if enter is pressed it submits
func _input(event: InputEvent) -> void:
	if not visible: # if hidden, don't do anything
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			get_viewport().set_input_as_handled()  # prevents Enter from going into TextEdits
			_on_sign_in_button_button_down() # go to sign up function

# when sign up button or enter pressed
func _on_sign_in_button_button_down():
	var user = username_field.text.strip_edges()
	var password = password_field.text
	var password2 = password_check_field.text

	# validate entered information 
	if user.is_empty():
		error_label.text = "No username entered."
		return
	if password.is_empty():
		error_label.text = "No password entered."
		return
	if password.length() < 6:
		error_label.text = "Password must be at least 6 characters long."
		return
	if password2.is_empty():
		error_label.text = "Please confirm your password."
		return
	if password != password2:
		error_label.text = "Passwords do not match."
		return
	if " " in password:
		error_label.text = "Password cannot contain spaces."
		return
	if login_manager.signup(user, password): # creates account
		error_label.text = "Account created! You are logged in."
		get_tree().change_scene_to_file("res://Scenes/backstory.tscn") # start game
	else:
		error_label.text = "Username already taken."

# close signup - through opening scene
func _on_cancel_button_2_button_down():
	get_parent().call_deferred("close_panels")

# go to login - opening scene
func _on_to_login_button_button_down():
	get_parent().call_deferred("show_login")

# clear fields when hidden and showed again
func _on_visibility_changed():
	if visible:
		error_label.text = ""
		username_field.text = ""
		password_field.text = ""
		password_check_field.text = ""
