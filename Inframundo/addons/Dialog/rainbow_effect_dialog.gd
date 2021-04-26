extends DefaultDialog

onready var freq_spinBox		= $VBoxContainer/HBoxContainer/freq_SpinBox
onready var sat_spinBox			= $VBoxContainer/HBoxContainer2/sat_SpinBox
onready var val_spinBox			= $VBoxContainer/HBoxContainer3/val_SpinBox

func _ready() -> void:
	freq_spinBox.get_line_edit().caret_blink = true
	sat_spinBox.get_line_edit().caret_blink = true
	val_spinBox.get_line_edit().caret_blink = true

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	freq_spinBox.apply()
	sat_spinBox.apply()
	val_spinBox.apply()
	var freq = freq_spinBox.value
	var sat = sat_spinBox.value
	var val = val_spinBox.value
	var text = {}
	text["begin_text"]	= "[rainbow freq=%s sat=%s val=%s]" % [freq, sat, val]
	text["end_text"]	= "[/rainbow]"
	emit_signal("OK", text, dialog_id)


func _on_rainbow_effect_dialog_visibility_changed() -> void:
	if visible and freq_spinBox:
		yield(get_tree(), "idle_frame")
		var lineedit = freq_spinBox.get_line_edit()
		lineedit.select_all()
		lineedit.caret_position = lineedit.text.length()
		lineedit.grab_focus()


func _on_Cancel_Button_focus_exited() -> void:
	yield(get_tree(), "idle_frame")
	freq_spinBox.get_line_edit().grab_focus()


func set_parameters(parameters):
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"freq": freq_spinBox.value = float(param[1])
				"sat": sat_spinBox.value = float(param[1])
				"val": val_spinBox.value = float(param[1])

