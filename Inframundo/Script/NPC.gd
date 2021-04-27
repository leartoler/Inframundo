extends Area2D
export(int) var dialog = 0


func _on_NPC_body_entered(body):
	if body.is_in_group("arbol"):
		body.dialog_id = dialog
		

func _on_NPC_body_exited(body):
	if body.is_in_group("arbol"):
		body.dialog_id = null
		



func _on_Salida_body_entered(body):
	pass # Replace with function body.
