extends Control


var entity = null
func init(_e):
	entity = _e

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func set_title(title: String) -> void:
	%Title.text = title


func set_fish_data(fish_data: FishData) -> void:
	%Title.text = fish_data.name
	%Description.text = fish_data.description
	%Photo.texture = fish_data.galery_photo


func _on_close_pressed() -> void:
	self.hide()
	entity.closed_menu()


func _on_close_draw() -> void:
	%Close.grab_focus()
