extends State

@onready var tween: Tween
var cast_dir := Vector2.RIGHT
var rotation = 0

func begin():
	var e: PlayerBoat = entity
	
	e.cast_power = 0
	
	tween = get_tree().create_tween()
	tween.stop()
	tween.tween_property(e, 'cast_power', 100, 1) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(e, 'cast_power', 0, 1) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_QUAD)
	tween.set_loops(-1)
	
	e.arrow_sprite.visible = true
	
func run(delta):
	var e: PlayerBoat = entity
	
	var button_pressed = e.get_input(e.input_start, 'pressed')
	#var button_just_pressed = e.get_input(e.input_start, 'just_pressed')
	var button_released = e.get_input(e.input_start, 'just_released')
	
	e.velocity = e.velocity.move_toward(Vector2.ZERO, e.FRICTION * delta)
	
	if e.inputs.dirv != Vector2.ZERO and not button_pressed:
		var input_angle = e.inputs.dirv.normalized().angle()
		e.arrow_sprite.rotation = lerp_angle(e.arrow_sprite.rotation, input_angle, e.ARROW_ROTATION_SPEED)
		
		cast_dir = Vector2.from_angle(e.arrow_sprite.rotation)
	
	if button_pressed:
		start_tweening()
	elif button_released:
		tween.stop()
		e.spawn_tackle(cast_dir)
		end("Fishing")
	if e.get_input(e.input_cancel, 'just_pressed'):
		end("Idle")
		
func start_tweening():
	if not tween.is_running():
		tween.play()

func before_end(_next_state):
	var e: PlayerBoat = entity
	e.arrow_sprite.visible = false
