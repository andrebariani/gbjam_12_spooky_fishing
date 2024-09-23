extends Control

@export var fishes: Array[FishData]

func _ready() -> void:
	SignalBus.minigame_completed.connect(add_fish_to_list)
	setup_buttons()
	#_on_button_pressed_test()


func add_fish_to_list(should_add: bool, fish_data: FishData) -> void:
	if should_add:
		var idx = fishes \
		.map(func(fish): return fish.id) \
		.find(fish_data.id)
		
		var fish_button = (%FishList.get_child(idx) as Button)
		
		if fish_button.disabled:
			fish_button.text = fish_data.name
			fish_button.disabled = false


func show_galery():
	if %FishList.get_child_count() > 0:
		%FishList.get_child(0).grab_focus()


func _on_button_focus_entered() -> void:
	var buttons: Array[Node] = %FishList.get_children()
	
	for idx in range(buttons.size()):
		if buttons[idx].has_focus() and not buttons[idx].visible:
			buttons[idx].set_visible(true)
			buttons[idx-4].set_visible(false)
			buttons[idx+4].set_visible(false)
			


func _on_button_pressed() -> void:
	var buttons: Array[Node] = %FishList.get_children()
	for idx in range(buttons.size()):
		if (buttons[idx] as Button).button_pressed:
			%FishDetails.set_fish_data(fishes[idx])
			%FishDetails.grab_focus()
			%FishDetails.show()
			


func _on_fish_details_hidden() -> void:
	show_galery()


func _on_button_pressed_test() -> void:
	var test = FishData.new()
	test.id = "jaca"
	test.name = "Jaca"
	add_fish_to_list(true, test)


func setup_buttons() -> void:
	for fish in fishes:
		var btn: Button = Button.new()
		btn.icon = fish.icon
		btn.disabled = true
		btn.text = "?????"
		btn.size_flags_horizontal = Control.SizeFlags.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_button_pressed)
		%FishList.add_child(btn)
