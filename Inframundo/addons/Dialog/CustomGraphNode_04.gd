tool
extends CustomGraphNode
class_name CustomGraphNode_04

onready var color_picker_button = $VBoxContainer/ContentContainer/separator/ColorPickerButton
onready var condition_container	= $VBoxContainer/ContentContainer/VBoxContainer/VBoxContainer
onready var probability_spinbox	= $VBoxContainer/ContentContainer/VBoxContainer/HBoxContainer/SpinBox
onready var simple_text_label	= $VBoxContainer/simple_text_label
onready var conditional_panel = preload("res://addons/Dialog/ConditionPanel.tscn")

var next_text = []

signal open_select_variable_request(object)
signal show_dialog_color_request(obj)

func _ready() -> void:
	var node = find_node("ColorPickerButton")
	node.connect("toggled", self, "color_button_pressed", [node])
	var line_edit = probability_spinbox.get_line_edit()
	line_edit.connect("focus_entered", self, "select_percent_button")
	line_edit.caret_blink = true

func _on_ColorPickerButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		yield(get_tree(), "idle_frame")
		var margin = 40
		var p = color_picker_button.get_picker().get_parent()
		var s = get_viewport().size - Vector2(margin, margin)
		p.rect_global_position = (get_global_mouse_position() -
			p.rect_size * 0.5 + Vector2(0, 230))
		if p.rect_global_position.x < margin:
			p.rect_global_position.x = margin
		elif p.rect_global_position.x + p.rect_size.x > s.x:
			p.rect_global_position.x = s.x - p.rect_size.x
		if p.rect_global_position.y < margin:
			p.rect_global_position.y = margin
		elif p.rect_global_position.y + p.rect_size.y > s.y:
			p.rect_global_position.y = s.y - p.rect_size.y

			
func get_probability():
	probability_spinbox.apply()
	return probability_spinbox.value

func add_next_text(_id):
	for item in next_text:
		if item.id == _id.id:
			item.probability = _id.probability
			return
	next_text.append(_id)
	
func remove_next_text(_id):
	if _id is Dictionary: _id = _id.id
	print("remove id %s" % _id)
	for item in next_text:
		print(item)
		if item.id == _id:
			next_text.erase(item)
			break


func get_data() -> Dictionary:
	var conditions = []
	for child in condition_container.get_children():
		conditions.append(child.get_condition())
		
	var data = {
		"name"			: name,
		"id"			: id,
		"title"			: title,
		"frame_color"	: frame_color,
		"position"		: rect_position,
		"size"			: rect_size,
		"conditions"	: conditions,
		"connections"	: connections,
		"next_text"		: next_text,
		"probability"	: get_probability(),
		"collapsed"		: typeof(collapsed) == TYPE_DICTIONARY,
		"type"			: "condition",
	}
	return data


func set_data(data):
	name = data.name
	id = data.id
	set_title_text(data.title)
	color_picker_button.color = data.frame_color
	set_frame_color(color_picker_button.color)
	rect_position = data.position
	rect_size.x = max(data.size.x, rect_min_size.x)
	rect_size.y = max(data.size.y, rect_min_size.y)
	connections = data.connections
	next_text = data.next_text
	for condition in data.conditions:
		add_condition(condition)
	if data.collapsed: expand_collapse()
	_on_CustomGraphNode_collapsed(data.collapsed)
	probability_spinbox.value = data.probability

func add_condition(condition=null):
	var panel = conditional_panel.instance()
	panel.connect("delete_condition_request", self, "delete_condition_panel")
	panel.connect("open_select_variable_request", self, "open_select_variable")
	panel.connect("select_parent_request", self, "select")
	if condition_container.get_child_count() != 0:
		panel.set_extra_condition(true)
	condition_container.add_child(panel)
	if condition != null:
		panel.set_condition(condition)
	find_node("NoConditionLabel").visible = false

func _on_AddConditionButton_button_down() -> void:
	add_condition()
	select()

func open_select_variable(obj, filter=null):
	emit_signal("open_select_variable_request", obj, filter)
	select()

func select_percent_button():
	select()
	if !is_inside_tree():
		return

	var line_edit = probability_spinbox.get_line_edit()
	line_edit.grab_focus()
	line_edit.caret_position = line_edit.text.length()
	var n = 1
	yields_active += n
	yield(wait(n), "completed")
	yields_active -= n
	line_edit.select_all()
	n = 1
	yields_active += n
	yield(wait(n), "completed")
	yields_active -= n
	line_edit.caret_position = line_edit.text.length()
	line_edit.select_all()


func delete_condition_panel(object):
	condition_container.remove_child(object)
	rect_size -= object.rect_size
	object.queue_free()
	if condition_container.get_child_count() == 0:
		find_node("NoConditionLabel").visible = true

func color_button_pressed(button_pressed : bool, obj : ColorPickerButton = null):
	if button_pressed:
		emit_signal("show_dialog_color_request", obj)
		yield(get_tree(), "idle_frame")
		obj.get_popup().hide()

func get_current_condition():
	var conditions = get_data().conditions
	var command = ""
	for condition in conditions:
		var partial_command = "" if command.length() == 0 else " "
		# Get AND or OR
		if condition.extra_condition != null:
			if condition.extra_condition == 0:
				partial_command += "and "
			else:
				partial_command += "or "
		# Get first value
		partial_command += "%s " % condition.variables.a.name
		# Get operation symbol
		var operation
		match condition.variables.a.type:
			0: operation = ["==", "<", ">", "!="] # String
			1, 2: operation = ["==", "<", "<=", ">", ">=", "!="] # Int and Float
			3: operation = ["==", "!="] # Bool
		partial_command += "%s " % operation[condition.check_type]
		# get second value
		if condition.value_type == 0 and condition.variables.b != null:
			partial_command += "%s " % condition.variables.a.name
		else:
			partial_command += "%s" % condition.value
		command += partial_command
	return command

func _on_CustomGraphNode_collapsed(value) -> void:
	var text = get_current_condition()
	if value:
		simple_text_label.parse_bbcode(text)
		simple_text_label.bbcode_text = simple_text_label.text
		simple_text_label.visible = true
		var n = 3
		yields_active += n
		yield(wait(n), "completed")
		yields_active -= n
		simple_text_label.rect_size.y = 14
	else:
		simple_text_label.bbcode_text = ""
		simple_text_label.visible = false
		simple_text_label.rect_size.y = 0

func _process(delta: float) -> void:
	if collapsed and simple_text_label.rect_size.y < 14:
		simple_text_label.rect_size.y = 14
