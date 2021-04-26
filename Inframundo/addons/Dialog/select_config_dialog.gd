extends DefaultDialog

onready var options_button	= $VBoxContainer/HBoxContainer/OptionButton

var config_ids = []
var last_index = 0
var initial_index = null
var graphnode


func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")

func set_configs(_config_ids):
	config_ids = _config_ids
	fill_configs()
	
func set_parent(node):
	graphnode = node
	
func get_parent():
	return graphnode
	
func fill_configs():
	options_button.clear()
	for id in config_ids:
		var n
		if id == 0: n = "Default Config"
		else: n = "Config ID # %s" % id
		options_button.add_item(n)
	if initial_index != null:
		for id in config_ids:
			if id == initial_index:
				options_button.select(id)
				initial_index = null
				break

func _on_OK_Button_button_down() -> void:
	var id = config_ids[options_button.get_selected_id()]
	var text = {
		"begin_text"	: "[set_config id=%s]" % id,
		"end_text"		: ""
	}
	emit_signal("OK", text, dialog_id)
#	emit_signal("Cancel")

func _on_Cancel_Button_focus_exited() -> void:
	yield(get_tree(), "idle_frame")
	options_button.grab_focus()

func _on_OptionButton_item_selected(index: int) -> void:
	last_index = index


func _on_OptionButton_item_rect_changed() -> void:
	rect_size.x = options_button.rect_size.x + 75


func set_parameters(command):
	if command[0] is String and command[0].find("=") != -1:
		initial_index = int(command[0].split("=")[1])
	fill_configs()


func _on_select_config_dialog_visibility_changed() -> void:
	if options_button != null:
		if visible and options_button.get_child_count() == 0:
			fill_configs()
