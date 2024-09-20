extends State


func run(delta):
	var e: Shadow = entity
	
	e.seek_bait()
	var dir = e.global_position.direction_to(e.target_pos)
	e.velocity = e.velocity.move_toward(dir * e.SPEED, e.ACCEL * delta)
	e.rotation = lerp_angle(e.rotation, dir.normalized().angle(), 0.05)

	if e.global_position.distance_to(e.target_pos) <= 1:
		e.roamTimer.start(randf_range(5, 15))
		end("Idle")
