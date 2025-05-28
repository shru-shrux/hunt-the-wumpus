extends Panel

@onready var username_field = $VBoxContainer/HBoxContainer/Username
@onready var password_field = $VBoxContainer/HBoxContainer2/Password
@onready var error_label = $Error
var login_manager = LoginManager

func _ready():
	LoginManager.load_accounts()
	$LoginButton.pressed.connect(_on_login_button_button_down)
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))
	visible = false

func _on_login_button_button_down():
	var user = username_field.text.strip_edges()
	var password = password_field.text
	
	if user.is_empty():
		error_label.text = "No username entered."
		return
	if password.is_empty():
		error_label.text = "No password entered."
		return
	if not login_manager.account_data.has(user):
		error_label.text = "Username not found."
		return
	if login_manager.login(user, password):
		error_label.text = "Login successful!"
		# proceed to main menu
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		error_label.text = "Incorrect password."

# if enter is pressed it submits
func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			get_viewport().set_input_as_handled()  # Prevents Enter from going into TextEdits
			_on_login_button_button_down()

func _on_cancel_button_button_down() -> void:
	get_parent().call_deferred("close_panels")

func _on_to_sign_up_button_button_down():
	get_parent().call_deferred("show_signup")

func _on_visibility_changed():
	if visible:
		error_label.text = ""
		username_field.text = ""
		password_field.text = ""
