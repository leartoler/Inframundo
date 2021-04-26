extends DefaultDialog

onready var options_button	= $VBoxContainer/HBoxContainer/OptionButton

var variables = []
var last_index = 0
var graphnode

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")

func set_variables(_variables, filter = null):
	variables = _variables
	fill_variables(filter)
	
func set_parent(node):
	graphnode = node
	
func get_parent():
	return graphnode
	
func fill_variables(filter):
	options_button.clear()
	var i = 0
	for variable in variables:
		if !(filter == null or filter == variable.type): continue
		var n = "%s  (%s)" % [
			variable.name,
			get_name_of_type(variable.type)
		]
		options_button.add_item(n)
		i += 1
	if i > 0:
		last_index = max(0, min(last_index, i - 1))
		options_button.select(last_index)

func get_name_of_type(type) -> String:
	var n = ""
	match type:
		0: n =  "STRING"
		1: n =  "INT"
		2: n =  "FLOAT"
		3: n =  "BOOLEAN"
	return n

func _on_OK_Button_button_down() -> void:
	var text
	for _var in variables:
		var n = "%s  (%s)" % [
			_var.name,
			get_name_of_type(_var.type)
		]
		if n == options_button.text:
			emit_signal("OK", _var, dialog_id)
			return
	emit_signal("Cancel")

func _on_Cancel_Button_focus_exited() -> void:
	yield(get_tree(), "idle_frame")
	options_button.grab_focus()

func _on_OptionButton_item_selected(index: int) -> void:
	last_index = index


func _on_OptionButton_item_rect_changed() -> void:
	rect_size.x = options_button.rect_size.x + 75
