extends DefaultDialog

onready var label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label
onready var ok_button = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/TextureButton2

var is_ok = false

func _ready() -> void:
	connect("OK", self, "enable_ok")

func _on_ok_button_down() -> void:
	emit_signal("OK", "", dialog_id)
	
func enable_ok(text, dialog_id):
	is_ok = true

func _on_ConfirmDialog_visibility_changed() -> void:
	if visible:
		is_ok = false
		if ok_button:
			yield(get_tree(), "idle_frame")
			ok_button.grab_focus()
	else:
		label.bbcode_text = ""
		label.rect_size.y = 64
		find_node("BACKGROUND").rect_size.y = 72
		rect_min_size.y = 117
		rect_size.y = rect_min_size.y

func _on_Label_item_rect_changed() -> void:
	var node = find_node("PanelContainer")
	rect_min_size.y = rect_min_size.y
	rect_size.y = rect_min_size.y
	node.rect_min_size.y = label.rect_size.y + 58
	node.rect_size.y = rect_min_size.y
