extends Area2D

@export var max_reach = 64
const ACCEL = 300.0

@onready var collision = $CollisionShape2D
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
var target_pos = Vector2.ZERO
var speed = 0

var entity = null
var bait: BaitData = null

	
func init(_entity):
	entity = _entity
	global_position = entity.global_position

func _physics_process(delta):
	match state:
		WAIT:
			pass
		LAUNCH:
			if not tween.is_running():
				state = FLOAT
		FLOAT:
			collision.disabled = false
			
func launch(_power: int, _dir: Vector2):
	state = LAUNCH
	
	var start_pos = entity.global_position
	target_pos = Vector2(start_pos.x + 16 * _dir.x, start_pos.y * _dir.y) - global_position
	
	tween = get_tree().create_tween()
	tween.tween_property(self, 'global_position', target_pos, 0.5) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_QUAD)
	
