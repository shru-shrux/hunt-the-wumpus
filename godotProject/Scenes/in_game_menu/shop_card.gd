extends Panel

# export variables for different items
@export var itemImage: Texture
@export var itemName: String
@export var itemPrice: String
@export var infomationPopup: String
@export var boughtPopup: String


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
	$PopupPanel2/MarginContainer/HBoxContainer/BoughtMessage.text = boughtPopup

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
			print("arrow added")
		"Anti-bat Potion":
			# TODO add minigame here
			player.changeAntiBat(true)
			print("anti bat added")
		"Secrets":
			print("secret message")
			# options for the secret: room number where a bat lives, where a pit is, if wumpus is 
			# within two rooms of you, where the wumpus is, or the room number you currently are in
			# or answer to a trivia you have already asked	
			
			# use random number generator to choose a number that corresponds to a secret
			var rng = RandomNumberGenerator.new()
			#var random_secret_num = rng.randi_range(0, 4)
			var random_secret_num = 3
			
			if random_secret_num == 0:
				var batList = GameData.batList
				var random_index = randi() % batList.size()
				boughtPopup = "Your secret:\nBats live in room " + str(batList[random_index].currentCaveNumber)
			elif random_secret_num == 1:
				var pitList = GameData.pitList
				var random_index = randi() % pitList.size()
				boughtPopup = "Your secret:\nA pit is located in room " + str(pitList[random_index].currentCaveNumber)
			elif random_secret_num == 2:
				var start_idx = PlayerData.currentRoomNumber
				var goal_idx = WumpusData.currentRoomNumber
				var path = GameData.bfs_shortest_path(start_idx, goal_idx, GameData.caveList)

				if path.size() > 2:
					boughtPopup = "Your secret:\nYou are more than 2 caves away from the Wumpus"
				else:
					boughtPopup = "Your secret:\nYou are within 2 caves of the Wumpus"
			elif random_secret_num == 3:
				boughtPopup = "Your secret:\nThe Wumpus is currently in room " + str(WumpusData.currentRoomNumber)
			elif random_secret_num == 4:
				boughtPopup = "Your secret:\nYou are currently in room " + str(PlayerData.currentRoomNumber)
			print("secret added")
			
	# show bought item message
	$PopupPanel2/MarginContainer/HBoxContainer/BoughtMessage.text = boughtPopup
	print("pop up changed")
	$PopupPanel2.popup_centered()

# close pop up of bought item message
func _on_bought_close_button_pressed() -> void:
	$PopupPanel2.hide()


func _on_info_button_mouse_entered() -> void:
	$PopupPanel.popup_centered()


func _on_info_button_mouse_exited() -> void:
	$PopupPanel.hide()
