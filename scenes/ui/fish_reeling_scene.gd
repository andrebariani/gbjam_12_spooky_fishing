extends Node2D
class_name FishReelingScene


@export var input_reel := 'A'
@export var input_tug := 'B'

@onready var sprite = $Fish
@onready var hook_sprite = $Hook
@onready var flailTimer = $FlailTimer
@onready var struggleTimer = $StruggleTimer
@onready var bg = $ParallaxBackground

@onready var lineTensionLabel = $LineTension
@onready var distanceLabel = $Distance
@onready var staminaLabel = $Stamina

@onready var tween: Tween

@export var fish: FishData

@export var total_distance: float = 100
@export var max_line_tension: float = 100

var input_map = {
	A = false,
	B = false,
}

var inputs = {
	#dirv = Vector2.ZERO,
	pressed = input_map.duplicate(),
	just_pressed = input_map.duplicate(),
	just_released = input_map.duplicate()
}

enum {
	WAIT,
	REST,
	FLAIL,
	STRUGGLE,
	RESULT
}

var state = REST

var distance = 50
var distance_rate = 10
var line_tension = 0
var line_tension_rate = 10

var max_stamina = 100
var stamina = 80
var stamina_rate = 2


func init(_fish):
	fish = _fish
	#max_stamina = fish.stamina
	#stamina = max_stamina
	max_stamina = 100
	stamina = max_stamina

var button_pressed = false
var tug_just_pressed = false

func _physics_process(delta):
	update_inputs()
	
	button_pressed = get_input(input_reel, 'pressed')
	tug_just_pressed = get_input(input_tug, 'just_pressed')
	
	match state:
		WAIT:
			return
		REST:
			if button_pressed:
				add_distance(distance_rate, delta)
				add_line_tension(line_tension_rate * 0.4, delta)
			else:
				add_distance(-distance_rate * 0.5, delta)
				add_line_tension(-line_tension_rate * 4, delta)
			if tug_just_pressed:
				add_distance(distance_rate * 10, delta)
				add_line_tension(line_tension_rate * 10, delta)
			
			add_stamina(stamina_rate, delta)
			
			if stamina >= 100:
				state = STRUGGLE
			elif stamina >= 30:
				if flailTimer.is_stopped():
					var sec = randf_range(0.5, 2)
					flailTimer.start(sec)
					struggleTimer.start(sec + randf_range(0, 1))
		FLAIL:
			if button_pressed:
				add_distance(distance_rate / 2.0, delta)
				add_line_tension(line_tension_rate, delta)
			else:
				add_distance(-distance_rate * 0.75, delta)
				add_line_tension(-line_tension_rate, delta)
				
			add_stamina(-stamina_rate * 0.7, delta)
			
			if stamina <= 0:
				state = REST
		STRUGGLE:
			if button_pressed:
				add_distance(-distance_rate / 5.0, delta)
				add_line_tension(line_tension_rate * 4, delta)
			else:
				add_distance(-distance_rate, delta)
				add_line_tension(-line_tension_rate * 0.5, delta)
				
			add_stamina(-stamina_rate * 1.5, delta)
			
			if stamina <= 0:
				state = REST
		RESULT:
			return
	
	lineTensionLabel.text = str(int(line_tension))
	distanceLabel.text = str(int(distance))
	staminaLabel.text = str(int(stamina))
	$state.text = str(state)
	
	bg.scroll_offset.x = -distance * 10
	bg.scroll_offset.y = distance / 10.0
	
	animate_body(delta)
	
	if line_tension >= 100 or distance <= 0:
		print_debug('It got away...')
		state = RESULT
		play_got_away_anim()
		flailTimer.stop()
		struggleTimer.stop()
	elif distance >= 100:
		print_debug('You got a ', fish.name)
		state = RESULT
		flailTimer.stop()
		struggleTimer.stop()
		

var sprite_flip = false
func animate_body(_delta):
	if state != RESULT:
		hook_sprite.visible = !hook_sprite.visible
	else:
		hook_sprite.visible = true
	if state == REST:
		if sprite_flip != button_pressed:
			sprite_flip = button_pressed
			flip_fish()
	else:
		if sprite_flip:
			sprite_flip = false
			flip_fish()
			

func flip_fish():
	tween = get_tree().create_tween()
	tween.stop()
	if sprite_flip:
		tween.tween_property(sprite, 'scale', Vector2(-1, 1), 0.3) \
			.set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_QUAD)
		tween.set_parallel()
		tween.tween_property(hook_sprite, 'position', Vector2(206, 0), 0.3) \
			.set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_QUAD)
	else:
		tween.tween_property(sprite, 'scale', Vector2(1, 1), 0.3) \
			.set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_QUAD)
		tween.set_parallel()
		tween.tween_property(hook_sprite, 'position', Vector2(123, 0), 0.3) \
			.set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_QUAD)
	tween.play()
	
	
func play_got_away_anim():
	hook_sprite.visible = true
	hook_sprite.frame = 1
	tween = get_tree().create_tween()
	tween.stop()
	tween.tween_property(sprite, 'position', Vector2(-50, 80), 1.5) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(hook_sprite, 'position', Vector2(123, 20), 10) \
		.set_trans(Tween.TRANS_LINEAR)
	tween.play()


func _on_timer_timeout():
	state = STRUGGLE
	flailTimer.stop()

func _on_flail_timer_timeout():
	state = FLAIL
	struggleTimer.start(randf_range(0.5, 5))


func add_distance(rate, delta):
	distance += rate * delta
	distance = clamp(distance, 0, 100)

func add_stamina(rate, delta):
	stamina += rate * 8 * delta
	stamina = clamp(stamina, 0, max_stamina)


func add_line_tension(rate, delta):
	line_tension += rate * delta
	line_tension = clamp(line_tension, 0, 100)


func update_inputs():
	#inputs.dirv = Input.get_vector("left", "right", "up", "down")
	
	for i_p in inputs.pressed:
		inputs.pressed[i_p] = Input.is_action_pressed(i_p)
		
	for i_jp in inputs.just_pressed:
		inputs.just_pressed[i_jp] = Input.is_action_just_pressed(i_jp)
		
	for i_jr in inputs.just_released:
		inputs.just_released[i_jr] = Input.is_action_just_released(i_jr)


func get_input(input_name: String, state_name: String = 'just_pressed'):
	if input_name == 'dirv':
		return inputs[input_name]
	return inputs[state_name][input_name]
