extends Panel

var lang_id

signal text_changed(term)

func set_lang(lang_id, lang_name):
	find_node("Label").text = lang_name
	self.lang_id = lang_id

func set_text(text):
	find_node("LineEdit").text = text
	
func get_term(text):
	return {
		"lang_id"	: lang_id,
		"text"		: text
	}
	
func select():
	var node = find_node("LineEdit")
	node.caret_position = node.text.length()
	node.select_all()
	node.grab_focus()
	
func set_disabled(value):
	find_node("LineEdit").editable = !value

func _on_LineEdit_text_changed(new_text: String) -> void:
	emit_signal("text_changed", get_term(new_text))


func _on_LineEdit_focus_entered() -> void:
	var node = find_node("LineEdit")
	node.caret_position = node.text.length()
	node.select_all()
