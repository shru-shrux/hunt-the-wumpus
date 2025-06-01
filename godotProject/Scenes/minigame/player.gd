extends CharacterBody2D

#player variables
const SPEED = 300.0
const JUMP_VELOCITY = -600.0
var first: bool
var active

func _physics_process(delta: float) -> void:
	# Add the gravity. update only if active/minigame root is visible
	if not is_on_floor() and active:
		velocity += get_gravity() * delta * 1.8
		
	move_and_slide()

#let player jump when user press space only when active
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and is_on_floor() and active: 
		velocity.y = JUMP_VELOCITY
		if first:
			$AnimatedSprite2D.play("run")
			$"../../start".hide()
			$"../enemy spawn".start()
			$"../../survival timer".start()
			first = false

#update active whenever game node visibility changed
func _on_game_visibility_changed() -> void:
	active = get_parent().active
