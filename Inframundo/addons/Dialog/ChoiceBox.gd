extends PanelContainer
class_name ChoiceBox

onready var line_edit = $HBoxContainer/LineEdit

signal choice_delete_request(obj)
signal text_changed_request(obj)


func _on_DeleteChoiceButton_button_down() -> void:
	emit_signal("choice_delete_request", self)

func set_text(text) -> void:
	line_edit.text = text
	
func get_text() -> String:
	return line_edit.text

func select():
	line_edit.grab_focus()
	
func deselect():
	line_edit.deselect()
	line_edit.caret_position = line_edit.text.length()

func _on_LineEdit_focus_entered() -> void:
	line_edit.caret_position = line_edit.text.length()
	line_edit.select_all()


func _on_LineEdit_text_changed(new_text: String) -> void:
	emit_signal("text_changed_request", self)


func _on_LineEdit_focus_exited() -> void:
	deselect()
