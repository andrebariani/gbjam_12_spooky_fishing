extends State


func begin():
	var e: Shadow = entity
	var timer: Timer = e.roamTimer
	
	if timer.is_stopped():
		timer.start(randf_range(1, 5))


func run(delta):
	var e: Shadow = entity
	
	e.velocity = e.velocity.move_toward(Vector2.ZERO, e.FRICTION * delta)
	e.seek_bait()
	if e.roamTimer.is_stopped():
		end("Roam")
