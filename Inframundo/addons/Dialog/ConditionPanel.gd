extends Panel

onready var value_container		= $VBoxContainer/HBoxContainer4/value_container
onready var variable_c1 = find_node("variable_c1")
onready var variable_c2 = find_node("variable_c2")
onready var variable_c3 = find_node("variable_c3")
onready var checkbox_c1 = find_node("checkbox_c1")
onready var checkbox_c2 = find_node("checkbox_c2")

var condition
var current_var
var variables = {
	"a"	: null,
	"b" : null
}
var last_focus
var resume_data

signal open_select_variable_request(obj)
signal delete_condition_request(object)
signal select_parent_request()

func _ready() -> void:
	variable_c1.connect("gui_input", self,
		"show_get_variable_dialog_request", [variable_c1])
	variable_c1.connect("mouse_entered", self, "change_style",
		[variable_c1, "over"])
	variable_c1.connect("mouse_exited", self, "change_style",
		[variable_c1, "out"])
	variable_c3.connect("gui_input", self,
		"show_get_variable_dialog_request", [variable_c3])
	variable_c3.connect("mouse_entered", self, "change_style",
		[variable_c3, "over"])
	variable_c3.connect("mouse_exited", self, "change_style",
		[variable_c3, "out"])

func add_variable(_var):
	if current_var == variable_c1:
		set_variable_a(_var)
	else:
		set_variable_b(_var)
	current_var = null

func fill_check_types(type):
	var id = variable_c2.get_selected_id()
	variable_c2.clear()
	var data
	match type:
		0: # String
			data = ["= Equal to", "< less than", "> greater than", "!= different to"]
			
		1, 2: # Int and Float
			data = ["= Equal to", "< less than", "<= less than or equal to",
				"> greater than", ">= greater thanor equal to", "!= different to"]
		3: # Bool
			data = ["= Equal to", "!= different to"]
	for o in data:
		variable_c2.add_item(o)
	variable_c2.select(max(0, min(id, data.size() - 1)))
	variable_c2.disabled = false

func set_variable_a(_var):
	var is_same_type = (variables.a != null and variables.a.type == _var.type)
	variables.a = _var
	var n = "%s  (%s)" % [
		_var.name,
		get_name_of_type(_var.type)
	]
	variable_c1.text = n
	checkbox_c1.disabled = false
	checkbox_c2.disabled = false
	variable_c3.modulate = Color.white
	fill_check_types(_var.type)
	match _var.type:
		0: if !is_same_type: create_string_value() # String
		1, 2: if !is_same_type: create_numeric_value(_var.type) # Int and Float
		3: if !is_same_type: create_bool_value() # Bool
		
	if variables.b != null and variables.b.type != variables.a.type:
		variables.b = null
		variable_c3.text = ""
		if value_container.get_child_count() > 0:
			value_container.get_child(0).queue_free()
		variable_c3.modulate = Color(0.411765, 0.411765, 0.411765, 0.301961)
	if variables.b == null:
		checkbox_c1.pressed = false
		checkbox_c1.emit_signal("toggled", false)
		checkbox_c2.pressed = true
		checkbox_c2.emit_signal("toggled", true)
	else:
		checkbox_c1.emit_signal("toggled", checkbox_c1.pressed)
		checkbox_c2.emit_signal("toggled", checkbox_c2.pressed)

func set_variable_b(_var):
	variables.b = _var
	var n = "%s  (%s)" % [
		_var.name,
		get_name_of_type(_var.type)
	]
	variable_c3.text = n

func get_name_of_type(type) -> String:
	var n = ""
	match type:
		0: n =  "STRING"
		1: n =  "INT"
		2: n =  "FLOAT"
		3: n =  "BOOLEAN"
	return n

func create_string_value():
	if value_container.get_child_count() > 0:
		value_container.get_child(0).queue_free()
	var c := LineEdit.new()
	c.caret_blink = true
	c.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	c.connect("text_changed", self, "update_condition", ["value"])
	c.connect("focus_entered", self, "select_parent")
	value_container.add_child(c)
	
func create_numeric_value(type):
	if value_container.get_child_count() > 0:
		value_container.get_child(0).queue_free()
	var c := SpinBox.new()
	c.allow_greater = true
	c.allow_lesser = true
	c.value = 0
	c.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	if type == 2:
		c.step = 0.1
	var lineedit = c.get_line_edit()
	lineedit.caret_blink = true
	c.connect("value_changed", self, "update_condition", ["value"])
	lineedit.connect("focus_entered", self, "select_parent")
	value_container.add_child(c)

