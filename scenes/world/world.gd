extends Node2D

@onready var playerCamera = $World/PlayerBoat/PlayerCamera

@onready var world = $World
@onready var reeling_minigame = $FishReelingScene


func _ready():
	playerCamera.make_current()
	
	SignalBus.fish_hooked.connect(_on_fish_hooked)
	SignalBus.minigame_completed.connect(_on_minigame_completed)


func _physics_process(delta):
	WorldTime._run(delta)


func _on_fish_hooked(_fish: FishData):
	get_tree().paused = true
	world.visible = false
	reeling_minigame.start(_fish)
	playerCamera.enabled = false
	

func _on_minigame_completed(got_caught: bool = false, _fish: FishData = null):
	#if got_caught:
	#	print_debug('Caught a fish: ', _fish.name)
	#else:
	#	print_debug('It got away...')
		
	get_tree().paused = false
	world.visible = true
	reeling_minigame.reset()
	playerCamera.enabled = true
