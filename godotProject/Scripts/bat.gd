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
	$AnimatedSprite2D.flip_h = (direction != 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	
	# calculate vertical offset using sine wave
	var y_offset = sin(time_passed * frequency * TAU) * amplitude
	
	# change in positions
	position.y = base_y + y_offset
	position.x += direction * speed * delta
	
	var cave_width = screen_size.x
	# flip direction at edges and animation
	if position.x < 0 or position.x > cave_width:
		direction *= -1
		$AnimatedSprite2D.flip_h = (direction != 1)
