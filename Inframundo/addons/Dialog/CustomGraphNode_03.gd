tool
extends CustomGraphNode
class_name CustomGraphNode_03

onready var color_picker_button = $VBoxContainer/ContentContainer/separator/ColorPickerButton
onready var variable_container	= $VBoxContainer/ContentContainer/VBoxContainer/VBoxContainer
onready var simple_text_label	= $VBoxContainer/simple_text_label
onready var variables_label		= $VBoxContainer/ContentContainer/VBoxContainer/Label

onready var variable_panel = preload("res://addons/Dialog/VariablePanel.tscn")

signal open_select_variable_request(object)
signal show_dialog_color_request(obj)

func _ready() -> void:
	var node = find_node("ColorPickerButton")
	node.connect("toggled", self, "color_button_pressed", [node])

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
	return 100


func get_data() -> Dictionary:
	var variables = []
	for child in variable_container.get_children():
		variables.append(child.get_variable())
		
	var data = {
		"name"			: name,
		"id"			: id,
		"title"			: title,
		"frame_color"	: frame_color,
		"position"		: rect_position,
		"size"			: rect_size,
		"set_variables"	: variables,
		"connections"	: connections,
		"collapsed"		: typeof(collapsed) == TYPE_DICTIONARY,
		"type"			: "variable",
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
	for _var in data.set_variables:
		add_variable(_var)
	if data.collapsed: expand_collapse()


func add_variable(_var):
	if !is_var_added(_var):
		var panel = variable_panel.instance()
		variable_container.add_child(panel)
		panel.set_variable(_var)
		panel.connect("delete_variable_request", self, "delete_variable_panel")
		panel.connect("select_parent_request", self, "select")
		variables_label.visible = false

func is_var_added(_var):
	for child in variable_container.get_children():
		var child_var = child.get_variable()
		if child_var.name == _var.name and child_var.type == _var.type:
			return true
	return false

func _on_AddVariableButton_button_down() -> void:
	emit_signal("open_select_variable_request", self)
	select()


func delete_variable_panel(object):
	variable_container.remove_child(object)
	rect_size -= object.rect_size
	object.queue_free()
	variables_label.visible = variable_container.get_child_count() == 0

func color_button_pressed(button_pressed : bool, obj : ColorPickerButton = null):
	if button_pressed:
		emit_signal("show_dialog_color_request", obj)
		yield(get_tree(), "idle_frame")
		obj.get_popup().hide()

func get_current_variable():
	var text = ""
	for variable in get_data().set_variables:
		match variable.type:
			0: # String
				text += variable.name + " = \"" + str(variable.value) + "\"; "
			1, 2: # int, float
				var symbol = ""
				match variable.operation_type:
					0: symbol = " = " # Set
					1: symbol = " + " # Add
					2: symbol = " - " # Minus
					3: symbol = " * " # Multiply
					4: symbol = " / " # Divide
				text += variable.name + symbol + str(variable.value) + "; "
			3: # Bool
				text += variable.name + " = " + str(variable.value) + "; "
	return text


func _on_CustomGraphNode_collapsed(value) -> void:
	var text = get_current_variable()
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
