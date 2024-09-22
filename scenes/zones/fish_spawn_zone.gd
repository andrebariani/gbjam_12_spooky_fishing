extends Node2D
class_name SpawnZone

@export var zone_name: String = ""
@export var possible_fishes: Array[FishData] = [
	preload("res://scenes/entities/fish/Redrum.tres"),
	preload("res://scenes/entities/fish/Lungfish.tres"),
	preload("res://scenes/entities/fish/Candiru.tres"),
	preload("res://scenes/entities/fish/ZombieWrasse.tres")
]

@onready var tilemap: TileMapLayer = $SpawnLayer
@onready var fishes: Node2D = $Fishes

@onready var SHADOW_TSCN: PackedScene = preload(
	"res://scenes/entities/shadow/shadow.tscn"
)


@onready var zone_cells: Array[Vector2i] = tilemap.get_used_cells()
@onready var current_shadows: Dictionary = {}


func _ready():
	tilemap.visible = false
	SignalBus.hour_passed.connect(_on_hour_passed)
	
	for fish in possible_fishes:
		current_shadows[fish.id] = []
	
	spawn_fishes()


func _on_hour_passed(prev_hour):
	print_debug('hour passed! it was', prev_hour, WorldTime.hours)
	update_spawned_fish()


func update_spawned_fish():
	if current_shadows.size() <= 0:
		spawn_fishes()
	for fish in possible_fishes:
		var shadows = current_shadows.get(fish.id)
		
		match fish.rarity:
			FishData.RARITY.COMMON:
				if shadows.size() < 3:
					spawn_fish(fish)
			FishData.RARITY.UNCOMMON:
				if shadows.size() < 2:
					spawn_fish(fish)
			FishData.RARITY.RARE:
				if shadows.size() < 1:
					spawn_fish(fish)
			FishData.RARITY.LEGENDARY:
				if shadows.size() == 0:
					spawn_fish(fish)

func spawn_fishes():
	for fish in possible_fishes:
		spawn_fish(fish)


func spawn_fish(fish: FishData):
	if fish.is_timed_only:
		if fish.start_time_window != WorldTime.hours:
			return
	
	print_debug('spawning fish: ', fish.name)
	var pos = get_random_pos()
	print('at: ', pos, zone_name)
	var shadow: Shadow = SHADOW_TSCN.instantiate()
	shadow.init(self, fish)
	shadow.global_position = pos
	
	current_shadows[fish.id].push_back(shadow)
	add_child(shadow)


func get_random_pos():
	return to_global(tilemap.map_to_local(zone_cells.pick_random()))
