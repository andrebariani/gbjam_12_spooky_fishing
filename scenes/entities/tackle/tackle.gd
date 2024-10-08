extends Area2D
class_name Tackle

@export var bait: BaitData = null
@export var SPEED = 64.0
@export var  ACCEL = 1

@onready var collision = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var tween: Tween

enum {
	WAIT,
	LAUNCH,
	FLOAT,
	BITE
}

var state = WAIT

var dir = Vector2.ZERO
var start_pos = Vector2.ZERO
var target_pos = Vector2.ZERO
var launch_speed = 0
var reel_speed = 0.0
var delta_elapsed = 0
var arc_axis = 0

var is_moving := false
var hooked := false
var hooked_fish: FishData = null

var entity: PlayerBoat = null


func init(_entity):
	entity = _entity
	bait = entity.selected_bait
	global_position = entity.global_position


func _physics_process(delta):
	var e: PlayerBoat = entity
	delta_elapsed += delta * 5
	
	match state:
		WAIT:
			return
		LAUNCH:
			arc_axis = launch_speed * sin(deg_to_rad(45)) * delta_elapsed - \
					(0.5 * 9.8 * pow(delta_elapsed, 2))
			
			if arc_axis > 0:
				var x_axis = launch_speed * cos(deg_to_rad(45)) * delta_elapsed
				global_position = start_pos + (dir * x_axis)
				
				sprite.position.y = -arc_axis
			
			# landed on water
			if arc_axis <= 0:
				collision.disabled = false
				state = FLOAT
				$sfx.play(0.0)
		FLOAT:
			var pressed = e.get_input(e.input_start, "pressed")
			
			if pressed:
				is_moving = false
				reel_speed = lerp(reel_speed, SPEED, ACCEL * delta)
				$sfx_reel.play(0.0)
			else:
				is_moving = true
				$sfx_reel.stop()
				reel_speed = lerp(reel_speed, 0.0, (ACCEL*4) * delta)
			
			global_position += global_position.direction_to( \
					e.global_position) * reel_speed * delta
		BITE:
			if e.get_input(e.input_start, "just_pressed"):
				hooked = true
				SignalBus.fish_hooked.emit(hooked_fish)


func despawn():
	var e: PlayerBoat = entity
	e.despawn_tackle()


func bite(_fish: FishData):
	$sfx_bite.play()
	hooked = false
	hooked_fish = _fish
	state = BITE
	collision.disabled = false
	sprite.visible = false


func launch(_power: int, _dir: Vector2):
	state = LAUNCH
	
	dir = _dir
	delta_elapsed = 0
	
	start_pos = entity.global_position
	
	launch_speed = pow(_power * 9.8 / sin(2 * deg_to_rad(45)), 0.5)
