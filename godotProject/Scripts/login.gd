extends Panel

@onready var username_field = $VBoxContainer/HBoxContainer/Username
@onready var password_field = $VBoxContainer/HBoxContainer2/Password
@onready var error_label = $Error
var login_manager = LoginManager

func _ready():
	$LoginButton.pressed.connect(_on_login_button_button_down)

func _on_login_button_button_down():
	var user = username_field.text.strip_edges()
	var password = password_field.text
	if login_manager.login(user, password):
		error_label.text = "Login successful!"
		# proceed to main menu
	else:
		error_label.text = "Incorrect password."

func _on_cancel_button_button_down() -> void:
	get_parent().call_deferred("close_panels")
	#visible = false

func _on_to_sign_up_button_button_down():
	# Tell the parent OpeningScene to show signup
	get_parent().call_deferred("show_signup")
	#visible = false
