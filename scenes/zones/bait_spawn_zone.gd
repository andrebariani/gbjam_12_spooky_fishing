extends Node2D
class_name BaitSpawnZone

@export var possible_baits: Array[BaitData] = [
	preload("res://scenes/items/maggot.tres"),
	preload("res://scenes/items/beetle.tres"),
]
@export var max_baits = 3

@onready var tilemap: TileMapLayer = $SpawnLayer
@onready var spawnTimer: Timer = $SpawnTimer

@onready var BAIT_TSCN: PackedScene = preload(
	"res://scenes/zones/bait_drop.tscn"
)


@onready var zone_cells: Array[Vector2i] = tilemap.get_used_cells()
@onready var current_baits: Array[BaitDrop]


func _ready():
	randomize()
	tilemap.visible = false
		
	spawnTimer.start(randi_range(1, 2))


func spawn_possible_baits():
	if current_baits.size() < max_baits:
		spawn_bait(possible_baits.pick_random())


func spawn_bait(bait: BaitData):
	var pos = get_random_pos()
	var bait_drop: BaitDrop = BAIT_TSCN.instantiate()
	bait_drop.init(bait)
	bait_drop.global_position = get_random_pos()
	
	current_baits.push_back(bait_drop)
	add_child(bait_drop)


func get_random_pos():
	return tilemap.map_to_local(zone_cells.pick_random())


func _on_spawn_timer_timeout():
	spawn_possible_baits()
	spawnTimer.start(randi_range(1, 2))
