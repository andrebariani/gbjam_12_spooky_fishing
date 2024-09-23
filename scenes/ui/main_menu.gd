extends Control


func _ready() -> void:
	$Background/Button.grab_focus()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/test_scene.tscn")
