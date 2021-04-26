extends GraphNode

onready var color_picker			= $HBoxContainer1/ColorPickerButton
onready var text_lineEdit			= $HBoxContainer3/Panel/current_text_LineEdit

signal edit_text(line_edit)

func _ready():
	var c = get_stylebox("frame").border_color
	color_picker.color = c
	get_stylebox("selectedframe").border_color = c.lightened(0.4)

func _on_SimpleBox_resize_request(new_minsize: Vector2) -> void:
				rect_size = new_minsize


func _on_ColorPickerButton_color_changed(color: Color) -> void:
	get_stylebox("frame").border_color = color
	get_stylebox("selectedframe").border_color = color.lightened(0.4)


func _on_Button_button_down() -> void:
	var l = LineEdit.new()
	l.expand_to_text_length = true
	l.placeholder_text = "write a choice..."
	l.caret_blink = true
	add_child(l)
	set_slot(get_children().size() - 1, false, 1, Color.red, true, 0, Color.red)
	
func get_data():
	var data = {
		"offset"	: offset,
		"color"		: color_picker.color,
		"text"		: text_lineEdit.text,
		"next"		: null,
		"choices"	: []
	}
	return data


func _on_Panel_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and
		event.button_index == BUTTON_LEFT and event.is_pressed()):
		emit_signal("edit_text", text_lineEdit)
		
		
		
		
