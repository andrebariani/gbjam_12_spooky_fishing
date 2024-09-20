extends State

@onready var biteTimer = $BiteTimer
@onready var tween: Tween

var current_fish_hook_sec = 0
var original_scale := Vector2(1, 1)

func begin():
	var e: Shadow = entity
	var bait = e.detectArea.bait
	
	original_scale = e.body.scale
	
	tween = get_tree().create_tween()
	tween.tween_property(e.body, 'scale', Vector2.ZERO, 0.5) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)
	tween.play()
	
	bait.bite()
	
	biteTimer.start(e.fish.hook_window)


func run(delta):
	var e: Shadow = entity
	var bait = e.detectArea.bait
	
	e.velocity = e.velocity.move_toward(Vector2.ZERO, e.FRICTION * delta)
	
	if bait:
		if bait.hooked:
			print_debug('You caught a ', e.fish.name)
			biteTimer.stop()
			bait.despawn()
			e.call_deferred("queue_free")
	else:
		end('Idle')


func before_end(_next):
	var e: Shadow = entity
	biteTimer.stop()
	
	tween = get_tree().create_tween()
	tween.tween_property(e.body, 'scale', original_scale, 0.5) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_QUAD)
	tween.play()


func _on_bite_timer_timeout():
	var e: Shadow = entity
	var bait = e.detectArea.bait
	
	bait.despawn()
	
	print_debug('Fish escaped...', e.fish.name)
	
	end('Escape')
