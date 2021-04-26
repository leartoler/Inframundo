extends DefaultDialog

onready var control_0		= $VBoxContainer/OptionButton

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	var text = {}
	var a = control_0.get_selected_id()
	text["begin_text"]	= "[remove_box_name type=%s]" % a
	text["end_text"]	= ""
	emit_signal("OK", text, dialog_id)


func _on_OptionButton_item_selected(index: int) -> void:
	yield(get_tree(), "idle_frame")
	get_node("VBoxContainer/HBoxContainer3/OK_Button").grab_focus()


func set_parameters(parameters):
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"type":
					var id = max(0, min(int(param[1]),
						control_0.get_item_count() - 1))
					control_0.select(id)
