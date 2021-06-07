extends Control

var scene_path_to_load
#var scene_to_load

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://Scenes/Lvl/Lvl_01.tscn")
func _on_ExitButton_pressed():
	get_tree().quit()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
