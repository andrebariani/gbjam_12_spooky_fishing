extends State


func run(delta):
	var e: PlayerBoat = entity
	
	e.velocity = e.velocity.move_toward(Vector2.ZERO, e.FRICTION * delta)
	
	if e.get_input(e.input_cancel, 'just_pressed'):
		e.despawn_tackle()
		end("Idle")
