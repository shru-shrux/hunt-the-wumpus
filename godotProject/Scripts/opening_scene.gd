extends Control

@onready var login_panel = preload("res://Scenes/login_signup/login.tscn").instantiate()
@onready var signup_panel = preload("res://Scenes/login_signup/sign_up.tscn").instantiate()

# add login/signup and hide to start
func _ready():
	add_child(login_panel)
	add_child(signup_panel)
	login_panel.visible = false
	signup_panel.visible = false

# switch to login
func _on_login_panel_button_button_down():
	login_panel.visible = true
	signup_panel.visible = false

# switch to signup
func _on_sign_up_panel_button_button_down():
	signup_panel.visible = true
	login_panel.visible = false

# fully quit game
func _on_quit_button_button_up():
	get_tree().quit()

# called by panels to switch
func show_login():
	login_panel.visible = true
	signup_panel.visible = false

# show signup
func show_signup():
	signup_panel.visible = true
	login_panel.visible = false

# close both
func close_panels():
	signup_panel.visible = false
	login_panel.visible = false
