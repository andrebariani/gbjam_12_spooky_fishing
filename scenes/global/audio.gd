extends Node

@onready var tween: Tween

@onready var world_music: AudioStreamPlayer = $world_music

@export var fadeout_timer = 3.0


func fadeout(stream: AudioStreamPlayer, duration: float = 3.0):
	tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.stop()
	tween.tween_property(stream, 'volume_db', -40, duration) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)
	tween.play()
	
	await tween.finished
	
	stream.volume_db = 0
	stream.stop()

func play_fanfare():
	world_music.volume_db = -40
	$fanfare.play(0.0)
	
	await get_tree().create_timer(3, true).timeout
	world_music.volume_db = 0


func switch(stream: AudioStreamMP3):
	if world_music.playing:
		if stream.resource_path != world_music.stream.resource_path:
			fadeout(world_music, 1.5)
			
			await get_tree().create_timer(2, true).timeout
			
			world_music.stream = stream
			
			await get_tree().create_timer(1, true).timeout
			
			world_music.volume_db = 0
			world_music.play(0.0)
	else:
		world_music.stream = stream
		world_music.play(0.0)
