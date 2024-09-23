extends Control


func _ready() -> void:
	$Background/Button.grab_focus()

var pressed = false
func _on_button_pressed() -> void:
	if not pressed:
		pressed = true
		$sfx.play(0.0)
		$music.stop()
		$AnimationPlayer.play("start")


func _on_animation_player_animation_finished(_anim_name):
	get_tree().change_scene_to_file("res://scenes/test_scene.tscn")
