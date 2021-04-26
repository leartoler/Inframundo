extends DefaultDialog

onready var fade_in_checkBox	= $VBoxContainer/HBoxContainer/fade_in_CheckBox
onready var fade_out_checkBox	= $VBoxContainer/HBoxContainer/fade_out_CheckBox
onready var time_spinBox		= $VBoxContainer/HBoxContainer2/time_SpinBox

func _ready() -> void:
	time_spinBox.get_line_edit().caret_blink = true

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	time_spinBox.apply()
	var t = time_spinBox.value
	var m = 0 if fade_in_checkBox.pressed else 1
	var text = {}
	text["begin_text"]	= "[fade_animation time=%s mode=%s]" % [t, m]
	text["end_text"]	= "[/fade_animation]"
	emit_signal("OK", text, dialog_id)


func _on_fade_animation_effect_dialog_visibility_changed() -> void:
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
				"mode":
					if int(param[1]) == 0:
						fade_in_checkBox.pressed = true
						fade_out_checkBox.pressed = false
					else:
						fade_in_checkBox.pressed = false
						fade_out_checkBox.pressed = true

