extends Control

@export var fishes: Array[FishData]

func _ready() -> void:
	SignalBus.minigame_completed.connect(add_fish_to_list)
	show_galery()


func add_fish_to_list(fish) -> void:
	print(fish)


func update_fish_list(fish_data: FishData) -> void:
	fishes.map(func(fish): return fish.id)

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
			%FishDetails.show()


func _on_fish_details_hidden() -> void:
	show_galery()
