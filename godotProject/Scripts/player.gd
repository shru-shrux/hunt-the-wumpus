extends Area2D
signal hit
signal interact

# this is basic player movement from tutorial, will need to be adapted and changed

@onready var gold_label = get_tree().current_scene.get_node("GoldCount")
@onready var arrow_label = get_tree().current_scene.get_node("ArrowCount")

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var sprint_multiplier = 1.5 # How much faster the player moves when sprinting

var screen_size # Size of the game window
var current_speed = speed

var can_move = true

var falling = false

# in game attributes
var goldCount : int
var arrowCount : int
var hasAntiBatEffect : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	#hide() # this is currently commented out so it shows up when you run since start function isn't used now
	goldCount = PlayerData.goldCount
	arrowCount = PlayerData.arrowCount
	$CollisionShape2D.disabled = true
	hasAntiBatEffect = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var velocity = Vector2.ZERO # The player's movement vector.

	if can_move:
		
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		
		# Sprint check
		var sprinting = Input.is_action_pressed("sprint") # Make sure you set this input action in Project Settings > Input Map
		if sprinting:
			current_speed = speed * sprint_multiplier
		
		#var jumping : bool = Input.is_action_pressed("jump")

		#if jumping:
		#	$AnimatedSprite2D.animation = "jump"
		#	$AnimatedSprite2D.play()
			# doesn't actually move the player
		elif velocity.length() > 0:
			velocity = velocity.normalized() * current_speed
			if sprinting:
				$AnimatedSprite2D.animation = "run"
			else:
				$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.play()
		else:
			$AnimatedSprite2D.animation = "idle"
			$AnimatedSprite2D.play()
			
		# Flip sprite based on direction
		if velocity.x != 0:
			$AnimatedSprite2D.flip_h = velocity.x < 0
			$AnimatedSprite2D.flip_v = false

		position += velocity * delta
		position.x = clamp(position.x, 119, 1059)

		if Input.is_action_pressed("Interact"):
			interact.emit()
	
	elif falling:
		velocity.y += 1000
		position += velocity * delta
		
	else:
		$AnimatedSprite2D.animation = "idle"
		$AnimatedSprite2D.play()

func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

## when the player enters a new cave set position
#func _on_new_cave_entered() -> void:
	#position = Vector2(87, 507)

# this changes the amount of gold the player has
func goldChange(addedGold:int):
	if goldCount < 0:
		goldCount = 0
	goldCount += addedGold
	PlayerData.goldCount = goldCount
	print("You now have " + str(goldCount) + " gold")
	
	if gold_label:
		gold_label.text = str(goldCount)


func arrowChange(addedArrow:int):
	arrowCount += addedArrow
	PlayerData.arrowCount = arrowCount
	print("You now have " + str(arrowCount) + " arrows")
	
	if arrow_label:
		arrow_label.text = str(arrowCount)
	
func changeAntiBat(gotEffect:bool):
	hasAntiBatEffect = true
	PlayerData.hasAntiBatEffect = hasAntiBatEffect
	print("You now have the anti-bat effect")
