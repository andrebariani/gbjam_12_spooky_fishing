extends CharacterBody2D
class_name Shadow

@onready var body: Line2D = $Body
@onready var detectArea = $DetectArea
@onready var lineOfSight = $LineOfSight

@onready var sm: StateMachine = $States

@onready var roamTimer = $RoamingTimer
@onready var chaseTimer = $ChaseTimer

@onready var tween: Tween

const SPEED = 50.0
const ROTATION_SPEED = 1.2
const FRICTION = 75.0
const ACCEL = 20.0

var shadow_scales = {
	FishData.SHADOW_SIZE.SMALL: Vector2(0.5, 0.5),
	FishData.SHADOW_SIZE.MEDIUM: Vector2(1, 1),
	FishData.SHADOW_SIZE.LARGE: Vector2(1.5, 1.5),
	FishData.SHADOW_SIZE.HUGE: Vector2(2.5, 2.5),
	FishData.SHADOW_SIZE.TITANIC: Vector2(3, 3),
}

var state = IDLE
enum {
	IDLE,
	ROAM,
	CHASE,
	NIBBLE,
	BITE,
	ESCAPE
}

var roaming_range = 64
var start_pos = self.global_position
var target_pos = self.global_position

var delta_elapsed = 0.0

var zone: SpawnZone = null
@export var fish: FishData

func init(_zone, _fish: FishData):
	zone = _zone
	fish = _fish
	
	rotation = randf_range(0, 2*PI)


func _ready():
	randomize()
	detectArea.init(self)
	
	update_target_position()
	
	sm.init(self)
	
	if fish:
		self.scale = shadow_scales[fish.shadow_size]
	
	play_spawn_anim()


func _physics_process(delta):
	lineOfSight.force_raycast_update()
	
	sm.run(delta)
	
	animate_body(delta)
	move_and_slide()


func animate_body(_delta):
	var pps = abs(velocity.x) + abs(velocity.y)
	var frequency = clampf((pps / (SPEED / 10.0)), 3, 30)
	var max_amplitude = 1
	delta_elapsed = fmod(delta_elapsed + (_delta * frequency), TAU)
	
	for point_idx in body.points.size():
		var point = body.get_point_position(point_idx)
		
		point.y = cos(delta_elapsed - point_idx) * max_amplitude
		
		body.set_point_position(point_idx, point)
		

func play_spawn_anim():
	body.scale = Vector2.ZERO
	tween = get_tree().create_tween()
	tween.tween_property(body, 'scale', Vector2.ONE, 0.8) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_QUAD)
	tween.play()
	
	
func play_despawn_anim():
	body.scale = Vector2.ONE
	tween = get_tree().create_tween()
	tween.tween_property(body, 'scale', Vector2.ZERO, 0.5) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)
	tween.play()
	

func despawn():
	detectArea.shape.disabled = true
	
	# need to be timed so had to move it here
	body.scale = Vector2.ONE
	tween = get_tree().create_tween()
	tween.tween_property(body, 'scale', Vector2.ZERO, 0.5) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)
	tween.play()
	
	await tween.finished
	
	call_deferred("queue_free")


func seek_bait():
	if detectArea.can_see_bait():
		sm.change_state("Chase")
		chaseTimer.start(randf_range(0.5, 2))


func update_target_position():
	if zone:
		target_pos = zone.get_random_pos()
	else:
		var random_pos_x = randf_range(-roaming_range, roaming_range)
		var random_pos_y = randf_range(-roaming_range, roaming_range)
		var new_target_pos = Vector2(random_pos_x, random_pos_y)
		target_pos = start_pos + new_target_pos


func _on_roaming_timer_timeout():
	update_target_position()
