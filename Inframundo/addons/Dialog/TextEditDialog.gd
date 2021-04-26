extends Popup

onready var textedit				= $VBoxContainer/BottomPanel/VBoxContainer/TextEdit
onready var hide_all_layer			= $hide_all_dialogs
onready var table_dialog			= $table_dialog
onready var wave_effect_dialog		= $wave_effect_dialog
onready var tornado_effect_dialog	= $tornado_effect_dialog
onready var shake_effect_dialog		= $shake_effect_dialog
onready var fade_effect_dialog		= $fade_effect_dialog
onready var rainbow_effect_dialog	= $rainbow_effect_dialog
onready var ghost_effect_dialog		= $ghost_effect_dialog
onready var pulse_effect_dialog		= $pulse_effect_dialog
onready var matrix_effect_dialog	= $matrix_effect_dialog
onready var fade_ani_effect_dialog	= $fade_animation_effect_dialog
onready var text_effects			= $VBoxContainer/BottomPanel/VBoxContainer/Container/PanelContainer6/HBoxContainer/effects_OptionButton
onready var file_dialog				= $CustomFileDialog
onready var font_dialog				= $font_dialog
onready var color_dialog			= $color_dialog
onready var pause_dialog			= $pause_dialog
onready var top_panel				= $VBoxContainer/TopPanel/PanelContainer
onready var bottom_panel			= $VBoxContainer/BottomPanel/VBoxContainer
onready var bottom_panel2			= $VBoxContainer/BottomPanel/Background2
onready var title_label2			= $VBoxContainer/TopPanel/PanelContainer/Container/Label2
onready var select_image_dialog		= $select_image_dialog
onready var image_effects_dialog	= $image_effects_dialog
onready var remove_image_dialog		= $remove_image_dialog
onready var show_char_name_dialog	= $show_char_name_dialog
onready var remove_char_name_dialog	= $remove_char_name_dialog
onready var change_lbl_dialog		= $change_letter_by_letter_dialog
onready var emit_signal_dialog		= $emit_signal_dialog
onready var play_sound_dialog		= $play_sound_dialog
onready var show_variable_dialog	= $show_variable_dialog
onready var show_term_dialog		= $show_term_dialog
onready var zoom_dialog				= $zoom_effect_dialog
onready var angle_dialog			= $angle_effect_dialog
onready var character_name_dialog	= $show_character_name_dialog
onready var show_config_dialog		= $select_config_dialog


var dragging = false
var resizing = false
var target_edge = -1
var cursor_type = -1
var last_mouse_position
var border_size = 10
var maximized = false
var sub_dialog_open = []

var current_parent

var variables = []
var characters = []
var signals = []
var config_ids = []
var terms = []

var paths

var edit_mode = false

enum edge {left, top, right, bottom, topl, topr, botl, botr};

signal close_request()
signal dialog_font_request(obj)
signal dialog_image_request(obj)
signal dialog_color_request(obj)
signal open_dialog_preview_request(id)
signal close_dialog_preview_request()
signal dialog_response(response)
signal chosen_sound(path)
signal preview_dialog(text, config_id, object)

func _ready() -> void:
	resize_hide_layer()
	textedit.add_color_region("[", "]", Color(0, 0.644531, 0.236664))
	text_effects.text = "Text Effects"
	font_dialog.connect("select_font_dialog_request",
		self, "show_font_dialog")
	select_image_dialog.connect("select_image_dialog_request",
		self, "show_image_dialog")
	play_sound_dialog.connect("show_select_audio_file_dialog_request",
		self, "show_sound_dialog")
	connect("chosen_sound", play_sound_dialog, "set_path")
	fix_spinboxes_and_lineedits(self)
	nodes_fixed = null


func set_paths(_paths):
	paths = _paths
	font_dialog.paths = _paths
	play_sound_dialog.paths = _paths
	select_image_dialog.paths = _paths
	

var nodes_fixed = []
func fix_spinboxes_and_lineedits(obj):
	if obj is SpinBox:
		var lineedit = obj.get_line_edit()
		lineedit.caret_blink = true
		lineedit.connect("gui_input", self,
			"spinboxesand_lineedits_gui_input", [obj])
		nodes_fixed.append(lineedit)
	elif obj is LineEdit:
		obj.caret_blink = true
		if !nodes_fixed.has(obj):
			obj.connect("gui_input", self,
				"spinboxesand_lineedits_gui_input", [obj])
	if obj.get_child_count() > 0:
		for child in obj.get_children():
			fix_spinboxes_and_lineedits(child)
	
