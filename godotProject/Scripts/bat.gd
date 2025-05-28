extends Area2D

@export var speed = 400
@export var amplitude = 20
@export var frequency = 2

var screen_size
var time_passed := 0.0
# -1 is left and 1 is right
var direction := 1
var base_y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	base_y = position.y
	$CollisionShape2D.disabled = false
	$AnimatedSprite2D.animation = "fly"
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.flip_h = (direction == 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	
	# Calculate vertical offset using sine wave
	var y_offset = sin(time_passed * frequency * TAU) * amplitude
	
	# Move left and apply vertical offset
	position.x -= speed * delta
	position.y = position.y + y_offset * delta
	
	# Flip direction at edges
	if position.x < 0:
		direction = 1
		$AnimatedSprite2D.flip_h = true
	elif position.x > screen_size.x:
		direction = -1
		$AnimatedSprite2D.flip_h = false
