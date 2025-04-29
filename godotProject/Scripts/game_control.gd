extends Node2D

var caveList: Array[Cave] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_caves()
	assign_special_caves()

func create_caves():
	for i in range(30):
		var cave = Cave.new()
		cave.currentCaveNumber = i
		caveList.append(cave)

func assign_special_caves():
	var available_caves = caveList
	available_caves.shuffle()
	
	for i in range(2):
		available_caves[i].hasBat = true
	
	for i in range(2, 4):
		available_caves[i].hasPit = true

func distribute_gold(total_gold: int):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