func spinboxesand_lineedits_gui_input(event : InputEvent, obj = null):
	if event is InputEventKey and (event.scancode == KEY_ENTER or \
		event.scancode == KEY_KP_ENTER) and event.is_pressed():
		get_tree().set_input_as_handled()
		if obj is SpinBox:
			get_next_focus_for(self, obj.get_line_edit())
		else:
			get_next_focus_for(self, obj)
		
func get_next_focus_for(obj, node_searched, node_found = {"t" : false}):
	if !node_found.t:
		if obj is SpinBox: obj = obj.get_line_edit()
		if obj == node_searched:
			node_found.t = true
			
	if node_found.t and obj != node_searched and \
		!obj is Timer and !obj is Popup and "focus_mode" in obj and \
		obj.focus_mode != FOCUS_NONE and is_on_screen(obj):
		node_found.t = null
		if obj is LineEdit:
			obj.caret_position = obj.text.length()
			obj.select_all()
		obj.grab_focus()
		
	if obj.get_child_count() > 0:
		for child in obj.get_children():
			get_next_focus_for(child, node_searched, node_found)
			if node_found.t == null: break
	
func is_on_screen(obj):
	if "visible" in obj and !obj.visible: return false
	var p = obj.get_parent()
	while p != null:
		if "visible" in p and !p.visible: return false
		p = p.get_parent()
	return true

func resize_hide_layer():
	hide_all_layer.rect_size = get_viewport().size
	hide_all_layer.rect_global_position = Vector2.ZERO

func set_text(_text : String) -> void:
	if current_parent == null: return
	current_parent.text = _text
	
func set_current_parent(obj):
	current_parent = obj
	textedit.text = obj.text

func _on_gui_input(event: InputEvent, id: String) -> void:
	if (!dragging and !resizing): set_edge()
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and
		!event.is_pressed()):
		dragging = false
		resizing = false
		target_edge = -1
	elif (!dragging and !resizing) and (event is InputEventMouseButton and
		event.button_index == BUTTON_LEFT and event.is_pressed()):
		if target_edge == -1:
			if event.doubleclick:
				maximize_or_restore()
			elif !maximized:
				dragging = true
		elif !maximized:
			resizing = true
			last_mouse_position = get_local_mouse_position()
	elif event is InputEventMouseMotion:
		if dragging:
			rect_position += event.relative
		elif resizing:
			var _rect_size = rect_size
			var current_mouse_position = get_local_mouse_position()
			var i
			if (target_edge == edge.left or
				target_edge == edge.topl or target_edge == edge.botl):
				if ((event.relative.x < 0 and
					current_mouse_position.x <= border_size) or
					event.relative.x > 0):
					i = last_mouse_position.x - current_mouse_position.x
					rect_size.x += i
					rect_position.x += _rect_size.x - rect_size.x
			if (target_edge == edge.topl or
				target_edge == edge.top or target_edge == edge.topr):
				if ((event.relative.y < 0 and
					current_mouse_position.y <= border_size) or
					event.relative.y > 0):
					i = last_mouse_position.y - current_mouse_position.y
					rect_size.y += i
					rect_position.y += _rect_size.y - rect_size.y
			if (target_edge == edge.topr or
				target_edge == edge.right or target_edge == edge.botr):
				if ((event.relative.x > 0 and
					current_mouse_position.x >= rect_size.x - border_size) or
					event.relative.x < 0):
					i = current_mouse_position.x - last_mouse_position.x
					rect_size.x += i
			if (target_edge == edge.botl or
				target_edge == edge.bottom or target_edge == edge.botr):
				if ((event.relative.y > 0 and
					current_mouse_position.y >= rect_size.y - border_size) or
					event.relative.y < 0):
					i = current_mouse_position.y - last_mouse_position.y
					rect_size.y += i
			last_mouse_position = get_local_mouse_position()
		
