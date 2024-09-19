extends State
	
func run(delta):
	var e: PlayerBoat = entity
	
	e.velocity = e.velocity.move_toward(Vector2.ZERO, e.FRICTION * delta)
	
	if e.inputs.dirv:
		end("Move")
	elif e.get_input(e.input_start, 'just_released'):
		end("Cast")
