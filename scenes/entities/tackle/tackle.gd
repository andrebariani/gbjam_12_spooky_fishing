extends Area2D
class_name Tackle

@export var max_reach = 64
const ACCEL = 300.0

@onready var collision = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var tween: Tween
#@onready var path = $Path2D
#@onready var path_follow = $Path2D/PathFollow2D

enum {
	WAIT,
	LAUNCH,
	FLOAT
}

var state = WAIT

var dir = Vector2.ZERO
var start_pos = Vector2.ZERO
var target_pos = Vector2.ZERO
var speed = 0
var delta_elapsed = 0
var arc_axis = 0

var entity = null
var bait: BaitData = null

	
func init(_entity):
	entity = _entity
	global_position = entity.global_position
	#print_debug(entity.global_position)
	#print_debug(global_position)

func _physics_process(delta):
	delta_elapsed += delta * 5
	
	match state:
		WAIT:
			return
		LAUNCH:
			arc_axis = speed * sin(deg_to_rad(45)) * delta_elapsed - (0.5 * 9.8 * pow(delta_elapsed, 2))
			
			if arc_axis <= 0:
				state = FLOAT
			
			if arc_axis > 0:
				var x_axis = speed * cos(deg_to_rad(45)) * delta_elapsed
				global_position = start_pos + (dir * x_axis)
				
				sprite.position.y = -arc_axis
		FLOAT:
			collision.disabled = false
			
func launch(_power: int, _dir: Vector2):
	state = LAUNCH
	
	dir = _dir
	delta_elapsed = 0
	
	start_pos = entity.global_position
	
	speed = pow(_power * 9.8 / sin(2 * deg_to_rad(45)), 0.5)
