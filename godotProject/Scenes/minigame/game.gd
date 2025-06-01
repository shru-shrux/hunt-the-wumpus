extends Node2D

#variables
@export var mob_scene: PackedScene #obstacle scene template
var time_remaining = 20
var active = false
var player: Node2D
signal game_finished #used in cave default for showing minigame
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Called every time enemy spawn timer times out. Inserts obstacle scene and resets timer wait time to a random num
#return: void
func _on_enemy_spawn_timeout() -> void:
	var mob = mob_scene.instantiate() #creates an obstacle scene in memory
	mob.initialize(500, Vector2(700, 110)) #set up speed and position
	add_child(mob) # add to scene tree
	
	$"enemy spawn".wait_time = randf_range(0.6, 1.5) #reset wait time to rand float between 0.6 to 1.5 sec next time it starts (timer is not on one shot)

#Called every time survival timer times out. decreases time remaining. If reaches 0, ends game with victory
#return: void
func _on_survival_timer_timeout() -> void:
	time_remaining -= 1
	$"../Label".text=str(time_remaining)
	if time_remaining == 0 and active:
		$"../victory".show()
		get_tree().paused = true
		await wait(1.0) #pause to display
		get_parent().get_parent().get_parent().get_node("CaveDefault").pickup = false #don't let bat pick up player
		end_game()


#end game function
func end_game():
	active = false #stop player processes from taking input
	get_tree().paused = false
	emit_signal("game_finished") #signal to cave default to stop waiting on showing minigame as visible
	$"enemy spawn".stop()
	$"../survival timer".stop()

#on game node visibility changed, when minigame is visible, reset game to starting condition
#return: void
func _on_visibility_changed() -> void:
	if get_parent().visible:
		active = true #use user inputs to update player physics, movement, animation 
		time_remaining = 20
		$"../game over".hide()
		$"../victory".hide()
		player = get_child(0)
		player.first = true #reset player to starting condition
		player.get_child(0).play("idle")
		$"../Label".text= str(time_remaining)
		$"../start".show()
		


# helper function for displays
func wait(seconds:float):
	await get_tree().create_timer(seconds).timeout
