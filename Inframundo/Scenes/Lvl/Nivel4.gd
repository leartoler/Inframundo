extends Area2D

func _on_Nivel4_body_entered(body):
	if body.is_in_group("arbol"):
		get_tree().change_scene("res://Scenes/Lvl/Lvl_05.tscn")

func _on_Nivel4_body_exited(body):
	if body.is_in_group("arbol"):
		body.dialog_id = null
		
func animation():
	$anim.play("Dialogo")
