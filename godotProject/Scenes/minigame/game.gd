extends Node2D


@export var mob_scene: PackedScene
var score
var time_remaining = 20

var player: Node2D
signal game_finished
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../game over".hide()
	$"../victory".hide()
	player = get_tree().current_scene.get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enemy_spawn_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	#var start_x = get_viewport_rect()
	mob.initialize(500, Vector2(700, 110))
	#specify where enemy spawn
	#have them spawn random intervals, connect to game control 

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	
	$"enemy spawn".wait_time=randf_range(0.6, 1.5)


func _on_survival_timer_timeout() -> void:
	time_remaining -= 1
	$"../Label".text="Time remaining: 0:" + str(time_remaining)
	if time_remaining ==0:
		$"../victory".show()
		get_tree().paused = true
		get_parent().get_parent().get_parent().get_node("CaveDefault").pickup = false
		end_game()


func end_game():
	emit_signal("game_finished")
