extends Line2D
class_name WaterTrail

@export var LENGTH = 40
@export var DISTANCE_LARGE_TIP = 128
@export var SMALL_TIP = 0.5
@export var LARGE_TIP = 1

var trail = []

# To work, must set top_level = true on CanvasItem or code

func _physics_process(_delta):
	var length = 0
	var pos = to_local(get_parent().global_position)
	trail.push_back(pos)
	
	if trail.size() > LENGTH and trail.size() > 2:
		trail.pop_front()
	
	clear_points()
		
	for i in (trail.size() - 1):
		length += trail[i].distance_to(trail[i + 1])
		add_point(trail[i])
	add_point(trail[trail.size() - 1])
	
	var width_value = lerpf(SMALL_TIP, LARGE_TIP, inverse_lerp(0, DISTANCE_LARGE_TIP, length))
	width_curve.set_point_value(0, width_value)
		
