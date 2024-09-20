extends State


func begin():
	var e: PlayerBoat = entity
	
	if e.tackle_instance:
		return
	else:
		end("Idle")


func run(delta):
	var e: PlayerBoat = entity
	
	e.velocity = e.velocity.move_toward(Vector2.ZERO, e.FRICTION * delta)
	
	if e.tackle_instance:
		if e.tackle_instance.state != e.tackle_instance.LAUNCH:
			if e.global_position.distance_to(e.tackle_instance.global_position) < 5:
				e.despawn_tackle()
				end("Idle")
				return
	else:
		end("Idle")
