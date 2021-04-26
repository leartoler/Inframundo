extends Panel

onready var variable_name		= $VBoxContainer/HBoxContainer/Label2
onready var value_container		= $VBoxContainer/value_container

var variable
var last_focus
var resume_data

signal delete_variable_request(object)
signal select_parent_request()

func set_variable(_var):
	variable = _var.duplicate(true)
	variable.operation_type = 0
	variable_name.text = variable.name
	create_variable_for_type()
	
func get_variable():
	if variable.type == 1 or variable.type == 2:
		value_container.get_child(1).apply()
	return variable

func create_variable_for_type():
	match variable.type:
		0: create_line_edit(variable.value)
		1: create_int_spinbox(variable.value)
		2: create_float_spinbox(variable.value)
		3: create_checkbox(variable.value)


func create_line_edit(value):
	var c := LineEdit.new()
	c.set("custom_fonts/font", variable_name.get("custom_fonts/font"))
	c.caret_blink = true
	c.text = value
	c.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	c.connect("text_changed", self, "update_variable", ["value"])
	c.connect("focus_entered", self, "select_parent")
	value_container.add_child(c)
	resume_data = [0, c]
	$Timer.start()

func create_int_spinbox(value):
	var c := SpinBox.new()
	c.allow_greater = true
	c.allow_lesser = true
	c.value = value
	c.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	var lineedit = c.get_line_edit()
	lineedit.caret_blink = true
	c.connect("value_changed", self, "update_variable", ["value"])
	lineedit.connect("focus_entered", self, "select_parent")
	value_container.add_child(c)
	create_operations_options()
	resume_data = [1, lineedit]
	$Timer.start()

func create_float_spinbox(value):
	var c := SpinBox.new()
	c.allow_greater = true
	c.allow_lesser = true
	c.step = 0.1
	c.value = value
	c.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	var lineedit = c.get_line_edit()
	lineedit.caret_blink = true
	c.connect("value_changed", self, "update_variable", ["value"])
	lineedit.connect("focus_entered", self, "select_parent")
	value_container.add_child(c)
	create_operations_options()
	lineedit.select_all()
	lineedit.caret_position = lineedit.text.length()
	lineedit.grab_focus()

func create_checkbox(value):
	var c := CheckBox.new()
	c.text = "enabled?"
	c.pressed = value
	c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	c.connect("toggled", self, "update_variable", ["value"])
	c.connect("focus_entered", self, "select_parent")
	value_container.add_child(c)

func create_operations_options():
	var c:= OptionButton.new()
	var items = ["= Set", "+ Add", "- Subtract", "* Multiply", "/ Divide"]
	for item in items:
		c.add_item(item)
	c.clip_text = true
	c.rect_min_size.x = 40
	c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	c.select(0)
	c.connect("item_selected", self, "update_variable", ["operation"])
	c.connect("focus_entered", self, "select_parent")
	value_container.add_child(c)
	value_container.move_child(c, 0)

func update_variable(_value, type):
	if type == "value":
		variable.value = _value
	else:
		variable.operation_type = _value
		yield(get_tree(), "idle_frame")
		var lineedit = value_container.get_child(1).get_line_edit()
		lineedit.caret_position = lineedit.text.length()
		lineedit.select_all()
		lineedit.grab_focus()

func _on_deleteButton_button_down() -> void:
	emit_signal("delete_variable_request", self)


func _on_VBoxContainer_item_rect_changed() -> void:
	rect_min_size.x = $VBoxContainer.rect_size.x + 12


func select_parent():
	var last_focus = get_focus_owner()
	emit_signal("select_parent_request")
	if last_focus == null: return
	get_node("Timer").start()



func _on_Timer_timeout() -> void:
	if is_inside_tree():
		if resume_data != null:
			if resume_data[0] == 0:
				resume_data[1].select_all()
				resume_data[1].caret_position = resume_data[1].text.length()
				resume_data[1].grab_focus()
			elif resume_data[0] == 1:
				resume_data[1].select_all()
				resume_data[1].caret_position = resume_data[1].text.length()
				resume_data[1].grab_focus()
			resume_data = null
		else:
			if last_focus == null: return
			if is_instance_valid(last_focus):
				last_focus.grab_focus()
