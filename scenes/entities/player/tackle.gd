extends CharacterBody2D


const SPEED = 300.0
const ACCEL = 300.0

@onready var collision = $CollisionShape2D

enum {
	WAIT,
	LAUNCH,
	IDLE
}

var state = WAIT

var dir = Vector2.ZERO

var bait: BaitData = null

func _physics_process(delta):
	match state:
		WAIT:
			collision.disabled = true
		LAUNCH:
			velocity = velocity.move_toward(dir * SPEED, ACCEL * delta)
		IDLE:
			collision.disabled = false
			
func _launch_at():
	state = LAUNCH
