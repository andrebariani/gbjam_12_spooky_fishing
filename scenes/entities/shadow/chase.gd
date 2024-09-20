extends State


func run(delta):
	var e: Shadow = entity
	
	var bait = e.detectArea.bait
	if bait != null:
		var dir = e.global_position.direction_to(bait.global_position)
		var distance = e.global_position.distance_to(bait.global_position)
		var target_velocity = Vector2.ZERO
		var friction_multiplier = e.FRICTION
		e.rotation = lerp_angle(e.rotation, dir.normalized().angle(), 0.05)
		
		if e.chaseTimer.is_stopped():
			if distance >= 5:
				target_velocity = dir * (e.SPEED - 10)
				friction_multiplier = e.ACCEL
			else:
				friction_multiplier = 3 * e.FRICTION
				end("Nibble")

		e.velocity = e.velocity.move_toward(target_velocity, friction_multiplier * delta)
	else:
		end("Idle")
