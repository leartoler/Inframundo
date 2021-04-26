extends DefaultDialog

onready var time_spinBox			= $VBoxContainer/HBoxContainer/time_SpinBox
onready var auto_continue_checkBox	= $VBoxContainer/HBoxContainer2/auto_continue_CheckBox

func _ready() -> void:
	time_spinBox.get_line_edit().caret_blink = true

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	time_spinBox.apply()
	var t = time_spinBox.value
	var a = str(auto_continue_checkBox.pressed).to_lower()
	var text = {}
	text["begin_text"]	= "[pause time=%s auto_continue=%s] " % [t, a]
	text["end_text"]	= ""
	emit_signal("OK", text, dialog_id)


func _on_pause_dialog_visibility_changed() -> void:
	if visible and time_spinBox:
		yield(get_tree(), "idle_frame")
		var lineedit = time_spinBox.get_line_edit()
		lineedit.select_all()
		lineedit.caret_position = lineedit.text.length()
		lineedit.grab_focus()
		

func _on_Cancel_Button_focus_exited() -> void:
	yield(get_tree(), "idle_frame")
	time_spinBox.get_line_edit().grab_focus()

func set_parameters(parameters):
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"time": time_spinBox.value = float(param[1])
				"auto_continue":
					auto_continue_checkBox.pressed = param[1].to_lower() == "true"


