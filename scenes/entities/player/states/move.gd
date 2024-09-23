extends State


func begin():
	var e: PlayerBoat = entity
	e.sfx_boat.play(0.0)


func run(delta):
	var e: PlayerBoat = entity
	
	e.velocity = e.velocity.move_toward(e.inputs.dirv * e.SPEED, e.ACCEL * delta)
	
	var input_angle = e.inputs.dirv.normalized().angle()
	e.sprite.rotation = lerp_angle(e.sprite.rotation, input_angle, e.ROTATION_SPEED)
	
	e.sfx_boat.pitch_scale = lerpf(0.6, 1, e.velocity.length() / 50)
	
	if e.inputs.dirv == Vector2.ZERO:
		end("Idle")
