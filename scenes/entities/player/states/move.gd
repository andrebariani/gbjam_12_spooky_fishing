extends State

	
func run(delta):
	var e: PlayerBoat = entity
	
	e.velocity = e.velocity.move_toward(e.inputs.dirv * e.SPEED, e.ACCEL * delta)
	
	var input_angle = e.inputs.dirv.normalized().angle()
	e.sprite.rotation = lerp_angle(e.sprite.rotation, input_angle, e.ROTATION_SPEED)
	
	if e.inputs.dirv == Vector2.ZERO:
		end("Idle")
