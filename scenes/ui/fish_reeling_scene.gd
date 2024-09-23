extends Node2D
class_name FishReelingScene


@export var input_reel := 'A'
@export var input_tug := 'B'

@onready var sprite_fish_offset = $Hook/FishOffset
@onready var sprite = $Hook/FishOffset/Fish
@onready var hook_sprite = $Hook
@onready var flailTimer = $FlailTimer
@onready var struggleTimer = $StruggleTimer
@onready var bg = $ParallaxBackground

@onready var lineTensionLabel = $Debug/LineTension
@onready var distanceLabel = $Debug/Distance
@onready var staminaLabel = $Debug/Stamina

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

var state = WAIT

var distance = 50
var distance_rate = 10
var line_tension = 0
var line_tension_rate = 10

var max_stamina = 100
var stamina = 0
var stamina_rate = 2


func start(_fish):
	self.visible = true
	bg.visible = true
	fish = _fish
	max_stamina = fish.stamina
	stamina = max_stamina
	
	distance = 50
	
	if fish.sprite:
		sprite.texture = fish.sprite
		
		var texture_size = sprite.texture.get_size()
		var hframes = sprite.hframes
		var vframes = sprite.vframes
		var frame_size = Vector2(texture_size.x / hframes, texture_size.y / vframes)
		
		sprite.position = Vector2(frame_size.x / 2, 0)
	
	$AnimationPlayer.play("begin")
	
func reset():
	state = WAIT
	self.visible = false
	bg.visible = false
	
	distance = 50
	line_tension = 0
	
func _ready():
	bg.visible = self.visible
	state = WAIT
	start(fish)

var button_pressed = false
var tug_just_pressed = false

var sprite_frame_anim = 0
func _physics_process(delta):
	if state != WAIT:
		update_inputs()
	
	button_pressed = get_input(input_reel, 'pressed')
	tug_just_pressed = get_input(input_tug, 'just_pressed')
	
	match state:
		WAIT:
			sprite_frame_anim += 1
			if (sprite_frame_anim) % 20 == 0:
				next_frame()
				sprite_frame_anim = 1
			pass
		REST:
			sprite_frame_anim += 1
			if (sprite_frame_anim) % 30 == 0:
				next_frame()
				sprite_frame_anim = 1
				
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
			sprite_frame_anim += 1
			if (sprite_frame_anim) % 20 == 0:
				next_frame()
				sprite_frame_anim = 1
				
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
			sprite_frame_anim += 1
			if (sprite_frame_anim) % 5 == 0:
				next_frame()
				sprite_frame_anim = 1
				
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
	$Debug/state.text = str(state)
	
	bg.scroll_offset.x = -distance * 10
	bg.scroll_offset.y = distance / 10.0
	
	animate_body(delta)
	
	if line_tension >= 100 or distance <= 0:
		state = RESULT
		flailTimer.stop()
		struggleTimer.stop()
		play_got_away_anim()
		#SignalBus.minigame_completed.emit(true, fish)
	elif distance >= 100:
		state = RESULT
		flailTimer.stop()
		struggleTimer.stop()
		SignalBus.minigame_completed.emit(true, fish)


var sprite_flip = false
var flash_line = true
func animate_body(_delta):
	if state != RESULT:
		flash_line = !flash_line
		var alpha = 255
		if flash_line:
			alpha = 0
		hook_sprite.self_modulate = Color(hook_sprite.self_modulate, alpha)
	else:
		hook_sprite.self_modulate = Color(hook_sprite.self_modulate, 255)
	
	if state == REST:
		if sprite_flip != button_pressed:
			sprite_flip = button_pressed
			flip_fish()
	else:
		if sprite_flip:
			sprite_flip = false
			flip_fish()

func flip_fish():
	if sprite_flip:
		play_flip_anim(206, -1, 0.3)
	else:
		play_flip_anim(123, 1, 0.3)

func next_frame():
	if sprite.frame:
		sprite.frame = 0
	else:
		sprite.frame = 1


func play_flip_anim(point_x, _scale, _duration := 0.3):
	tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.stop()
	tween.tween_property(sprite_fish_offset, 'scale', Vector2(_scale, 1), _duration) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)
	tween.set_parallel()
	tween.tween_property(hook_sprite, 'position', Vector2(point_x, 0), _duration) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)
	tween.play()


func play_got_away_anim():
	hook_sprite.self_modulate = Color(hook_sprite.self_modulate, 255)
	hook_sprite.frame = 1
	tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.stop()
	tween.tween_property(sprite, 'position', Vector2(-100, 160), 3) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)
	tween.set_parallel()
	tween.tween_property(hook_sprite, 'position', Vector2(123, 20), 10) \
		.set_trans(Tween.TRANS_LINEAR)
	tween.play()
	
	await get_tree().create_timer(3.0, true).timeout
	
	SignalBus.minigame_completed.emit(false, null)
	state = WAIT
	hook_sprite.frame = 0


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


func _on_animation_player_animation_finished(_anim_name):
	state = REST
