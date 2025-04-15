extends Control

@onready var login_form = $CenterContainer/MainContaienr/LoginForm
@onready var signup_form = $CenterContainer/MainContaienr/SignUpForm

func _on_to_sign_up_pressed():
	login_form.visible = false
	signup_form.visible = true

func _on_to_login_pressed():
	signup_form.visible = false
	login_form.visible = true

func _on_quit_pressed():
	get_tree().quit()
