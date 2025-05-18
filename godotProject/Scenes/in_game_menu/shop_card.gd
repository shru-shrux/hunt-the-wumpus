extends Panel

@export var itemImage: Texture
@export var itemName: String
@export var itemPrice: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/VBoxContainer/HBoxContainer2/TextureRect.texture = itemImage
	$MarginContainer/VBoxContainer/HBoxContainer/Label.text = itemName
	$MarginContainer/VBoxContainer/PanelContainer/Button.text = itemPrice


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
