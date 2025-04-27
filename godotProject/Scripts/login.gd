extends Panel

signal LoginUser(username, password)
signal CreateUser(username, password)

@export var CreateUserWindow : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cancel_button_button_down() -> void:
	queue_free()

func _on_login_button_button_down() -> void:
	LoginUser.emit($VBoxContainer/HBoxContainer/Username.text, $VBoxContainer/HBoxContainer2/Password.text)

func _on_to_sign_up_button_button_down() -> void:
	var createUserWindow = CreateUserWindow.instantiate()
	add_child(createUserWindow) 
	createUserWindow.CreateUser.connect()
	
func createUser(username, password):
	CreateUser.emit(username, password)
