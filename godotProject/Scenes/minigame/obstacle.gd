extends Area2D

	
var speed

func initialize(num, start_position: Vector2):
	speed = num
	position = start_position
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -105:
		queue_free()


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.name == "player": 
		body.get_parent().get_parent().get_child(4).show()
		get_tree().paused = true
		get_parent().end_game()
		
