extends Area2D
signal hit
signal interact

# this is basic player movement from tutorial, will need to be adapted and changed

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window

# in game attributes
var goldCount : int
var arrowConut : int

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	#hide() # this is currently commented out so it shows up when you run since start function isn't used now


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	
	
	if Input.is_action_pressed("Interact"):
		interact.emit()


func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

# when the player enters a new cave set position
func _on_new_cave_entered() -> void:
	position = Vector2(87, 507)

# this changes the amount of gold the player has
func goldChange(addedGold:int):
	goldCount += addedGold
	print("You now have " + str(goldCount) + " gold")
