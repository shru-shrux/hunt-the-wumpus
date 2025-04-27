extends Node2D


#to do: figure out how to know which cave the player is standing
#in the area2d for. also figure out how to display the number cave
#the player is standing close to on the label. Also have to
#intialize the cave number above each door









# the amount of gold the player gets for entering the cave
var roomGoldAmount = 0
# the caves the player can go into from this one
var connectingCaves = []
# the answer for the riddle and the cave the player 
# wants to go into
var bestOption = 0

# specialty caves that make it different than default

# will be a bat cave
var hasBat = false
# will be a wumpus cave
var hasWumpus = false
# will have a bottomless pit
var hasPit = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# if game control sets this to bat cave start minigame
	if hasBat:
		pass
	
	# if game control sets this to wumpus cave start minigame
	if hasWumpus:
		pass
	
	# if game control sets this to pit cave start minigame
	if hasPit:
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func changeRooms()
