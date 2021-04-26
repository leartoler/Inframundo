tool
extends CustomGraphNode
class_name CustomGraphNode_01

onready var text_line_edit = $VBoxContainer/ContentContainer/HBoxContainer3/Panel/current_text_LineEdit
onready var choice_box = preload("res://addons/Dialog/ChoiceBox.tscn")
onready var color_picker_button = $VBoxContainer/ContentContainer/HBoxContainer1/ColorPickerButton
onready var percent_button		= $VBoxContainer/ContentContainer/current_text_label/PercentToAppear_SpinBox
onready var simple_text_label	= $VBoxContainer/simple_text_label
onready var variables_behavior	= $VBoxContainer/ContentContainer/variable_label/variables_behavior_OptionButton

var text = ""
var config = null
var next_text = []
var choices_result = []
var set_variables = []

signal add_slot(index)
signal remove_slot(obj_name, dot_left_index, dot_right_index)
signal request_open_advance_text_editor(obj)
signal text_updated(id, index, text, action)
signal replace_text_with_other_request(obj)
signal show_dialog_color_request(obj)
signal preview_dialog(text, config_id, object)

func _ready() -> void:
	connect("focus_entered", self, "_on_CustomGraphNode_focus_entered_new")
	var line_edit = percent_button.get_line_edit()
	line_edit.connect("focus_entered", self, "select_percent_button")
	line_edit.caret_blink = true
	var node = find_node("ColorPickerButton")
	node.connect("toggled", self, "color_button_pressed", [node])
	
func add_variable(_var):
	set_variables.append(_var)
	
func remove_variable(id):
	set_variables.erase(id)

func _on_add_choice_button_button_down() -> void:
	var c = create_choice()
	c.select()
	emit_signal("add_slot", get_child_count() - 1)
	emit_signal("text_updated", id, c.get_index() - 7, 
		{"text" : "", "next" : []}, "create")
	select()
	var n = 2
	yields_active += n
	yield(wait(n), "completed")
	yields_active -= n
	c.select()
		
func create_choice():
	var c = choice_box.instance()
	c.connect("choice_delete_request", self, "delete_choice")
	c.connect("text_changed_request", self, "choice_text_changed")
	add_child(c)
	slots[-1].right_show = true
	slots[-1].right_type = 1
	slots[-1].right_color = Color("fcb6b6")
	slots[-1].right_max_connections = 0
	#slots[-1].right_offset.y = c.rect_size.y
	choices_result.append([])
	return c


func delete_choice(obj):
	var index = obj.get_index()
	var obj_size = obj.rect_size
	obj.queue_free()
	var slot = slots[index]
	slots.remove(index)
	choices_result.remove(index - 8)
	var dot1_index; var dot2_index;
	if slot.left_show:
		dot1_index = dot_container_left.get_node(slot.dot_left_name).get_index()
	if slot.right_show:
		dot2_index = dot_container_right.get_node(slot.dot_right_name).get_index()
	emit_signal("remove_slot", name, dot1_index, dot2_index)
	emit_signal("text_updated", id, index - 7, "", "delete")
	var n = 2
	yields_active += n
	yield(wait(n), "completed")
	yields_active -= n
	rect_size.y -= obj_size.y + 12
	update_dots()
	
func choice_text_changed(obj):
	var text = {
		"text"		: obj.get_text(),
		"next"		: choices_result[obj.get_index()-8]
	}
	emit_signal("text_updated", id, obj.get_index() - 7,
		text, "update")
	
func _on_CustomGraphNode_focus_entered_new():
	if !is_inside_tree():
		return
	var n = 1
	yields_active += n
	yield(wait(n), "completed")
	yields_active -= n
	if get_focus_owner() != percent_button.get_line_edit():
		percent_button.get_line_edit().grab_focus()

func select_percent_button():
	select()
	if !is_inside_tree():
		return

	var line_edit = percent_button.get_line_edit()
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


func select(force_select = false) -> void:
	.select(force_select)
	if !force_select:
		_on_CustomGraphNode_focus_entered_new()




func _on_ColorPickerButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		var n = 1
		yields_active += n
		yield(wait(n), "completed")
		yields_active -= n
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


