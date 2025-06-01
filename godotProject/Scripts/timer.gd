extends Node
class_name MyTimer

var time = 0.00
var stopped = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stopped:
		return
	time += delta

func reset():
	time = 0.00

func time_to_string() -> String:
	var msec = fmod(time, 1) *1000
	var sec = fmod(time, 60)
	var min = time/60
	var format_string = "%02d : %02d : %02d"
	var actual_string = format_string % [min, sec, msec]
	return actual_string