func set_edge():
	target_edge = -1
	var mouse_pos = get_local_mouse_position()
	var s = rect_size
	if mouse_pos.y <= border_size:	
		if mouse_pos.x <= border_size:
			target_edge = edge.topl;
		elif mouse_pos.x < s.x - border_size:
			target_edge = edge.top
		elif mouse_pos.x >= s.x - border_size:
			target_edge = edge.topr
	elif mouse_pos.y < s.y - border_size:
		if mouse_pos.x <= border_size:
			target_edge = edge.left;
		elif mouse_pos.x >= s.x - border_size:
			target_edge = edge.right
	else:
		if mouse_pos.x <= border_size:
			target_edge = edge.botl;
		elif mouse_pos.x < s.x - border_size:
			target_edge = edge.bottom
		elif mouse_pos.x >= s.x - border_size:
			target_edge = edge.botr
 
	# Determine Cursor Type
	if !maximized:
		match target_edge:
			edge.topl, edge.botr:
				cursor_type = CURSOR_FDIAGSIZE;
			edge.topr, edge.botl:
				cursor_type = CURSOR_BDIAGSIZE;
			edge.top, edge.bottom:
				cursor_type = CURSOR_VSIZE;
			edge.left, edge.right:
				cursor_type = CURSOR_HSIZE;
			_:
				cursor_type = CURSOR_ARROW;
	else:
		cursor_type = CURSOR_ARROW;
			
	set_default_cursor_shape(cursor_type)


func _on_CloseButton_pressed() -> void:
	emit_signal("close_request")
	
func get_dialog_pos(_size):
	var pos = get_global_mouse_position() - _size * 0.5
	var margin = 20
	var s = get_viewport().size
	if pos.x < margin:
		pos.x = margin
	elif pos.x + rect_size.x - margin > s.x:
		pos.x = s.x - rect_size.x - margin
	if pos.y < margin:
		pos.y = margin
	elif pos.y + rect_size.y - margin > s.y:
		pos.y = s.y - rect_size.y - margin
	return pos
	
func show() -> void:
	var pos = get_dialog_pos(rect_size)
	var margin = 20
	var s = get_viewport().size
	if pos.x < margin:
		pos.x = margin
	elif pos.x + rect_size.x - margin > s.x:
		pos.x = s.x - rect_size.x - margin
	if pos.y < margin:
		pos.y = margin
	elif pos.y + rect_size.y - margin > s.y:
		pos.y = s.y - rect_size.y - margin
	rect_position = pos
	.show()
	textedit.cursor_set_line(textedit.get_line_count())
	var line = textedit.get_line(textedit.get_line_count()-1)
	textedit.cursor_set_column(line.length())
	textedit.grab_focus()


func _on_TextEdit_text_changed() -> void:
	set_text(textedit.text)

func edit_text(openText : String, closeText : String):
	var is_selection = textedit.is_selection_active()
	var old_selection = 0
	if is_selection:
		old_selection = textedit.get_selection_text().length()
		textedit.cut()
	textedit.insert_text_at_cursor(openText)
	if is_selection and !edit_mode:
		textedit.paste()
	if !edit_mode:
		textedit.insert_text_at_cursor(closeText)
		textedit.cursor_set_column(textedit.cursor_get_column() - \
			closeText.length() - old_selection)
		if old_selection != 0:
			var sl = textedit.cursor_get_line()
			var sc = textedit.cursor_get_column()
			textedit.select(sl, sc, sl, sc + old_selection)
			textedit.cursor_set_column(sc + old_selection)
	else:
		textedit.cursor_set_column(textedit.cursor_get_column() - \
			openText.length())
		var sl = textedit.cursor_get_line()
		var sc = textedit.cursor_get_column()
		textedit.select(sl, sc, sl, sc + openText.length())
		textedit.cursor_set_column(sc + openText.length())
	textedit.grab_focus()
	edit_mode = false
	hide_all()

func _on_BoldButton_button_down() -> void:
	edit_text("[b]", "[/b]")


func _on_ItalicButton_button_down() -> void:
	edit_text("[i]", "[/i]")


func _on_UnderlineButton_button_down() -> void:
	edit_text("[u]", "[/u]")


func _on_strikethroughButton_button_down() -> void:
	edit_text("[s]", "[/s]")


func _on_CenterTextButton_button_down() -> void:
	edit_text("[center]", "[/center]")


func _on_RightTextButton_button_down() -> void:
	edit_text("[right]", "[/right]")


func _on_LeftTextButton_button_down() -> void:
	edit_text("[left]", "[/left]")


func _on_FontButton_button_down() -> void:
	font_dialog.set_font_type(null)
	edit_mode = false
	show_dialog(font_dialog)

