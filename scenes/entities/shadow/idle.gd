extends State


func begin():
	var e: Shadow = entity
	var timer: Timer = e.roamTimer
	
	if timer.is_stopped():
		timer.start(randf_range(1, 5))
	
	if e.fish.is_timed_only and WorldTime.hours == e.fish.end_time_window:
		e.despawn()


func run(delta):
	var e: Shadow = entity
	
	e.velocity = e.velocity.move_toward(Vector2.ZERO, e.FRICTION * delta)
	e.seek_bait()
	if e.roamTimer.is_stopped():
		end("Roam")