func create_bool_value():
	if value_container.get_child_count() > 0:
		value_container.get_child(0).queue_free()
	var c := CheckBox.new()
	c.text = "enabled?"
	c.pressed = true
	c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	c.connect("toggled", self, "update_condition", ["value"])
	c.connect("focus_entered", self, "select_parent")
	value_container.add_child(c)

func set_condition(condition):
	variables = condition.variables
	if variables.a != null:
		set_variable_a(variables.a)
		match variables.a.type:
			0: # String
				create_string_value()
				value_container.get_child(0).text = condition.value
			1, 2: # Int and Float
				create_numeric_value(variables.a.type)
				value_container.get_child(0).value = condition.value
			3: # Bool
				create_bool_value()
				value_container.get_child(0).pressed = condition.value
		fill_check_types(variables.a.type)
	if variables.b != null:
		set_variable_b(variables.b)
	if variable_c2.get_item_count() - 1 >= condition.check_type:
		variable_c2.select(condition.check_type)
	checkbox_c1.disabled = variables.a == null
	checkbox_c2.disabled = variables.a == null
	if condition.value_type == 0:
		checkbox_c1.pressed = true
		checkbox_c1.emit_signal("toggled", true)
		checkbox_c2.emit_signal("toggled", false)
	else:
		checkbox_c2.pressed = true
		checkbox_c2.emit_signal("toggled", true)
		checkbox_c1.emit_signal("toggled", false)
	if condition.extra_condition != null:
		set_extra_condition(true)
		find_node("ExtraCondition").select(condition.extra_condition)
	else:
		set_extra_condition(false)
	
func get_condition():
	var value = null
	if variables.a != null:
		match variables.a.type:
			0: value = value_container.get_child(0).text # String
			1, 2: # Int and Float
				var child = value_container.get_child(0)
				child.apply()
				value = child.value
			3: value = value_container.get_child(0).pressed # bool
	var value_type = 0 if checkbox_c1.pressed else 1
	var extra_condition
	if find_node("ExtraConditionContainer").visible:
		extra_condition = find_node("ExtraCondition").get_selected_id()
	var condition = {
		"variables"			: variables,
		"check_type"		: variable_c2.get_selected_id(),
		"value_type"		: value_type,
		"value"				: value,
		"extra_condition"	: extra_condition
	}
	return condition

func _on_deleteButton_button_down() -> void:
	emit_signal("delete_condition_request", self)


func _on_VBoxContainer_item_rect_changed() -> void:
	rect_min_size.x = $VBoxContainer.rect_size.x + 12


func select_parent():
	if is_inside_tree():
		var last_focus = get_focus_owner()
		emit_signal("select_parent_request")
		if last_focus == null: return
		get_node("Timer").start()

func show_get_variable_dialog_request(event: InputEvent, obj = null) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and \
		event.is_pressed():
		current_var = obj
		if obj == variable_c3:
			if variables.a == null or !checkbox_c1.pressed:
				current_var = null
				return
			emit_signal("open_select_variable_request", self, variables.a.type)
		else:
			emit_signal("open_select_variable_request", self)
		

func change_style(obj : LineEdit, type):
	var c1; var c2;
	if type == "over":
		c1 = Color(0.188416, 0.492188, 0)
	else:
		c1 = Color("000000")
	obj.add_color_override("font_color_uneditable", c1)


func _on_checkbox_c1_toggled(button_pressed: bool) -> void:
	if button_pressed:
		variable_c3.modulate = Color.white
	else:
		variable_c3.modulate = Color(0.411765, 0.411765, 0.411765, 0.301961)
	select_parent()

func _on_checkbox_c2_toggled(button_pressed: bool) -> void:
	if value_container.get_child_count() > 0:
		if button_pressed:
			var resume_data = true
			$Timer.start()
		else:
			var child = value_container.get_child(0)
			if child is CheckBox:
				child.disabled = true
			else:
				child.editable = false
	select_parent()


func update_condition(value, type):
	select_parent()

func set_extra_condition(value = true):
	var node = find_node("ExtraConditionContainer")
	if value:
		node.visible = true
		self.rect_min_size.y = 185
		self.rect_size.y = 185
	else:
		node.visible = false
		self.rect_min_size.y = 167
		self.rect_size.y = 167


func _on_Timer_timeout() -> void:
	if is_inside_tree():
		if resume_data != null:
			var child = value_container.get_child(0)
			if child is SpinBox:
				child = child.get_line_edit()
			if child is LineEdit:
				child.editable = true
				child.caret_position = child.text.length()
				child.select_all()
				if child.is_inside_tree():
					child.grab_focus()
			else:
				child.disabled = false
				if child.is_inside_tree():
					child.grab_focus()
			resume_data = null
		else:
			if last_focus == null: return
			if is_instance_valid(last_focus):
				last_focus.grab_focus()
