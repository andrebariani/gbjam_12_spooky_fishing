extends Control

@onready var timerLabel = $Background/TimeBox/MarginContainer/Time
@onready var regionLabel = $Background/BaitMenu/BgRegion/RegionContainer/HBoxContainer3/Region
@onready var baitLabel = $Background/MarginContainer/HBoxContainer2/HBoxContainer/BaitName
@onready var baitIcon = $Background/BaitMenu/BaitIcon

@onready var newFishGot = $FishResult
@onready var gallery = $Gallery

@onready var anim = $AnimationPlayer

@onready var player: PlayerBoat = null

func init(_player):
	player = _player
	newFishGot.init(self)


func _ready():
	SignalBus.zone_entered.connect(_on_zone_entered)
	SignalBus.minigame_completed.connect(_on_minigame_completed)

var start = false
var gallery_open = false
#var select = false
func _physics_process(_delta):
	timerLabel.text = "%02d:%02d" % [WorldTime.hours, WorldTime.minutes]
	
	start = Input.is_action_just_released('select')
	
	if start:
		show_gallery()


func show_gallery():
	if not gallery_open:
		gallery.visible = true
		open_menu()
		gallery.show_galery()
		gallery_open = true
		start = false
	else:
		gallery.visible = false
		gallery_open = false
		start = false
		closed_menu()

func _on_zone_entered(zone_name):
	if zone_name != regionLabel.text:
		anim.stop()
		regionLabel.text = zone_name
		anim.play("region_change")


func _on_minigame_completed(_got_caught, fish: FishData):
	if _got_caught:
		newFishGot.visible = true
		newFishGot.set_title(str('New Fish! %s' % fish.name))
		newFishGot.set_fish_data(fish)


func open_menu():
	player.sm.end_current_state('Menu')

func closed_menu():
	player.sm.end_current_state('Idle')


func update_inventory():
	if player.selected_bait:
		baitLabel.visible = true
		baitIcon.visible = true
		baitLabel.text = player.selected_bait.name
		baitIcon.text = 'x'+str(player.inventory[player.bait_inventory_id].units)
		#baitIcon.icon = player.selected_bait.icon
	else:
		baitLabel.visible = false
		baitIcon.visible = false
	
