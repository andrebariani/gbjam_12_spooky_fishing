extends CharacterBody2D
class_name PlayerBoat


@onready var sm = $States
@onready var sprite = $sprite
@onready var arrow_sprite = $arrow

@onready var TACKLE_TSCN = preload(
	"res://scenes/entities/tackle/tackle.tscn"
)
var tackle_instance = null

# DEBUG
@onready var castLabel = $Debug/cast
@onready var posLabel = $Debug/pos
@onready var menu = $GameMenu


@export var input_start := 'A'
@export var input_cancel := 'B'
@export var input_select := 'select'
@export var selected_bait := preload("res://scenes/items/maggot.tres")
var is_selecting_bait = true

const SPEED = 50.0
const ROTATION_SPEED = 0.05
const ARROW_ROTATION_SPEED = 0.08
const FRICTION = 25
const ACCEL = 50
const CHANGE_SPRITE_TRESHOLD = 0.5

const CAST_POWER_MAX = 100

var cast_power = 0

var input_map = {
	A = false,
	B = false,
	select = false,
	left = false,
	right = false
}

var inputs = {
	dirv = Vector2.ZERO,
	pressed = input_map.duplicate(),
	just_pressed = input_map.duplicate(),
	just_released = input_map.duplicate()
}


var inventory = [
	{"data": preload("res://scenes/items/maggot.tres"), "units": 3}
]

func _ready():
	sm.init(self)
	menu.init(self)
	menu.update_inventory()
	SignalBus.fish_bited.connect(_on_fish_bited)
	SignalBus.fish_hooked.connect(_on_fish_hooked)
	SignalBus.minigame_completed.connect(_on_minigame_completed)


func _process(_delta: float) -> void:
	update_sprite()


func _physics_process(delta):
	update_inputs()
	sm.run(delta)
	move_and_slide()
	
	castLabel.text = str(cast_power)
	posLabel.text = str("%.1f" % global_position.x, ", ",  "%.1f" % global_position.y)

func _on_minigame_completed(_got_caught, _fish: FishData):
	if _fish:
		if _fish.mooch_bait != null:
			# print_debug('got new bait!')
			add_to_inventory(_fish.mooch_bait)

func _on_fish_bited():
	remove_from_inventory()

func _on_fish_hooked(_fish: FishData):
	pass
	# print_debug('Caught a ', _fish.name)

func spawn_tackle(_dir := Vector2.ZERO):
	var tackle: Tackle = TACKLE_TSCN.instantiate()
	tackle_instance = tackle
	tackle.init(self)
	
	get_parent().add_child(tackle)
	
	tackle.launch(cast_power, _dir)


func despawn_tackle():
	if tackle_instance: 
		tackle_instance.call_deferred("queue_free")
		tackle_instance = null


func add_to_inventory(bait: BaitData = null):
	if bait:
		var item = {
			"data": bait,
			"units": 1
		}
		for i in inventory:
			if i.data.id == item.data.id:
				i.units += 1
				menu.update_inventory()
				return
				
		inventory.push_back(item)
		menu.update_inventory()


func remove_from_inventory():
	if selected_bait:
		for i in inventory:
			if i.data.id == selected_bait.id:
				i.units -= 1
				if i.units == 0:
					inventory.erase(i.data.id)
				break
				
	menu.update_inventory()


var bait_inventory_id = 0
func change_bait(dirv_x):
	bait_inventory_id = int((bait_inventory_id + dirv_x)) % inventory.size()
	
	selected_bait = inventory[abs(bait_inventory_id)].data
	menu.update_inventory()


func update_inputs():
	inputs.dirv = Input.get_vector("left", "right", "up", "down")
	
	for i_p in inputs.pressed:
		inputs.pressed[i_p] = Input.is_action_pressed(i_p)
		
	for i_jp in inputs.just_pressed:
		inputs.just_pressed[i_jp] = Input.is_action_just_pressed(i_jp)
		
	for i_jr in inputs.just_released:
		inputs.just_released[i_jr] = Input.is_action_just_released(i_jr)


func get_input(input_name: String, state_name: String = 'just_pressed'):
	if input_name == 'dirv':
		return inputs[input_name]
	return inputs[state_name][input_name]


func update_sprite():
	var vel: Vector2 = get_real_velocity()
	
	if vel.length() < CHANGE_SPRITE_TRESHOLD:
		return
	
	var highest_dot = vel.dot(Vector2.RIGHT)
	var most_aligned: int = 0
	
	var this_dot = vel.dot(Vector2.DOWN) + 20.0
	if this_dot > highest_dot:
		highest_dot = this_dot
		most_aligned = 1
	
	this_dot = vel.dot(Vector2.UP) + 20.0
	if this_dot > highest_dot:
		highest_dot = this_dot
		most_aligned = 3
	
	this_dot = vel.dot(Vector2.LEFT)
	if this_dot > highest_dot:
		most_aligned = 2
	
	$sprite.frame = most_aligned


func _on_area_2d_body_entered(body):
	if body is TileMapLayer:
		var zone: SpawnZone = body.get_parent()
		SignalBus.zone_entered.emit(zone.zone_name)
