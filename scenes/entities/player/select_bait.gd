extends State


func begin():
	var e: PlayerBoat = entity
	
	e.is_selecting_bait = true


func run(delta):
	var e: PlayerBoat = entity
	
	var button_pressed_select_bait = e.get_input(e.input_select, 'pressed')
	var left_just_pressed = e.get_input('left', 'just_pressed')
	var right_just_pressed = e.get_input('right', 'just_pressed')
	
	e.velocity = e.velocity.move_toward(Vector2.ZERO, e.FRICTION * delta)
	
	if not button_pressed_select_bait:
		e.is_selecting_bait = false
		end("Cast")
	elif left_just_pressed:
		e.change_bait(-1)
	elif right_just_pressed:
		e.change_bait(1)
