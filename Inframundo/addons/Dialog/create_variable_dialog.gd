extends DefaultDialog

onready var options_type 	= $VBoxContainer/OptionButton
onready var name_lineedit 	= $VBoxContainer/LineEdit
onready var value_container	= $VBoxContainer/Container
onready var rich_text_label	= $VBoxContainer/RichTextLabel

var value
var handled_event = false

func _ready() -> void:
	create_string_value()
	value_container.connect("item_rect_changed", self, "update_child_size")

func update_child_size() -> void:
	if value_container.get_child_count() > 0:
		var c = value_container.get_child(0)
		if c is LineEdit:
			c.rect_size = value_container.rect_size
			

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	var type = options_type.get_selected_id()
	if type == 1 or type == 2:
		var obj = value_container.get_child(0)
		obj.apply()
	var _name = name_lineedit.text
	var text = {}
	text["name"]	= _name
	text["type"]	= type
	text["value"]	= value
	emit_signal("OK", text, dialog_id)
		

func _on_Cancel_Button_focus_exited() -> void:
	pass


func _on_OptionButton_item_selected(index: int, _value = null) -> void:
	match index:
		0: create_string_value(_value) # String
		1: create_int_value(_value) # Int
		2: create_float_value(_value) # Float
		3: create_boolean_value(_value) # Boolean

func clear_value_container():
	for child in value_container.get_children():
		value_container.remove_child(child)
		child.queue_free()

func create_string_value(_value=null):
	clear_value_container()
	var c := LineEdit.new()
	c.set("custom_fonts/font", name_lineedit.get("custom_fonts/font"))
	c.connect("text_changed", self, "update_value")
	c.connect("gui_input", self, "_on_control2_gui_input")
	c.caret_blink = true
	c.rect_size.x = value_container.rect_size.x
	c.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	value_container.add_child(c)
	if _value == null:
		value = ""
	else:
		c.text = _value
		value = _value
	yield(get_tree(), "idle_frame")
	c.caret_position = c.text.length()
	c.select_all()
	c.grab_focus()
	
func create_int_value(_value=null):
	clear_value_container()
	var c := SpinBox.new()
	c.allow_greater = true
	c.allow_lesser = true
	c.get_line_edit().caret_blink = true
	c.connect("value_changed", self, "update_value")
	c.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	value_container.add_child(c)
	if _value == null:
		value = 0
	else:
		c.value = _value
		value = _value
	yield(get_tree(), "idle_frame")
	var lineedit = c.get_line_edit()
	lineedit.connect("gui_input", self, "_on_control2_gui_input")
	lineedit.caret_position = lineedit.text.length()
	lineedit.select_all()
	lineedit.grab_focus()
	
func create_float_value(_value=null):
	clear_value_container()
	var c := SpinBox.new()
	c.allow_greater = true
	c.allow_lesser = true
	c.step = 0.1
	c.get_line_edit().caret_blink = true
	c.connect("value_changed", self, "update_value")
	c.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	value_container.add_child(c)
	if _value == null:
		value = 0
	else:
		c.value = _value
		value = _value
	yield(get_tree(), "idle_frame")
	var lineedit = c.get_line_edit()
	lineedit.connect("gui_input", self, "_on_control2_gui_input")
	lineedit.caret_position = lineedit.text.length()
	lineedit.select_all()
	lineedit.grab_focus()
	
func create_boolean_value(_value=null):
	clear_value_container()
	var c := CheckBox.new()
	c.connect("toggled", self, "update_value")
	c.connect("gui_input", self, "_on_control2_gui_input")
	c.text = "enabled?"
	c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	value_container.add_child(c)
	if _value == null:
		value = false
	else:
		c.pressed = _value
		value = _value
	c.grab_focus()
	
func update_value(_value):
	value = _value
	
func set_data(type, value=null, id = null):
	if value != null:
		name_lineedit.text = value.name
		name_lineedit.editable = false
		options_type.select(value.type)
		options_type.emit_signal("item_selected", value.type, value.value)
		rich_text_label.bbcode_text = \
			rich_text_label.bbcode_text.replace("Create a new", "Edit")
	else:
		name_lineedit.text = "my_var"
		name_lineedit.editable = true
		options_type.select(type)
		options_type.emit_signal("item_selected", type, value)
		rich_text_label.bbcode_text = \
			rich_text_label.bbcode_text.replace("Edit", "Create a new")
	dialog_id = id
	
func get_data():
	var _data = {
		"type"	: options_type.get_selected_id(),
		"name"	: name_lineedit.text,
		"value"	: value
	}
	return _data


func _on_create_variable_dialog_visibility_changed() -> void:
	if visible and name_lineedit:
		yield(get_tree(), "idle_frame")
		select()
		rect_position.y -= 45


func _on_LineEdit_focus_exited() -> void:
	name_lineedit.deselect()


func _on_control1_gui_input(event : InputEvent) -> void:
	if event is InputEventKey and (
		event.scancode == KEY_ENTER or event.scancode == KEY_KP_ENTER):
		handled_event = true
		var c = value_container.get_child(0)
		if c is SpinBox: c = c.get_line_edit()
		c.grab_focus()
		
func _on_control2_gui_input(event : InputEvent) -> void:
	if handled_event:
		handled_event = false
		return
	if event is InputEventKey and (
		event.scancode == KEY_ENTER or event.scancode == KEY_KP_ENTER):
		_on_OK_Button_button_down()
		
func select():
	name_lineedit.caret_position = name_lineedit.text.length()
	name_lineedit.select_all()
	name_lineedit.grab_focus()


func _on_LineEdit_focus_entered() -> void:
	if !name_lineedit.editable:
		var c = value_container.get_child(0)
		if c is SpinBox: c = c.get_line_edit()
		c.grab_focus()
