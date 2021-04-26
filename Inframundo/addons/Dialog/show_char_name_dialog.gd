extends DefaultDialog

onready var lineedit		= $VBoxContainer/HBoxContainer/LineEdit
onready var control_0		= $VBoxContainer/OptionButton
onready var control_1		= $VBoxContainer/OptionButton2
onready var control_2		= $VBoxContainer/OptionButton3
onready var control_3		= $VBoxContainer/HBoxContainer
onready var control_4		= $VBoxContainer/HBoxContainer2/OptionButton

var variables = []
var characters = []

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	var text = {}
	var a = control_4.get_selected_id()
	var b = control_0.get_selected_id()
	var c = get_data()
	if c != null:
		text["begin_text"]	= "[show_box_name type=%s sub_type=%s %s]" % [a, b, c]
		text["end_text"]	= ""
	else:
		text = null
	emit_signal("OK", text, dialog_id)

func get_data() -> String:
	var s = null
	match control_0.get_selected_id():
		0: if characters.size() > 0: s = "id=%s" % control_1.get_selected_id()
		1: if variables.size() > 0: s = "id=%s" % control_2.get_selected_id()
		2: if lineedit.text.length() > 0:
				s = "name=%s" % lineedit.text.replace(" ", "■")
	return s

func _on_show_char_name_dialog_visibility_changed() -> void:
	if visible:
		fill_options_buttons()
		if control_1.visible and characters.size() == 0:
			control_1.visible = false
			control_2.visible = true
			control_0.select(1)
		if control_2.visible and variables.size() == 0:
			control_2.visible = false
			control_3.visible = true
			control_0.select(2)
		if control_3.visible:
			select_lineedit()
	else:
		variables = []
		characters = []

func fill_options_buttons():
	# Fill characters
	var index = control_1.get_selected_id()
	control_1.clear()
	if characters.size() > 0:
		for character in characters:
			control_1.add_item(character.name)
		control_1.select(min(index, characters.size() - 1))
		control_1.disabled = false
	else:
		control_1.text = "No Characters available"
		control_1.disabled = true
	# Fill variables
	index = control_2.get_selected_id()
	control_2.clear()
	if variables.size() > 0:
		for variable in variables:
			control_2.add_item("Variable - %s" % variable.name)
		control_2.select(min(index, variables.size() - 1))
		control_2.disabled = false
	else:
		control_2.text = "No Variables available"
		control_2.disabled = true

func _on_OptionButton_item_selected(index: int) -> void:
	control_1.visible = false
	control_2.visible = false
	control_3.visible = false
	match index:
		0:
			control_1.visible = true
			yield(get_tree(), "idle_frame")
			control_1.grab_focus()
		1:
			control_2.visible = true
			yield(get_tree(), "idle_frame")
			control_2.grab_focus()
		2:
			control_3.visible = true
			select_lineedit()
		
func select_lineedit():
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	lineedit.caret_position = lineedit.text.length()
	lineedit.select_all()
	lineedit.grab_focus()



func _on_type_OptionButton_item_selected(index: int) -> void:
	yield(get_tree(), "idle_frame")
	get_node("VBoxContainer/HBoxContainer3/OK_Button").grab_focus()


func set_parameters(parameters):
	var selectedIndex = null
	var id = null
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"type" : control_4.select(max(0, min(int(param[1]),
					control_4.get_item_count() - 1)))
				"sub_type":
					control_0.select(max(0, min(int(param[1]),
						control_0.get_item_count() - 1)))
					selectedIndex = control_0.get_selected_id()
				"name":
					lineedit.text = param[1].replace("■", " ")
					lineedit.text.replace(" ", "■")
				"id": id = int(param[1])
	if id != null and selectedIndex != null:
		if selectedIndex != null: control_1.select(selectedIndex)
		elif id != null: control_2.select(id)
	_on_OptionButton_item_selected(control_0.get_selected_id())


