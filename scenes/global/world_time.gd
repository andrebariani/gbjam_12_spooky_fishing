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
	
	seconds += delta_int_secs
	minutes += seconds / 60
	hours += minutes / 60
	days += hours / 24
	
	seconds = seconds % 60
	minutes = minutes % 60
	hours = hours % 24
