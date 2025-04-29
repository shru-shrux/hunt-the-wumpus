extends Panel

@onready var username_field = $VBoxContainer/Username/TextEdit
@onready var password_field = $VBoxContainer/Password/TextEdit
@onready var password_check_field = $VBoxContainer/Password/TextEdit
@onready var error_label = $Error
var login_manager = LoginManager

func _ready():
	LoginManager.load_accounts()
	$SignInButton.pressed.connect(_on_sign_in_button_button_down)
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))
	visible = false

func _on_sign_in_button_button_down():
	var user = username_field.text.strip_edges()
	var password = password_field.text
	var password2 = password_check_field	.text
	
	if user.is_empty():
		error_label.text = "No username entered."
		return
	if password.is_empty():
		error_label.text = "No password entered."
		return
	if password2.is_empty():
		error_label.text = "Please confirm your password."
		return
	if password != password2:
		error_label.text = "Passwords do not match."
		return
	if login_manager.signup(user, password):
		error_label.text = "Account created! You are logged in."
		
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		error_label.text = "Username already taken."

func _on_cancel_button_2_button_down():
	get_parent().call_deferred("close_panels")
	
func _on_to_login_button_button_down():
	get_parent().call_deferred("show_login")

func _on_visibility_changed():
	if visible:
		error_label.text = ""
		username_field.text = ""
		password_field.text = ""
		password_check_field.text = ""
