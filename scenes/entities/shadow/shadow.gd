extends CharacterBody2D
class_name Shadow

@export var fish: FishData

@onready var body: Line2D = $Body
@onready var detectArea = $DetectArea
@onready var lineOfSight = $LineOfSight

@onready var roamTimer = $RoamingTimer
@onready var chaseTimer = $ChaseTimer

const SPEED = 50.0
const ROTATION_SPEED = 1.2
const FRICTION = 50
const ACCEL = 50

var state = IDLE
enum {
	IDLE,
	ROAM,
	CHASE,
	NIBBLE,
	BITE
}

var roaming_range = 64
var start_pos = self.global_position
var target_pos = self.global_position

var delta_elapsed = 0.0


func _ready():
	detectArea.init(self)
	
	update_target_position()


func _physics_process(delta):
	lineOfSight.force_raycast_update()
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_bait()
			if roamTimer.is_stopped():
				state = ROAM
		ROAM:
			seek_bait()
			var dir = global_position.direction_to(target_pos)
			velocity = velocity.move_toward(dir * SPEED, ACCEL * delta)
			rotation = lerp_angle(rotation, dir.normalized().angle(), 0.05)
			
			if global_position.distance_to(target_pos) <= 1:
				roamTimer.start(randi_range(1, 5))
				state = IDLE
		CHASE:
			var bait = detectArea.bait
			if bait != null:
				var dir = global_position.direction_to(bait.global_position)
				rotation = lerp_angle(rotation, dir.normalized().angle(), 0.05)
				
				if chaseTimer.is_stopped():
					velocity = velocity.move_toward(dir * SPEED, ACCEL * delta)
				else:
					velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			else:
				roamTimer.start(randi_range(2, 4))
				state = IDLE
		NIBBLE:
			call_deferred("queue_free")
		BITE:
			call_deferred("queue_free")
	
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


func seek_bait():
	if detectArea.can_see_bait():
		state = CHASE
		chaseTimer.start(randf_range(0.5, 2))


func update_target_position():
	var random_pos_x = randf_range(-roaming_range, roaming_range)
	var random_pos_y = randf_range(-roaming_range, roaming_range)
	var new_target_pos = Vector2(random_pos_x, random_pos_y)
	target_pos = start_pos + new_target_pos


func _on_roaming_timer_timeout():
	update_target_position()


func _on_chase_timer_timeout():
	pass
