extends State

@onready var nibbleTimer := $NibbleTimer

@onready var tween: Tween

var nibbles = 0
var MAX_NIBBLE = 0.3
var MIN_NIBBLE = 3.0

func begin():
	var e: Shadow = entity
	
	if e.fish.is_fixed_attempts:
		nibbles = e.fish.max_attempts
	else:
		nibbles = randi_range(0, e.fish.max_attempts)
	nibbleTimer.start(randf_range(e.fish.min_interval, e.fish.max_interval))


func run(delta):
	var e: Shadow = entity
	
	e.velocity = e.velocity.move_toward(Vector2.ZERO, e.FRICTION * delta)
	
	var bait = e.detectArea.bait
	if bait:
		var distance = e.global_position.distance_to(bait.global_position)
		
		if nibbles <= 0:
			end("Bite")
			return
		elif distance >= 5:
			end("Chase")
	else:
		end("Idle")


func before_end(_next):
	nibbleTimer.stop()
	
	
func play_nibble_animation():
	var e: Shadow = entity
	
	tween = get_tree().create_tween()
	tween.tween_property(e.body, 'position', Vector2(2, 0), 0.1) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(e.body, 'position', Vector2.ZERO, 0.2) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_QUAD)
	tween.play()


func _on_nibble_timer_timeout():
	nibbles -= 1
	if nibbles > 0:
		play_nibble_animation()
		nibbleTimer.start(randf_range(MIN_NIBBLE, MAX_NIBBLE))
