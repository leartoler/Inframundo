extends DefaultDialog

onready var control_0		= $VBoxContainer/OptionButton

var signals = []

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	var text = {}
	var index = control_0.get_selected_id()
	if index <= signals.size() - 1 and index >= 0:
		text["begin_text"]	= "[emit_signal id=%s]" % index
		text["end_text"]	= ""
	else:
		text = null
	emit_signal("OK", text, dialog_id)


func _on_emit_signal_dialog_visibility_changed() -> void:
	if visible and control_0:
		fill_signals()

func fill_signals():
	var index = control_0.get_selected_id()
	control_0.clear()
	if signals.size() > 0:
		for s in signals:
			control_0.add_item("Signal - %s" % s)
		control_0.select(min(index, signals.size() - 1))
		control_0.disabled = false
	else:
		control_0.text = "No signals found"
		control_0.disabled = true
		


func _on_OptionButton_item_selected(index: int) -> void:
	yield(get_tree(), "idle_frame")
	get_node("VBoxContainer/HBoxContainer3/OK_Button").grab_focus()

func set_parameters(parameters):
	fill_signals()
	if control_0.get_item_count() == 0: return
	for i in range(0, parameters.size()):
			var param = parameters[i].split("=")
			if param.size() >= 2:
				match param[0]:
					"id" :
						var id = max(0, min(int(param[1]),
							control_0.get_item_count() - 1))
						control_0.select(id)


