extends DefaultDialog

onready var lineedit	= $VBoxContainer/HBoxContainer2/LineEdit

var allowed_characters = "" # [a-zA-Z0-9_\\-*/?&$%@!#.ñÑ() ]"

#func _ready():
#	._ready()
#	rect_position = Vector2(20,20)

func set_text(label_text : String, input_text : String) -> void:
	var node = self.get_node("VBoxContainer/HBoxContainer/Label")
	node.text = label_text
	node = lineedit
	node.text = input_text
	
func set_dialog_id(id):
	dialog_id = id

func _on_LineEdit_text_entered(new_text: String) -> void:
	emit_signal("OK", new_text, dialog_id)
	hide()


func _on_SelectLanguageNameDialog_visibility_changed() -> void:
	if visible:
		yield(get_tree(), "idle_frame")
		var node = lineedit
		node.caret_position = node.text.length()
		node.select_all()
		node.grab_focus()


func _on_ok_button_down() -> void:
	var new_text = lineedit.text
	emit_signal("OK", new_text, dialog_id)


func _on_LineEdit_text_changed(new_text : String) -> void:
	var old_caret_position = lineedit.caret_position
	if allowed_characters.length() > 0:
		var word = ''
		var regex = RegEx.new()
		regex.compile(allowed_characters)
		for valid_character in regex.search_all(new_text):
			word += valid_character.get_string()
		lineedit.set_text(word)
	else:
		lineedit.set_text(new_text)
	lineedit.caret_position = old_caret_position
	
