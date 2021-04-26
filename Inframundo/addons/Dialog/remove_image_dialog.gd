extends DefaultDialog

onready var character_id_container		= $VBoxContainer/Control
onready var character_id_spinbox		= $VBoxContainer/Control/HBoxContainer2/character_id_SpinBox
onready var character_options			= $VBoxContainer/OptionButton

func _ready() -> void:
	character_id_spinbox.get_line_edit().caret_blink = true

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	var text = {}
	var s = ""
	if character_id_container.visible:
		s += "type=1"
		character_id_spinbox.apply()
		s += " id=%s" % character_id_spinbox.value
	else:
		s += "type=0"
	text["begin_text"]	= "[remove_image %s]" % s
	text["end_text"]	= ""
	emit_signal("OK", text, dialog_id)


func _on_type_OptionButton_item_selected(index: int) -> void:
	if index == 1:
		character_id_container.visible = true
		yield(get_tree(), "idle_frame")
		var lineedit = character_id_spinbox.get_line_edit()
		lineedit.caret_position = lineedit.text.length()
		lineedit.select_all()
		lineedit.grab_focus()
		rect_size.y = 138
	else:
		character_id_container.visible = false
		yield(get_tree(), "idle_frame")
		get_node("VBoxContainer/HBoxContainer3/OK_Button").grab_focus()
		rect_size.y = 103

func set_parameters(parameters):
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"type": character_options.select(max(0, min(int(param[1]),
					character_options.get_item_count()-1)))
				"id": character_id_spinbox.value = int(param[1])
	_on_type_OptionButton_item_selected(character_options.get_selected_id())
