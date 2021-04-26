extends DefaultDialog

onready var cols	= $VBoxContainer/HBoxContainer/columns_SpinBox
onready var rows	= $VBoxContainer/HBoxContainer2/rows_SpinBox

func _ready() -> void:
	cols.get_line_edit().caret_blink = true
	rows.get_line_edit().caret_blink = true


func _on_OK_Button_button_down() -> void:
	cols.apply()
	rows.apply()
	var columns = ""
	var cursor_row = rows.value
	var cursor_column = 6
	for i in rows.value:
		var c = ""
		for j in cols.value:
			if c != "": c += "  "
			c += "[cell][/cell]"
		columns += c + "\n"
		
	var text = {
		"begin_text"	: "[table=%s]" % cols.value,
		"columns"		: columns,
		"end_text"		: "[/table]",
		"cursor_row"	: cursor_row,
		"cursor_column"	: cursor_column
	}
	emit_signal("OK", text, dialog_id)


func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_table_dialog_visibility_changed() -> void:
	if visible and rows:
		yield(get_tree(), "idle_frame")
		var lineedit = rows.get_line_edit()
		lineedit.select_all()
		lineedit.caret_position = lineedit.text.length()
		lineedit.grab_focus()


func _on_Cancel_Button_focus_exited() -> void:
	yield(get_tree(), "idle_frame")
	rows.get_line_edit().grab_focus()
