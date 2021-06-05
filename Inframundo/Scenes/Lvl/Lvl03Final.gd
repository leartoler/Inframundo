extends Area2D
func _on_Lvl03Final_body_entered(body):
	if body.is_in_group("arbol"):
		get_tree().change_scene("res://Scenes/Lvl/Lvl_04.tscn")
		
		


func _on_Lvl03Final_body_exited(body):
	if body.is_in_group("arbol"):
		body.dialog_id = null
		
func animation():
	$anim.play("Dialogo")
