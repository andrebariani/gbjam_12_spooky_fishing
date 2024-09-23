extends State


func begin():
	var e: PlayerBoat = entity
	
	e.run_input = false


func run(_delta):
	var e: PlayerBoat = entity
	
	e.velocity = Vector2.ZERO
	
	
func before_end(_next_state):
	var e: PlayerBoat = entity
	e.run_input = true