func show_font_dialog(id=null):
	font_dialog.sub_dialog_open = true
	var pos = get_dialog_pos(file_dialog.rect_size)
	var margin = 20
	var s = get_viewport().size
	if pos.x < margin:
		pos.x = margin
	elif pos.x + rect_size.x - margin > s.x:
		pos.x = s.x - rect_size.x - margin
	if pos.y < margin:
		pos.y = margin
	elif pos.y + rect_size.y - margin > s.y:
		pos.y = s.y - rect_size.y - margin
	file_dialog.rect_global_position = pos
	if id == "fonts_02":
		file_dialog.set_valid_files(["tres"])
		file_dialog.set_title("Select a Dynamic Font '*.tres'")
	else:
		file_dialog.set_valid_files(["ttf"])
		file_dialog.set_title("Select a valid Font '*.ttf'")
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = false
	file_dialog.set_allow_external_files_visibility(true)
	file_dialog.id = id
	if sub_dialog_open.size() == 0:
		edit_mode = false
	show_dialog(file_dialog, false)
	
func show_image_dialog(id=null):
	select_image_dialog.sub_dialog_open = true
	var pos = get_dialog_pos(file_dialog.rect_size)
	var margin = 20
	var s = get_viewport().size
	if pos.x < margin:
		pos.x = margin
	elif pos.x + rect_size.x - margin > s.x:
		pos.x = s.x - rect_size.x - margin
	if pos.y < margin:
		pos.y = margin
	elif pos.y + rect_size.y - margin > s.y:
		pos.y = s.y - rect_size.y - margin
	file_dialog.rect_global_position = pos
	file_dialog.set_valid_files(["png"])
	file_dialog.set_title("Select a valid Image")
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = false
	file_dialog.set_allow_external_files_visibility(true)
	file_dialog.id = id
	if sub_dialog_open.size() == 0:
		edit_mode = false
	show_dialog(file_dialog, false)
	
func show_sound_dialog(id=null):
	select_image_dialog.sub_dialog_open = true
	var pos = get_dialog_pos(file_dialog.rect_size)
	var margin = 20
	var s = get_viewport().size
	if pos.x < margin:
		pos.x = margin
	elif pos.x + rect_size.x - margin > s.x:
		pos.x = s.x - rect_size.x - margin
	if pos.y < margin:
		pos.y = margin
	elif pos.y + rect_size.y - margin > s.y:
		pos.y = s.y - rect_size.y - margin
	file_dialog.rect_global_position = pos
	file_dialog.set_valid_files(["wav", "ogg"])
	file_dialog.set_title("Select a valid Audio File")
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = false
	file_dialog.set_allow_external_files_visibility(true)
	file_dialog.id = id
	if sub_dialog_open.size() == 0:
		edit_mode = false
	show_dialog(file_dialog, false)


func _on_FontColorButton_button_down() -> void:
	edit_mode = false
	show_dialog(color_dialog)
	#emit_signal("dialog_color_request", self)

func set_presets(presets : PoolColorArray) -> void:
	color_dialog.set_presets(presets)

func clear_color_presets():
	color_dialog.clear_color_presets()

func _on_ImageButton_button_down() -> void:
	edit_mode = false
	show_dialog(select_image_dialog)


func _on_Button_button_down() -> void:
	var config_id = current_parent.config if current_parent.config != null else 0
	emit_signal("preview_dialog", textedit.text, config_id, self)
#	return
#	var b = $VBoxContainer/BottomPanel/VBoxContainer/Container/PanelContainer9/HBoxContainer/Button
#	if b.text == "PREVIEW":
#		if current_parent != null:
#			b.set("text", "HIDE PREVIEW")
#			emit_signal("open_dialog_preview_request", current_parent.id)
#	else:
#		b.set("text", "PREVIEW")
#		emit_signal("close_dialog_preview_request")


func _on_IndentButton_button_down() -> void:
	edit_text("[indent]", "")


func _on_TableButton_button_down() -> void:
	edit_mode = false
	show_dialog(table_dialog)
	
	
func show_dialog(dialog, pre_hide = true):
	if pre_hide:
		hide_all()
	hide_all_layer.visible = true
		
	dialog.show()
	var m = 0.2
	top_panel.modulate.a = m
	bottom_panel.modulate.a = m
	bottom_panel2.modulate.a = m
	release_focus()
	sub_dialog_open.append(dialog)

	
