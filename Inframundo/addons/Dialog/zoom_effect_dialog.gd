extends DefaultDialog

onready var start_value_spinBox		= $VBoxContainer/HBoxContainer/start_value_SpinBox
onready var end_value_spinBox		= $VBoxContainer/HBoxContainer/end_value_SpinBox
onready var time_spinBox			= $VBoxContainer/HBoxContainer2/time_SpinBox
onready var loop_spinBox			= $VBoxContainer/HBoxContainer2/loop_SpinBox

func _ready() -> void:
	start_value_spinBox.get_line_edit().caret_blink = true
	end_value_spinBox.get_line_edit().caret_blink = true
	time_spinBox.get_line_edit().caret_blink = true
	loop_spinBox.get_line_edit().caret_blink = true

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	start_value_spinBox.apply()
	end_value_spinBox.apply()
	time_spinBox.apply()
	loop_spinBox.apply()
	var s = start_value_spinBox.value
	var e = end_value_spinBox.value
	var t = time_spinBox.value
	var l = loop_spinBox.value
	var text = {}
	text["begin_text"]	= "[zoom start=%s end=%s time=%s loop=%s]" % [s, e, t, l]
	text["end_text"]	= "[/zoom]"
	emit_signal("OK", text, dialog_id)


func _on_fade_animation_effect_dialog_visibility_changed() -> void:
	if visible and start_value_spinBox:
		yield(get_tree(), "idle_frame")
		var lineedit = start_value_spinBox.get_line_edit()
		lineedit.select_all()
		lineedit.caret_position = lineedit.text.length()
		lineedit.grab_focus()
		

func _on_Cancel_Button_focus_exited() -> void:
	yield(get_tree(), "idle_frame")
	start_value_spinBox.get_line_edit().grab_focus()


func set_parameters(parameters):
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"start": start_value_spinBox.value = float(param[1])
				"end": end_value_spinBox.value = float(param[1])
				"time": time_spinBox.value = float(param[1])
				"loop": loop_spinBox.value = int(param[1])

