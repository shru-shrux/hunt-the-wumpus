extends Panel

@export var itemImage: Texture
@export var itemName: String
@export var itemPrice: String
@export var infomationPopup: String

var player : Node2D

func set_player(p : Node2D):
	player = p
	print("Player set in ShopCard: ", player)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/VBoxContainer/HBoxContainer2/TextureRect.texture = itemImage
	$MarginContainer/VBoxContainer/HBoxContainer/Label.text = itemName
	$MarginContainer/VBoxContainer/PanelContainer/BuyButton.text = itemPrice
	$PopupPanel/MarginContainer/HBoxContainer/Label.text = infomationPopup


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_buy_button_pressed() -> void:
	#var shop = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	#var player = shop.player
	if player == null:
		print("ERROR: No player assigned to ShopCard")
		return
		
	var price = int(itemPrice)
	
	if player.goldCount < price:
		print("Not enough gold")
		return
	
	player.goldChange(-(price))
	match itemName:
		"arrows":
			player.arrowChange(1)
		"anti_bat":
			player.changeAntiBat(true)
		"secret":
			print("secret message")


func _on_info_button_pressed() -> void:
	$PopupPanel.popup_centered()


func _on_close_button_pressed() -> void:
	$PopupPanel.hide()