func hide_all(obj = null):
	get_tree().set_input_as_handled()
	if sub_dialog_open.size() > 1:
		var dialog = sub_dialog_open.pop_back()
		dialog.visible = false
	elif sub_dialog_open.size() == 1:
		var dialog = sub_dialog_open.pop_back()
		dialog.visible = false
		hide_all_layer.visible = false
		textedit.grab_focus()
		top_panel.modulate.a = 1.0
		bottom_panel.modulate.a = 1.0
		bottom_panel2.modulate.a = 1.0

func _on_table_dialog_OK(text, dialog_id) -> void:
	text.begin_text = text.begin_text + "\n" + text.columns
	clear_selection_and_insert_text(text)
	textedit.cursor_set_line(textedit.cursor_get_line() - text.cursor_row)
	textedit.cursor_set_column(text.cursor_column)


func _on_effects_OptionButton_item_selected(index: int) -> void:
	var d = null
	edit_mode = false
	match index:
		1: show_dialog(wave_effect_dialog) # wave
		2: show_dialog(tornado_effect_dialog) # tornado
		3: show_dialog(shake_effect_dialog) # shake
		4: show_dialog(fade_effect_dialog) # fade
		5: show_dialog(rainbow_effect_dialog) # rainbow
		6: show_dialog(ghost_effect_dialog) # ghost
		7: show_dialog(pulse_effect_dialog) # pulse
		8: show_dialog(matrix_effect_dialog) # matrix
		9: show_dialog(fade_ani_effect_dialog) # fade animation
		10: show_dialog(zoom_dialog) # zoom
		11: show_dialog(angle_dialog) # angle
	if d != null:
		show_dialog(d)
		if index != 0:
			text_effects.select(0)
			text_effects.text = "Text Effects"
	text_effects.select(0)
	text_effects.text = "Text Effects"


func _on_wave_effect_dialog_OK(text, dialog_id) -> void:
	edit_text(text.begin_text, text.end_text)


func _on_tornado_effect_dialog_OK(text, dialog_id) -> void:
	text.begin_text = text.begin_text.replace("wave", "tornado")
	text.begin_text = text.begin_text.replace("amp", "radius")
	text.end_text = text.end_text.replace("wave", "tornado")
	edit_text(text.begin_text, text.end_text)


func _on_shake_effect_dialog_OK(text, dialog_id) -> void:
	text.begin_text = text.begin_text.replace("wave", "shake")
	text.begin_text = text.begin_text.replace("amp", "rate")
	text.begin_text = text.begin_text.replace("freq", "level")
	text.end_text = text.end_text.replace("wave", "shake")
	edit_text(text.begin_text, text.end_text)


func _on_fade_effect_dialog_OK(text, dialog_id) -> void:
	text.begin_text = text.begin_text.replace("wave", "fade")
	text.begin_text = text.begin_text.replace("amp", "start")
	text.begin_text = text.begin_text.replace("freq", "length")
	text.end_text = text.end_text.replace("wave", "fade")
	edit_text(text.begin_text, text.end_text)


func _on_rainbow_effect_dialog_OK(text, dialog_id) -> void:
	edit_text(text.begin_text, text.end_text)


func _on_ghost_effect_dialog_OK(text, dialog_id) -> void:
	text.begin_text = text.begin_text.replace("wave", "ghost")
	text.begin_text = text.begin_text.replace("freq", "span")
	text.begin_text = text.begin_text.replace("amp", "freq")
	text.end_text = text.end_text.replace("wave", "ghost")
	edit_text(text.begin_text, text.end_text)


func _on_pulse_effect_dialog_OK(text, dialog_id) -> void:
	edit_text(text.begin_text, text.end_text)


func _on_matrix_effect_dialog_OK(text, dialog_id) -> void:
	edit_text(text.begin_text, text.end_text)


func _on_fade_animation_effect_dialog_OK(text, dialog_id) -> void:
	edit_text(text.begin_text, text.end_text)


func set_cursor(pos) -> void:
	textedit.cursor_set_column(pos.x)
	textedit.cursor_set_line(pos.y)
	yield(get_tree(), "idle_frame")
	textedit.grab_focus()
	
func get_cursor() -> Vector2:
	var pos = Vector2(
		textedit.cursor_get_column(),
		textedit.cursor_get_line()
	)
	return pos


