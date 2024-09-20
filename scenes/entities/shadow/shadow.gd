extends CharacterBody2D
class_name Shadow

@export var fish: FishData

@onready var sprite = $Line2D
@onready var roamTimer = $RoamingTimer
@onready var detectArea = $DetectArea
@onready var lineOfSight = $LineOfSight

const SPEED = 50.0
const ROTATION_SPEED = 1.2
const FRICTION = 50
const ACCEL = 50

#var shadow_size_transform = {
	#FishData.SHADOW_SIZE.SMALL: {
		#position: Vector2(0,0),
		#scale: Vector2(1,1)
	#},
	#FishData.SHADOW_SIZE.MEDIUM: {
		#position: Vector2(0,0),
		#scale: Vector2(2,2)
	#},
#}

var state = IDLE
enum {
	IDLE,
	ROAM,
	CHASE,
	BITE
}

var roaming_range = 64
var start_pos = self.global_position
var target_pos = self.global_position


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
				print_debug('idle')
				roamTimer.start(randi_range(1, 5))
				state = IDLE
		CHASE:
			var bait = detectArea.bait
			if bait != null:
				var dir = global_position.direction_to(bait.global_position)
				velocity = velocity.move_toward(dir * SPEED, ACCEL * delta)
				look_at(bait.global_position)
			else:
				state = IDLE
				
		BITE:
			call_deferred("queue_free")
			
	move_and_slide()
	
func seek_bait():
	if detectArea.can_see_bait():
		print_debug('chase!')
		state = CHASE


func update_target_position():
	var random_pos_x = randf_range(-roaming_range, roaming_range)
	var random_pos_y = randf_range(-roaming_range, roaming_range)
	var new_target_pos = Vector2(random_pos_x, random_pos_y)
	target_pos = start_pos + new_target_pos


func _on_roaming_timer_timeout():
	update_target_position()
	print_debug('go somewhere', target_pos)