func get_data() -> Dictionary:
	var choices = []
	if content_container.get_child_count() > 8:
		for i in range(8, content_container.get_child_count()):
			choices.append(
				{
					"text"		: content_container.get_child(i).get_text(),
					"next"		: choices_result[i-8]
				}
			)
	var data = {
		"name"					: name,
		"id"					: id,
		"title"					: title,
		"frame_color"			: frame_color,
		"position"				: rect_position,
		"size"					: rect_size,
		"text"					: text,
		"probability"			: percent_button.value,
		"choices"				: choices,
		"next_text"				: next_text,
		"config"				: config,
		"connections"			: connections,
		"collapsed"				: typeof(collapsed) == TYPE_DICTIONARY,
		"type"					: "message",
		"set_variables"			: set_variables,
		"variables_behavior"	: variables_behavior.get_selected_id()
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
	if data.has("text"):
		set_text(data.text)
	if data.has("probability"):
		percent_button.value = data.probability
	if data.has("next_text"):
		next_text = data.next_text
	config = data.config
	choices_result.clear()
	if data.has("choices"):
		set_choices(data.choices)
	connections = data.connections
	if data.has("set_variables"):
		set_variables = data.set_variables
	if data.has("variables_behavior"):
		variables_behavior.select(data.variables_behavior)
	resume_data = [0, data]
	$Timer.start()

func set_choices(choices):
	if choices.size() == 0: return
	choices_result.clear()
	var choice_data = []
	for choice in choices:
		var c = create_choice()
		c.set_text(choice.text)
		c.deselect()
		choice_data.append(choice.next)
	choices_result = choice_data

func set_choices_text(choices):
	for i in choices.size():
		var c = content_container.get_child(i+8)
		if choices[i] is Dictionary:
			c.set_text(choices[i].text)
		else:
			c.set_text(str(choices[i]))
		

func _on_current_text_LineEdit_text_changed(new_text: String) -> void:
	text = text_line_edit.text


func _on_advance_edit_text_button_down() -> void:
	emit_signal("request_open_advance_text_editor", self)
	
func set_text(_text : String, is_edition=false) -> void:
	if is_edition and _text != text_line_edit.text:
		emit_signal("text_updated", id, 0, _text, "update")
	text_line_edit.text = _text
	text = _text
	
func replace_text(text, _choices):
	set_text(text)
	set_choices_text(_choices)
	emit_signal("text_updated", id, 0, [text, _choices], "replace")
	
	
func get_probability():
	return percent_button.value
	
func add_next_text(_id):
	for item in next_text:
		if item.id == _id.id:
			item.probability = _id.probability
			return
	next_text.append(_id)
	
func remove_next_text(_id):
	if _id is Dictionary: _id = _id.id
	for item in next_text:
		if item.id == _id:
			next_text.erase(item)
			break

func add_next_choice_text(from_port, next_id, probability):
	var current_id = from_port - 2
	choices_result[current_id].append(
		{
			"id"			: next_id,
			"probability"	: probability
		}
	)

func remove_next_choice_text(from_port, id):
	var current_id = from_port - 2
	for choice in choices_result[current_id]:
		if choice.id == id: choices_result[current_id].erase(choice)

func set_config(_id):
	config = _id
	

func set_choice(index, text):
	content_container.get_child(8+index).set_text(text)

func _on_Panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and \
		event.is_pressed():
		emit_signal("request_open_advance_text_editor", self)


func _on_get_default_text_button_down() -> void:
	emit_signal("replace_text_with_other_request", self)


func _on_CustomGraphNode_collapsed(value) -> void:
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
	if collapsed and simple_text_label.rect_size.y != 14:
		simple_text_label.rect_size.y = 14

func color_button_pressed(button_pressed : bool, obj : ColorPickerButton = null):
	if button_pressed:
		emit_signal("show_dialog_color_request", obj)
		var n = 1
		yields_active += n
		yield(wait(n), "completed")
		yields_active -= n
		obj.get_popup().hide()


func _on_Timer_timeout() -> void:
	if is_inside_tree():
		if resume_data[0] == 0:
			update_dots()
			if resume_data[1].collapsed: expand_collapse()
			_on_CustomGraphNode_collapsed(resume_data[1].collapsed)
		resume_data = null


func _on_preview_Button_button_down():
	var config_id = 0 if config == null else config
	emit_signal("preview_dialog", text, config_id, self)