func _on_CustomFileDialog_hide() -> void:
	if sub_dialog_open[-1] == file_dialog: hide_all()
	for i in 10:
		yield(get_tree(), "idle_frame")
	if 	file_dialog.id == "fonts_01" or \
		file_dialog.id == "fonts_02" or \
		file_dialog.id == "image" or \
		file_dialog.id == "sound_01":
		font_dialog.sub_dialog_open = false
	else:
		hide_all_layer.visible = false
		top_panel.modulate.a = 1.0
		bottom_panel.modulate.a = 1.0
		bottom_panel2.modulate.a = 1.0


func _on_TextEditDialog_item_rect_changed() -> void:
	hide_all_layer.rect_global_position = Vector2.ZERO


func _on_hide_all_dialogs_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and
		event.button_index == BUTTON_LEFT):
		hide_all()
		get_tree().set_input_as_handled()


func _on_CustomFileDialog_select_files(files_string_array) -> void:
	if file_dialog.id == "fonts_01":
		var file = files_string_array[0]
		if paths != null:
			file = copy_file(file, paths.fonts).get_file()
		font_dialog.set_font(file)
	elif file_dialog.id == "fonts_02":
		var file = files_string_array[0]
		if ResourceLoader.load(file) is DynamicFont:
			if paths != null:
				file = copy_file(file, paths.fonts).get_file()
			font_dialog.set_dynamic_font(file)
	elif file_dialog.id == "sound_01":
		var file = files_string_array[0]
		if paths != null:
			file = copy_file(file, paths.sounds)
		emit_signal("chosen_sound", file)
		sub_dialog_open.pop_back()
	elif file_dialog.id == "image":
		var file = files_string_array[0]
		if paths != null:
			file = copy_file(file, paths.graphics)
		select_image_dialog.load_image(file)

func copy_file(from : String, to : String) -> String:
	# file outside of this project  v
	# ProjectSettings.localize_path(from).find("res://") == -1:
	var dir = Directory.new()
	var _filename = ProjectSettings.localize_path(from)
	if _filename.find(to) == -1:
		dir.make_dir_recursive(to)
		_filename = from.get_file() # .replace(" ", "_")
		to = to + _filename
	else:
		to = _filename
	
	if !dir.file_exists(to):
		dir.copy(from, to)
	return to


func _on_font_dialog_OK(text, dialog_id) -> void:
	edit_text(text.begin_text, text.end_text)


func _on_color_dialog_OK(text, dialog_id) -> void:
	edit_text(text.begin_text, text.end_text)


func _on_PauseButton_button_down() -> void:
	edit_mode = false
	show_dialog(pause_dialog)


func _on_pause_dialog_OK(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)
	


func _on_PageBreakButton_button_down() -> void:
	var text = {
		"begin_text"	: "[pagebreak]\n",
		"end_text"		: ""
	}
	clear_selection_and_insert_text(text)


func _on_TextEditDialog_visibility_changed() -> void:
	if visible:
		var node = get_node("VBoxContainer/BottomPanel/VBoxContainer/Container")
		node.rect_size.x = node.rect_size.x + 1
		yield(get_tree(), "idle_frame")
		node.rect_size.x = node.rect_size.x - 1
		var b = $VBoxContainer/BottomPanel/VBoxContainer/Container/PanelContainer9/HBoxContainer/Button
		b.set("text", "PREVIEW")
		if maximized:
			set_maximized(false)
		else:
			maximized = {
				"size"		: rect_size,
				"position"	: rect_position
			}
			rect_position += rect_size * 0.5
			rect_size *= 0.5
			maximize_or_restore()
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		textedit.grab_focus()
	else:
		emit_signal("close_dialog_preview_request")
		variables = []
		characters = []
		signals = []
		terms = []


func _unhandled_input(event: InputEvent) -> void:
	if !visible: return
	if event is InputEventKey and event.scancode == KEY_ESCAPE and \
		event.is_pressed():
		if sub_dialog_open.size() > 0:
			hide_all()
		else:
			emit_signal("close_request")
		get_tree().set_input_as_handled()
		
func maximize_or_restore():
	if maximized:
		display_animation(maximized.size, maximized.position)
		maximized = false
		title_label2.text = "(Double click to maximize)"
	else:
		set_maximized()
		

func set_maximized(save_coords = true):
	if save_coords:
		maximized = {
			"size"		: rect_size,
			"position"	: rect_position
		}
	display_animation(get_viewport().size - Vector2(20, 20),
		Vector2(10, 10)
	)
	title_label2.text = "(Double click to restore)"
	
