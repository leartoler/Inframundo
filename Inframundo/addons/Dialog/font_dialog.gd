extends DefaultDialog

onready var path_lineEdit		= $VBoxContainer/HBoxContainer/path_LineEdit
onready var size_spinBox		= $VBoxContainer/HBoxContainer2/size_SpinBox
onready var outline_spinBox		= $VBoxContainer/HBoxContainer30/osize_SpinBox
onready var color_button		= $VBoxContainer/HBoxContainer4/ocolor_Button
onready var mipmaps_checkBox	= $VBoxContainer/HBoxContainer5/mipmaps_CheckBox
onready var filter_checkBox		= $VBoxContainer/HBoxContainer6/filter_CheckBox
onready var sp_top_spinBox		= $VBoxContainer/HBoxContainer7/top_spacing_SpinBox
onready var sp_bottom_spinBox	= $VBoxContainer/HBoxContainer7/bottom_spacing_SpinBox
onready var sp_char_spinBox		= $VBoxContainer/HBoxContainer8/char_spacing_SpinBox
onready var sp_space_spinBox	= $VBoxContainer/HBoxContainer8/space_SpinBox
onready var font_type_options	= $VBoxContainer/HBoxContainer2/OptionButton

signal select_font_dialog_request

var path = "default_font-normal(16).tres"
var paths

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	outline_spinBox.apply()
	size_spinBox.apply()
	sp_top_spinBox.apply()
	sp_bottom_spinBox.apply()
	sp_char_spinBox.apply()
	sp_space_spinBox.apply()
	var path = create_dynamic_font()
	var index = font_type_options.get_selected_id()
	var text = {}
	text["begin_text"]	= "[font name=%s type=%s]" % [path.get_file(), index]
	text["end_text"]	= "[/font type=%s]" % index
	emit_signal("OK", text, dialog_id)
	
func create_dynamic_font() -> String:
	path = path_lineEdit.text
	if path == "default":
		path = "default_font-normal"
	if paths == null: return path
	var size = size_spinBox.value
	var outline = outline_spinBox.value
	var color = color_button.color
	var mipmaps = mipmaps_checkBox.pressed
	var filter = filter_checkBox.pressed
	var top = sp_top_spinBox.value
	var bottom = sp_bottom_spinBox.value
	var chr = sp_char_spinBox.value
	var space = sp_space_spinBox.value
	var dir = Directory.new()
	var to = paths.fonts
	dir.make_dir_recursive(to)
	var _filename = to + path.get_basename().get_file() + "(%s)" % size + ".tres"
	var filename2 = to + path.get_basename().get_file() + ".ttf"
	to = "res://addons/Dialog/Fonts/"
	var f = DynamicFont.new()
	f.size = size
	f.outline_size = outline
	f.outline_color = color
	f.use_mipmaps = mipmaps
	f.use_filter = filter
	f.extra_spacing_bottom = bottom
	f.extra_spacing_top = top
	f.extra_spacing_char = chr
	f.extra_spacing_space = space
	f.font_data = load(filename2)
	ResourceSaver.save(_filename, f)
#	var file = File.new()
#	var template_path = to + "dynamic_font.template"
#	file.open(template_path, File.READ)
#	var template = ""
#	while not file.eof_reached():
#		if template.length() > 0: template += "\n"
#		template += file.get_line()
#	file.close()
#	template = template.replace("$001", filename2)
#	template = template.replace("$002", str(size))
#	template = template.replace("$003", outline)
#	template = template.replace("$004", color)
#	template = template.replace("$005", str(mipmaps).to_lower())
#	template = template.replace("$006", str(filter).to_lower())
#	template = template.replace("$007", str(top))
#	template = template.replace("$008", str(bottom))
#	template = template.replace("$009", str(chr))
#	template = template.replace("$010", str(space))
#	file.open(_filename, File.WRITE)
#	file.store_string(template)
#	file.close()
	
	path = _filename
	return _filename

func _on_Cancel_Button_focus_exited() -> void:
	pass


func _on_path_LineEdit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and \
		event.is_pressed():
		emit_signal("select_font_dialog_request", "fonts_01")
		
func set_font(font_path):
	var begin_path = paths.fonts if paths != null else ""
	path = begin_path + font_path
	path_lineEdit.text = font_path

func set_font_type(id = null):
	if id == null:
		font_type_options.disabled = false
	else:
		font_type_options.disabled = true
		font_type_options.select(id)

func set_dynamic_font(font_path):
	var begin_path = paths.fonts if paths != null else ""
	var font = ResourceLoader.load(begin_path + font_path)
	if font is DynamicFont:
		path_lineEdit.text = font.font_data.font_path
		size_spinBox.value = font.size
		outline_spinBox.value = font.outline_size
		color_button.color = font.outline_color
		mipmaps_checkBox.pressed = font.use_mipmaps
		filter_checkBox.pressed = font.use_filter
		sp_top_spinBox.value = font.extra_spacing_top
		sp_bottom_spinBox.value = font.extra_spacing_bottom
		sp_char_spinBox.value = font.extra_spacing_char
		sp_space_spinBox.value = font.extra_spacing_space
		path = font_path

func set_font_type_options(id):
	id = max(0, min(id, 3))
	font_type_options.select(id)

func _on_font_dialog_visibility_changed() -> void:
	if visible and size_spinBox:
		yield(get_tree(), "idle_frame")
		var lineedit = size_spinBox.get_line_edit()
		lineedit.select_all()
		lineedit.caret_position = lineedit.text.length()
		lineedit.grab_focus()


func _on_TextureButton_button_down() -> void:
	pass # Replace with function body.


func _on_load_font_Button_button_down() -> void:
	emit_signal("select_font_dialog_request", "fonts_02")
