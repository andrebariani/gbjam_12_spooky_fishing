extends Control

@onready var timerLabel = $Background/TimeBox/MarginContainer/Time
@onready var regionLabel = $Background/BaitMenu/BgRegion/RegionContainer/HBoxContainer3/Region
@onready var baitLabel = $Background/MarginContainer/HBoxContainer2/HBoxContainer/BaitName
@onready var baitIcon = $Background/BaitMenu/BaitIcon
@onready var newFishGot = $FishResult

@onready var anim = $AnimationPlayer

@onready var player: PlayerBoat = null

func init(_player):
	player = _player
	newFishGot.init(self)


func _ready():
	SignalBus.zone_entered.connect(_on_zone_entered)
	SignalBus.minigame_completed.connect(_on_minigame_completed)


func _physics_process(_delta):
	timerLabel.text = "%02d:%02d" % [WorldTime.hours, WorldTime.minutes]

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


func closed_menu():
	player.run_input = true


func update_inventory():
	if player.selected_bait:
		baitLabel.visible = true
		baitIcon.visible = true
		baitLabel.text = player.selected_bait.name
		baitIcon.text = 'x'+str(player.inventory[player.bait_inventory_id].units)
		baitIcon.icon = player.selected_bait.icon
	else:
		baitLabel.visible = false
		baitIcon.visible = false
	