func display_animation(_size, _position):
	$Tween.interpolate_property(self, "rect_size", rect_size,
		_size, 0.3,Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "rect_position", rect_position,
		_position,  0.3,Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.reset_all()
	$Tween.start()


func _on_TextEdit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		textedit.center_viewport_to_cursor()
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
		and event.doubleclick and event.is_pressed():
			try_edit_command()

func try_edit_command():
	var column = textedit.cursor_get_column()
	var line = textedit.cursor_get_line()
	var start_column = column
	var start_line = line
	var command = ""
	var selection_data = {
		"from_line"		: -1,
		"to_line"		: -1,
		"from_column"	: -1,
		"to_column"		: -1
	}
	while line > -1:
		column -= 1
		if column < 0:
			line -= 1
			if line >= 0:
				column = textedit.get_line(line).length()
			else:
				break
		textedit.select(line, column, start_line, start_column)
		var text = textedit.get_selection_text()
		if text.length() > 0:
			if text[0] == "[":
				command += text
				selection_data.from_line = line
				selection_data.from_column = column
				break
			elif text[0] == "]":
				break
	if selection_data.from_line == -1: return
	column = start_column
	line = start_line
	while line < textedit.get_line_count():
		column += 1
		if column > textedit.get_line(line).length():
			line += 1
			column = 0
		textedit.select(start_line, start_column, line, column)
		var text = textedit.get_selection_text()
		if text.length() > 0:
			if text[-1] == "]":
				command += text
				selection_data.to_line = line
				selection_data.to_column = column
				break
	if selection_data.from_line != -1 and selection_data.to_line != -1:
		for i in 15:
			yield(get_tree(), "idle_frame")
			textedit.select(selection_data.from_line, selection_data.from_column,
				selection_data.to_line, selection_data.to_column)
	edit_command(command)

func edit_command(command):
	command = command.trim_prefix("[")
	command = command.trim_suffix("]")
	command = command.split(" ")
	var sub_type = null
	var dialog = null
	if command.size() == 1 and command[0].find("=") != -1:
		command = command[0].split("=")
	match command[0]:
		"font":
			for i in range(1, command.size()):
				if command[i].find("=") != -1:
					var param = command[i].split("=")
					if param.size() >= 2:
						match param[0]:
							"name":
								font_dialog.set_dynamic_font(param[1])
							"type":
								font_dialog.set_font_type_options(int(param[1]))
			dialog = font_dialog
		"color":
			if command.size() >= 2:
				color_dialog.set_color(Color(command[1]))
			dialog = color_dialog
		"face", "character", "img":
			var type_id
			match command[0]:
				"face": type_id = 0
				"character": type_id = 1
				_: type_id = 2
			command.remove(0)
			sub_type = type_id
			select_image_dialog.clean_mode = false
			dialog = select_image_dialog
		"image_effect":
			command.remove(0)
			dialog = image_effects_dialog
		"remove_image":
			command.remove(0)
			dialog = remove_image_dialog
		"show_box_name":
			command.remove(0)
			dialog = show_char_name_dialog
			dialog.variables = variables
			dialog.characters = characters
		"remove_box_name":
			command.remove(0)
			dialog = remove_char_name_dialog
		"pause":
			command.remove(0)
			dialog = pause_dialog
		"play_sound":
			command.remove(0)
			dialog = play_sound_dialog
		"set_lbl":
			command.remove(0)
			dialog = change_lbl_dialog
		"emit_signal":
			command.remove(0)
			emit_signal_dialog.signals = signals
			dialog = emit_signal_dialog
		"var":
			command.remove(0)
			show_variable_dialog.variables = variables
			dialog = show_variable_dialog
		"term":
			command.remove(0)
			show_term_dialog.terms = terms
			dialog = show_term_dialog
		"character_name":
			command.remove(0)
			character_name_dialog.characters = characters
			dialog = character_name_dialog
		"wave":
			command.remove(0)
			sub_type = "wave"
			dialog = wave_effect_dialog
		"tornado":
			command.remove(0)
			sub_type = "tornado"
			dialog = tornado_effect_dialog
		"shake":
			command.remove(0)
			sub_type = "shake"
			dialog = shake_effect_dialog
		"fade":
			command.remove(0)
			sub_type = "fade"
			dialog = fade_effect_dialog
		"ghost":
			command.remove(0)
			sub_type = "ghost"
			dialog = fade_effect_dialog
		"rainbow":
			command.remove(0)
			dialog = rainbow_effect_dialog
		"pulse":
			command.remove(0)
			dialog = pulse_effect_dialog
		"matrix":
			command.remove(0)
			dialog = matrix_effect_dialog
		"fade_animation":
			command.remove(0)
			dialog = fade_ani_effect_dialog
		"zoom":
			command.remove(0)
			dialog = zoom_dialog
		"angle":
			command.remove(0)
			dialog = angle_dialog
		"set_config":
			command.remove(0)
			dialog = show_config_dialog
			dialog.config_ids = config_ids

	if dialog != null:
		edit_mode = true
		show_dialog(dialog)
		if dialog.has_method("set_parameters"):
			for i in 2: # Double check because with 1 sometimes the dialog no refresh :(
				yield(get_tree(), "idle_frame")
				if sub_type == null:
					dialog.set_parameters(command)
				else:
					dialog.set_parameters(sub_type, command)


func _on_select_image_dialog_OK(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)


func _on_image_effects_button_down() -> void:
	edit_mode = false
	show_dialog(image_effects_dialog)


func _on_remove_images_button_down() -> void:
	edit_mode = false
	show_dialog(remove_image_dialog)


func _on_ShowNameButton_button_down() -> void:
	show_char_name_dialog.variables = variables
	show_char_name_dialog.characters = characters
	edit_mode = false
	show_dialog(show_char_name_dialog)


func _on_RemoveNameButton_button_down() -> void:
	edit_mode = false
	show_dialog(remove_char_name_dialog)


func _on_PlaySoundButton_button_down() -> void:
	edit_mode = false
	show_dialog(play_sound_dialog)


func _on_LetterByLetterButton_button_down() -> void:
	edit_mode = false
	show_dialog(change_lbl_dialog)


func _on_EmitSignalButton_button_down() -> void:
	emit_signal_dialog.signals = signals
	edit_mode = false
	show_dialog(emit_signal_dialog)
	
func _on_ShowVariableButton_button_down() -> void:
	show_variable_dialog.variables = variables
	edit_mode = false
	show_dialog(show_variable_dialog)
	
func _on_ShowTermButton_button_down() -> void:
	show_term_dialog.terms = terms
	edit_mode = false
	show_dialog(show_term_dialog)

func fix_hide_layer_size():
	hide_all_layer.rect_size = get_viewport().size


func clear_selection_and_insert_text(text):
	if !edit_mode:
		var is_selection = textedit.is_selection_active()
		if text != null:
			if is_selection:
				var c = textedit.get_selection_to_column()
				var r = textedit.get_selection_to_line()
				textedit.deselect()
				textedit.cursor_set_line(r)
				textedit.cursor_set_column(c)
			edit_text(text.begin_text, text.end_text)
			textedit.cursor_set_column(textedit.cursor_get_column() +
				text.end_text.length())
			textedit.grab_focus()
	else:
		if text != null:
			edit_text(text.begin_text, text.end_text)


func _on_image_effects_dialog_OK(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)

func remove_image_dialog(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)


func _on_show_char_name_dialog_OK(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)


func _on_remove_char_name_dialog_OK(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)


func _on_change_letter_by_letter_dialog_OK(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)


func _on_emit_signal_dialog_OK(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)


func _on_play_sound_dialog_OK(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)


func _on_show_variable_dialog_OK(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)
	
func _on_show_term_dialog_OK(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)


func _on_FontColorButton_hide() -> void:
	if color_dialog == null: return
	get_tree().current_scene.set_color_presets(color_dialog.get_presets())


func _on_zoom_effect_dialog_OK(text, dialog_id) -> void:
	edit_text(text.begin_text, text.end_text)


func _on_angle_effect_dialog_OK(text, dialog_id) -> void:
	edit_text(text.begin_text, text.end_text)


func _on_show_character_name_dialog_OK(text, dialog_id) -> void:
	edit_text(text.begin_text, text.end_text)


func _on_CharacterNameButton_button_down() -> void:
	character_name_dialog.characters = characters
	edit_mode = false
	show_dialog(character_name_dialog)


func _on_SeparatorButton_button_down() -> void:
	var text = {
		"begin_text"	: "\n■\n",
		"end_text"		: ""
	}
	clear_selection_and_insert_text(text)


func _on_ChangeConfigButton_button_down() -> void:
	show_config_dialog.set_configs(config_ids)
	edit_mode = false
	show_dialog(show_config_dialog)


func _on_select_config_dialog_OK(text, dialog_id) -> void:
	clear_selection_and_insert_text(text)
