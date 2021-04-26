extends DefaultDialog

onready var amp_spinBox		= $VBoxContainer/HBoxContainer/amp_SpinBox
onready var freq_spinBox	= $VBoxContainer/HBoxContainer2/freq_SpinBox

func _ready() -> void:
	amp_spinBox.get_line_edit().caret_blink = true
	freq_spinBox.get_line_edit().caret_blink = true

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	amp_spinBox.apply()
	freq_spinBox.apply()
	var amp = amp_spinBox.value
	var freq = freq_spinBox.value
	var text = {}
	text["begin_text"]	= "[wave amp=%s freq=%s]" % [amp, freq]
	text["end_text"]	= "[/wave]"
	emit_signal("OK", text, dialog_id)


func _on_wave_effect_dialog_visibility_changed() -> void:
	if visible and amp_spinBox:
		yield(get_tree(), "idle_frame")
		var lineedit = amp_spinBox.get_line_edit()
		lineedit.select_all()
		lineedit.caret_position = lineedit.text.length()
		lineedit.grab_focus()
		

func _on_Cancel_Button_focus_exited() -> void:
	yield(get_tree(), "idle_frame")
	amp_spinBox.get_line_edit().grab_focus()

func set_parameters(id, parameters):
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"amp", "radius", "rate", "start", "freq":
					if param[0] == "freq":
						if id == "ghost": amp_spinBox.value = float(param[1])
						elif id == "tornado": freq_spinBox.value = float(param[1])
					else:
						amp_spinBox.value = float(param[1])
				"level", "length", "span":
					freq_spinBox.value = float(param[1])
					

