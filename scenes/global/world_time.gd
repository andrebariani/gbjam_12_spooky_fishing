extends Node

@export var ticks := 36

@export_range(0,59) var seconds := 0
@export_range(0,59) var minutes := 0
@export_range(0,23) var hours := 0
@export var days := 0

var delta_time := 0.0

func _run(delta):
	delta_time += (delta * ticks)
	if delta_time < 1:
		return
		
	var delta_int_secs = delta_time
	delta_time -= delta_int_secs
	
	seconds += int(delta_int_secs)
	minutes += int(seconds / floor(60))
	hours += int(minutes / floor(60))
	days += int(hours / floor(24))
	
	seconds = seconds % 60
	minutes = minutes % 60
	hours = hours % 24
