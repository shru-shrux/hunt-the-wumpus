extends Control

@onready var login_panel = preload("res://Scenes/login_signup/login.tscn").instantiate()
@onready var signup_panel = preload("res://Scenes/login_signup/sign_up.tscn").instantiate()

func _ready():
	add_child(login_panel)
	add_child(signup_panel)
	login_panel.visible = false
	signup_panel.visible = false

func _on_login_panel_button_button_down():
	login_panel.visible = true
	signup_panel.visible = false

func _on_sign_up_panel_button_button_down():
	signup_panel.visible = true
	login_panel.visible = false
	
# Called by panels to switch
func show_login():
	login_panel.visible = true
	signup_panel.visible = false

func show_signup():
	signup_panel.visible = true
	login_panel.visible = false

func close_panels():
	signup_panel.visible = false
	login_panel.visible = false
