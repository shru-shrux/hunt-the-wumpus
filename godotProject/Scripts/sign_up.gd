extends Panel

@onready var username_field = $VBoxContainer/Username/TextEdit
@onready var password_field = $VBoxContainer/Password/TextEdit
@onready var password_check_field = $VBoxContainer/Password/TextEdit
@onready var error_label = $Error
var login_manager = LoginManager

func _ready():
	$SignInButton.pressed.connect(_on_sign_in_button_button_down)

func _on_sign_in_button_button_down():
	var user = username_field.text.strip_edges()
	var password = password_field.text
	var password2 = password_check_field.text
	if password != password2:
		error_label.text = "Passwords do not match."
		return
	if login_manager.signup(user, password):
		error_label.text = "Account created! You are logged in."
		# proceed to main menu
	else:
		error_label.text = "Username already taken."

func _on_cancel_button_2_button_down():
	get_parent().call_deferred("close_panels")
	
func _on_to_login_button_button_down():
	# Tell parent OpeningScene to show login
	get_parent().call_deferred("show_login")
	visible = false
