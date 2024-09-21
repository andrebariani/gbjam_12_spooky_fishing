extends Node2D
class_name FishReelingScene


@export var input_reel := 'A'
@export var input_tug := 'B'

@onready var flailTimer = $FlailTimer
@onready var struggleTimer = $StruggleTimer
@onready var bg = $ParallaxBackground

@onready var lineTensionLabel = $LineTension
@onready var distanceLabel = $Distance
@onready var staminaLabel = $Stamina

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


func _physics_process(delta):
	update_inputs()
	
	var button_pressed = get_input(input_reel, 'pressed')
	var tug_just_pressed = get_input(input_tug, 'just_pressed')
	
	match state:
		REST:
			if button_pressed:
				distance += distance_rate * delta
			if tug_just_pressed:
				distance += (distance_rate * 10) * delta
				line_tension += line_tension_rate * 10 * delta
			
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
				distance += (distance_rate / 2.0) * delta
				line_tension += line_tension_rate * delta
			else:
				distance -= (distance_rate * 0.5) * delta
				
			add_stamina(-stamina_rate * 0.7, delta)
			
			if stamina <= 0:
				state = REST
		STRUGGLE:
			if button_pressed:
				distance += (distance_rate / 5.0) * delta
				line_tension += (line_tension_rate * 4) * delta
			else:
				distance -= (distance_rate) * delta
				
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
	
	if line_tension >= 100 or distance <= 0:
		print_debug('It got away...')
		state = RESULT
	elif distance >= 100:
		print_debug('You got a ', fish.name)
		state = RESULT


func _on_timer_timeout():
	state = STRUGGLE
	flailTimer.stop()

func _on_flail_timer_timeout():
	state = FLAIL
	struggleTimer.start(randf_range(0.5, 5))


func add_stamina(rate, delta):
	stamina += rate * 10 * delta
	stamina = clamp(stamina, 0, max_stamina)


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
