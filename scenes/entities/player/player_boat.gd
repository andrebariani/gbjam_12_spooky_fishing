extends CharacterBody2D
class_name PlayerBoat


@onready var sm = $States
@onready var sprite = $sprite
@onready var arrow_sprite = $arrow

@onready var TACKLE_TSCN = preload(
	"res://scenes/entities/tackle/tackle.tscn"
)
var tackle_instance = null

# DEBUG
@onready var castLabel = $Debug/cast
@onready var posLabel = $Debug/pos


@export var input_start := 'A'
@export var input_cancel := 'B'

const SPEED = 50.0
const ROTATION_SPEED = 0.5
const ARROW_ROTATION_SPEED = 0.5
const FRICTION = 25
const ACCEL = 50

const CAST_POWER_MAX = 100

var cast_power = 0

var input_map = {
	A = false,
	B = false,
}

var inputs = {
	dirv = Vector2.ZERO,
	pressed = input_map.duplicate(),
	just_pressed = input_map.duplicate(),
	just_released = input_map.duplicate()
}

func _ready():
	sm.init(self)


func _physics_process(delta):
	update_inputs()
	sm.run(delta)
	move_and_slide()
	
	castLabel.text = str(cast_power)
	posLabel.text = str("%.1f" % global_position.x, ", ",  "%.1f" % global_position.y)
	

func spawn_tackle(_dir := Vector2.ZERO):
	var tackle: Tackle = TACKLE_TSCN.instantiate()
	tackle_instance = tackle
	tackle.init(self)
	
	get_parent().add_child(tackle)
	
	tackle.launch(cast_power, _dir)


func despawn_tackle():
	tackle_instance.call_deferred("queue_free")
	tackle_instance = null
	

func rotate_to_direction(_rotation: float, _dir: Vector2, _speed: float, delta: float):
	var tangent = atan2(_dir.y, _dir.x)
	var theta = wrapf(tangent - _rotation, -PI, PI)
	return clamp(_speed * TAU * delta, 0, abs(theta)) * sign(theta)


func update_inputs():
	#if ControllerManager.is_controller_active():
		#inputs.dirv.x = Input.get_axis("move_left_controller", "move_right_controller")
		#inputs.dirv.y = Input.get_axis("move_up_controller", "move_down_controller")
		#if inputs.dirv.length() < 0.3:
			#inputs.dirv = Vector2.ZERO
	#else:
		#inputs.dirv.x = Input.get_axis("move_left", "move_right")
		#inputs.dirv.y = Input.get_axis("move_up", "move_down")
	inputs.dirv = Input.get_vector("left", "right", "up", "down")
	
	
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
