extends State


func begin():
	var e: PlayerBoat = entity
	
	e.sfx_boat.play(0.0)


func run(delta):
	var e: PlayerBoat = entity
	
	e.velocity = e.velocity.move_toward(Vector2.ZERO, e.FRICTION * delta)
	
	if e.inputs.dirv:
		end("Move")
	elif e.get_input(e.input_start, 'just_pressed'):
		if e.inventory.size() != 0 and e.selected_bait:
			end("Cast")
	
	e.sfx_boat.pitch_scale = lerpf(0.6, 1, e.velocity.length() / 50)
	
func before_end(_next_state):
	var e: PlayerBoat = entity
	if _next_state != 'Move':
		e.sfx_boat.stop()
