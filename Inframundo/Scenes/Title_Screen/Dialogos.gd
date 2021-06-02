extends Area2D
export(int) var dialog = 0




func _on_Dialogo_1_body_entered(body):
	if body.is_in_group("arbol"):
		body.dialog_id = dialog

func _on_Dialogo_1_body_exited(body):
	if body.is_in_group("arbol"):
		body.dialog_id = null
		queue_free()
		
