extends Control

@onready var title_label = $TitleLabel
@onready var scroll_label = $ScrollLabel
@onready var typing_label = $TypingLabel
@onready var continue_label = $ContinueLabel
@onready var anim_player = $AnimationPlayer

var phase = 0
var scroll_speed = 60.0
var waiting_for_input = false

# Typing effect
var full_text := """
You are a hunter, chosen for your cunning and courage. Rumors speak of the Wumpus, a shadowy beast with terrible fangs and an appetite for the foolish.
Somewhere in this cavern, it sleeps—until disturbed.

But beware—deadly pits lie beneath your feet, and giant bats may carry you to unknown parts of the cave.
You'll need your wits, your senses, and your limited supply of arrows to survive.

Can you outsmart the Wumpus before it devours you whole?

The hunt begins.
"""
var char_index = 0
var typing_speed = 0.025

func _ready():
	scroll_label.visible = false
	typing_label.visible = false
	continue_label.visible = false
	anim_player.play("grow_title")
	anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == "grow_title":
		show_continue_label()

func _unhandled_input(event):
	# when enter is hit, it moves onto the next phase of the backstory
	if event.is_action_pressed("ui_accept") and waiting_for_input:
		hide_continue_label()

		match phase:
			0:
				title_label.visible = false
				show_scroll_intro()
				phase = 1
			1:
				scroll_label.visible = false
				set_process(false)
				show_typing_intro()
				phase = 2
			2:
				get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func show_continue_label():
	continue_label.visible = true
	waiting_for_input = true

func hide_continue_label():
	continue_label.visible = false
	waiting_for_input = false

# --- PHASE 1: Scrolling paragraph ---
func show_scroll_intro():
	scroll_label.visible = true
	scroll_label.text = """
“You wake in the darkness with a torch barely flickering in your hand. The air smells of damp moss and old danger.
Deep below the mountains lies a maze of twisted tunnels, ancient and forgotten. Few have dared to enter. Fewer have returned.”
"""
	scroll_label.position = Vector2(100, 600)
	set_process(true)
	# Wait 3 seconds then show continue
	await get_tree().create_timer(3.0).timeout
	show_continue_label()

func _process(delta):
	if phase == 1:
		scroll_label.position.y -= scroll_speed * delta

# --- PHASE 2: Typing effect ---
func show_typing_intro():
	typing_label.visible = true
	typing_label.text = ""
	char_index = 0
	type_text()

func type_text():
	if char_index < full_text.length():
		typing_label.text += full_text[char_index]
		char_index += 1
		await get_tree().create_timer(typing_speed).timeout
		type_text()
	else:
		show_continue_label()


# skips to main menu
func _on_skip_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
