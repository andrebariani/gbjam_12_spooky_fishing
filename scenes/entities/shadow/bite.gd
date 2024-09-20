extends State

@onready var biteTimer = $BiteTimer

var current_fish_hook_sec = 0

func begin():
	var e: Shadow = entity
	var bait = e.detectArea.bait
	
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
	biteTimer.stop()


func _on_bite_timer_timeout():
	var e: Shadow = entity
	var bait = e.detectArea.bait
	
	bait.despawn()
	
	print_debug('Fish escaped...', e.fish.name)
	
	end('Escape')
