extends State

	
func run(delta):
	var e: PlayerBoat = entity
	
	e.velocity = e.velocity.move_toward(e.inputs.dirv * e.SPEED, e.ACCEL * delta)
	
	#var input_angle = e.inputs.dirv.normalized().angle()
	#e.sprite.rotation = lerp(e.sprite.rotation, input_angle, e.ROTATION_SPEED)
	
	e.sprite.rotation += e.rotate_to_direction(
		e.sprite.rotation,e.inputs.dirv, e.ROTATION_SPEED, delta
	)
	
	if e.inputs.dirv == Vector2.ZERO:
		end("Idle")
