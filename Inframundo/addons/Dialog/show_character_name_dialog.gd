extends DefaultDialog

onready var control_0		= $VBoxContainer/OptionButton

var characters = []

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	var text = {}
	var character_id = control_0.get_selected_id()
	text["begin_text"]	= "[character_name=%s]" % character_id
	text["end_text"]	= ""
	emit_signal("OK", text, dialog_id)


func _on_emit_signal_dialog_visibility_changed() -> void:
	if visible and control_0:
		fill_character_names()

func fill_character_names():
	var index = control_0.get_selected_id()
	control_0.clear()
	if characters.size() > 0:
		for i in characters.size():
			var n = "%s: %s" % [i, characters[i].name]
			control_0.add_item(n)
		control_0.select(min(index, characters.size() - 1))
		control_0.disabled = false
	else:
		control_0.text = "No variables found"
		control_0.disabled = true


func _on_OptionButton_item_selected(index: int) -> void:
	yield(get_tree(), "idle_frame")
	get_node("VBoxContainer/HBoxContainer3/OK_Button").grab_focus()


func set_parameters(parameters):
	fill_character_names()
	if control_0.get_item_count() == 0: return
	control_0.select(min(0, max(int(parameters[0]),
		control_0.get_item_count() - 1)))
