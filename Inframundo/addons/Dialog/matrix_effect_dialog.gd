extends DefaultDialog

onready var clean_spinBox		= $VBoxContainer/HBoxContainer/clean_SpinBox
onready var dirty_spinBox		= $VBoxContainer/HBoxContainer2/dirty_SpinBox
onready var span_spinBox		= $VBoxContainer/HBoxContainer3/span_SpinBox
onready var delay_spinBox		= $VBoxContainer/HBoxContainer2/delay_SpinBox

func _ready() -> void:
	clean_spinBox.get_line_edit().caret_blink = true
	dirty_spinBox.get_line_edit().caret_blink = true
	span_spinBox.get_line_edit().caret_blink = true
	delay_spinBox.get_line_edit().caret_blink = true

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	clean_spinBox.apply()
	dirty_spinBox.apply()
	span_spinBox.apply()
	delay_spinBox.apply()
	var c = clean_spinBox.value
	var d = dirty_spinBox.value
	var s = span_spinBox.value
	var dl = delay_spinBox.value
	var text = {}
	text["begin_text"]	= "[matrix clean=%s dirty=%s span=%s delay=%s]" % \
		[c, d, s, dl]
	text["end_text"]	= "[/matrix]"
	emit_signal("OK", text, dialog_id)


func _on_matrix_effect_dialog_visibility_changed() -> void:
	if visible and clean_spinBox:
		yield(get_tree(), "idle_frame")
		var lineedit = clean_spinBox.get_line_edit()
		lineedit.select_all()
		lineedit.caret_position = lineedit.text.length()
		lineedit.grab_focus()
		

func _on_Cancel_Button_focus_exited() -> void:
	yield(get_tree(), "idle_frame")
	clean_spinBox.get_line_edit().grab_focus()


func set_parameters(parameters):
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"clean": clean_spinBox.value = float(param[1])
				"dirty": dirty_spinBox.value = float(param[1])
				"span": span_spinBox.value = float(param[1])
				"delay": delay_spinBox.value = float(param[1])

