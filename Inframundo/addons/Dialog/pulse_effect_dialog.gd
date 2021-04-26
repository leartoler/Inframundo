extends DefaultDialog

onready var color_button		= $VBoxContainer/HBoxContainer/ColorPickerButton
onready var freq_spinBox		= $VBoxContainer/HBoxContainer30/freq_SpinBox

func _ready() -> void:
	freq_spinBox.get_line_edit().caret_blink = true

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	freq_spinBox.apply()
	var c = color_button.color.to_html()
	var f = freq_spinBox.value
	var text = {}
	text["begin_text"]	= "[pulse color=#%s freq=%s]" % [c, f]
	text["end_text"]	= "[/pulse]"
	emit_signal("OK", text, dialog_id)


func _on_pulse_effect_dialog_visibility_changed() -> void:
	if visible and freq_spinBox:
		yield(get_tree(), "idle_frame")
		var lineedit = freq_spinBox.get_line_edit()
		lineedit.select_all()
		lineedit.caret_position = lineedit.text.length()
		lineedit.grab_focus()


func _on_Cancel_Button_focus_exited() -> void:
	yield(get_tree(), "idle_frame")
	freq_spinBox.get_line_edit().grab_focus()


func _on_ColorPickerButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		yield(get_tree(), "idle_frame")
		var popup = color_button.get_popup()
		var pos = get_global_mouse_position()
		popup.rect_global_position = pos - popup.rect_size * 0.5
		var child = popup.get_child(0)
		child.rect_global_position = pos - child.rect_size * 0.5


func set_parameters(parameters):
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"color": color_button.color = Color(param[1])
				"freq": freq_spinBox.value = float(param[1])

