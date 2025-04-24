extends Panel

signal CreateUser(user, password)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sign_in_button_button_down() -> void:
	CreateUser.emit($VBoxContainer/Username/TextEdit, $VBoxContainer/Password/TextEdit)

func _on_cancel_button_2_button_down():
	queue_free()
