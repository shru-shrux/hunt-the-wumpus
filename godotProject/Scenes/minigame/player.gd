extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
var first = true
var active

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and active:
		velocity += get_gravity() * delta * 1.8
		

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		#if first:
			#$AnimatedSprite2D.play("run")
			#$"../../start".hide()
			#$"../enemy spawn".start()
			#$"../../survival timer".start()
			#first = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
		#$AnimatedSprite2D.play("run")
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#$AnimatedSprite2D.play("idle")

	move_and_slide()
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and is_on_floor() and active:
		velocity.y = JUMP_VELOCITY
		if first:
			$AnimatedSprite2D.play("run")
			$"../../start".hide()
			$"../enemy spawn".start()
			$"../../survival timer".start()
			first = false
		get_viewport().set_input_as_handled()


func _on_game_visibility_changed() -> void:
	active = get_parent().active
