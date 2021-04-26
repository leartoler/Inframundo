extends DefaultDialog

onready var options_button	= $VBoxContainer/HBoxContainer/OptionButton

var languages = []
var last_index = 0
var graphnode

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")

func set_languages(_languages):
	languages = _languages
	fill_languages()
	
func set_parent(node):
	graphnode = node
	
func get_parent():
	return graphnode
	
func fill_languages():
	options_button.clear()
	for lang in languages:
		options_button.add_item(lang.name)
	last_index = min(last_index, languages.size() - 1)
	options_button.select(last_index)

func _on_OK_Button_button_down() -> void:
	emit_signal("OK", last_index, dialog_id)
		

func _on_Cancel_Button_focus_exited() -> void:
	yield(get_tree(), "idle_frame")
	options_button.grab_focus()

func _on_OptionButton_item_selected(index: int) -> void:
	last_index = index


func _on_OptionButton_item_rect_changed() -> void:
	rect_size.x = options_button.rect_size.x + 75
