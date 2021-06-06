extends Control

var scene_path_to_load
#var scene_to_load

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://Scenes/Title_Screen/TitleScreen.tscn")
func _on_ExitButton_pressed():
	get_tree().quit()

#Lo de abajo es para hacer que se dispare un fade a la hora de darle un click a ago

#func _on_Button_pressed(scene_to_load):
#	scene_path_to_load = scene_to_load
#	$FadeIn.show()
#	$FadeIn.fade_in()
#
#func _on_FadeIn_fade_finished():
#	get_tree().change_scene("scene_path_to_load")
	


