extends State


func run(_delta):
	var e: PlayerBoat = entity
	
	if e.get_input(e.input_cancel, 'just_pressed'):
		end("Idle")
