extends Control

@onready var tab_container = $TabContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.profile_start_tab == "profile":
		tab_container.current_tab = 2
	elif Global.profile_start_tab == "options":
		tab_container.current_tab = 3
	elif Global.profile_start_tab == "leaderboard":
		tab_container.current_tab = 0
	elif Global.profile_start_tab == "achievements":
		tab_container.current_tab = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
