extends Panel

# export variables for different items
@export var itemImage: Texture
@export var itemName: String
@export var itemPrice: String
@export var infomationPopup: String
@export var boughtPopup: String

const MinigameScene = preload("res://Scenes/minigame/minigame.tscn")
var player : Node2D

# set player for each card
func set_player(p : Node2D):
	player = p
	print("Player set in ShopCard: ", player)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# update the labels
	$MarginContainer/VBoxContainer/HBoxContainer2/TextureRect.texture = itemImage
	$MarginContainer/VBoxContainer/HBoxContainer/Label.text = itemName
	$MarginContainer/VBoxContainer/PanelContainer/BuyButton.text = itemPrice
	$PopupPanel/MarginContainer/Label.text = infomationPopup
	$PopupPanel2/MarginContainer/HBoxContainer/BoughtMessage.text = boughtPopup
	$MarginContainer/VBoxContainer/HBoxContainer/InfoButton.disabled = true
	$PopupPanel.resize_to_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_buy_button_pressed() -> void:
	if player == null:
		print("ERROR: No player assigned to ShopCard")
		return
		
	var price = int(itemPrice)
	
	# print not enough gold message is gold count less than price of item
	if player.goldCount < price:
		print("Not enough gold")
		var notEnoughGold = "Not enough gold"
		$PopupPanel2/MarginContainer/HBoxContainer/BoughtMessage.text = notEnoughGold
		$PopupPanel2.popup_centered()
		return
	
	# call gold change for player after buying item
	player.goldChange(-(price))
	# match items and call specific item actions
	match itemName:
		"Arrows":
			player.arrowChange(1)
		"Anti-bat Potion":
			player.changeAntiBat(true)
		"secret":
			print("secret message")
			# options for the secret: room number where a bat lives, where a pit is, if wumpus is 
			# within two rooms of you, where the wumpus is, or the room number you currently are in
			# or answer to a trivia you have already asked	
			
			# use random number generator to choose a number that corresponds to a secret
			var rng = RandomNumberGenerator.new()
			var random_secret_num = rng.randi_range(0, 4)
			if random_secret_num == 0:
				boughtPopup = "Bats live in room " # set this to bat room number
			elif random_secret_num == 1:
				boughtPopup = "A pit is located in room " # set this to pit room number
			elif random_secret_num == 2:
				# TODO make this determine if wumpus is within two rooms of you
				# use bfs to see if it is within two
				var wumpusWithinTwo = false
			elif random_secret_num == 3:
				boughtPopup = "The Wumpus is currently in room " + WumpusData.currentRoomNumber
			elif random_secret_num == 4:
				boughtPopup = "You are currently in room " + PlayerData.currentRoomNumber
			
	# show bought item message
	$PopupPanel2/MarginContainer/HBoxContainer/BoughtMessage.text = boughtPopup
	$PopupPanel2.popup_centered()

# close pop up of bought item message
func _on_bought_close_button_pressed() -> void:
	$PopupPanel2.hide()


func _on_info_button_mouse_entered() -> void:
	$PopupPanel.popup_centered()


func _on_info_button_mouse_exited() -> void:
	$PopupPanel.hide()
