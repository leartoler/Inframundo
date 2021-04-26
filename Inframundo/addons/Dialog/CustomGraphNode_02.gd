tool
extends CustomGraphNode
class_name CustomGraphNode_02

onready var color_picker_button		= $VBoxContainer/ContentContainer/HBoxContainer1/ColorPickerButton

var collapse_images = {}

signal show_font_dialog_request(obj, id)
signal show_audio_dialog_request(obj)
signal play_audio_request(text)
signal show_image_dialog_request(obj)
signal show_dialog_color_request(obj)
signal show_dialog_input_actions_request(data)
signal show_dialog_ninepatch(img, patchs)
signal set_as_default_config(data)
signal show_preview_config(config)

var input_actions = {
	"resume_actions"	: ["ui_accept"],
	"up_actions"		: ["ui_up"],
	"down_actions"		: ["ui_down"]
}

var update_patchs_limits_enabled = true

var paths

func _ready() -> void:
	show_on_top = true
	set_initial_textures()
	connect_all()
	set_images()

	if Engine.editor_hint:
		find_node("ScrollContainer").rect_clip_content = false
		expand_or_collapse_all(1, self)
	else:
		find_node("ScrollContainer").rect_clip_content = true
		expand_or_collapse_all(0, self)

func set_paths(_paths):
	paths = _paths
	for i in range(1, 6):
		find_node("image_panel%s_c1" % i).paths = paths

func set_initial_textures():
	var tex = ImageTexture.new()
	var img = load_texture("res://addons/Dialog/Graphics/arrow_right2.png")
	collapse_images.open = img
	img = load_texture("res://addons/Dialog/Graphics/arrow_down.png")
	collapse_images.close = img

func set_images():
	for i in 8:
		update_image_value(null, i)

func connect_all():
	connect("focus_entered", self, "_on_CustomGraphNode_focus_entered_new")
	
	var spinboxes = [
		[8, 9, 10], [8, 9, 10], [8, 9, 10],
		[2, 3, 4, 5, 6, 9, 11],
		[2, 3, 4, 6, 7, 9, 11], [8, 9, 10], [8, 9, 10],
		[2, 3, 4, 5, 6, 9, 11]
	]
	var options = [
		[6, 7], [6, 7], [6, 7], [], [5], [6, 7], [6, 7]
	]
	var checkeds = [
		[11], [11], [11], [], [], [11], [11], [8]
	]
	var colors = [
		[12], [12], [12], [7], [13], [12], [12], [7]
	]
	for i in spinboxes.size():
		for j in spinboxes[i].size():
			var node = find_node("image_panel%s_c%s" % [i+1, spinboxes[i][j]])
			node.connect("value_changed", self, "update_image_value", [i])
			if range(2, 7).has(spinboxes[i][j]):
				node.connect("value_changed", self,
					"update_patchs_limits", [i+1, spinboxes[i][j]])
	for i in options.size():
		for j in options[i].size():
			var node = find_node("image_panel%s_c%s" % [i+1, options[i][j]])
			node.connect("item_selected", self, "update_image_value", [i])
	for i in checkeds.size():
		for j in checkeds[i].size():
			var node = find_node("image_panel%s_c%s" % [i+1, checkeds[i][j]])
			node.connect("toggled", self, "update_image_value", [i])
	for i in colors.size():
		for j in colors[i].size():
			var node = find_node("image_panel%s_c%s" % [i+1, colors[i][j]])
			node.connect("color_changed", self, "update_image_value", [i])
	
	connect_collapse_labels(self)
	set_auto_apply_to_spinboxes(self)
	
	var b_images = ["default_font_c5", "left_box_name_c10",
		"right_box_name_c10", "options_box_c10",
		"image_panel1_c12", "image_panel2_c12", "image_panel3_c12",
		"image_panel4_c7", "image_panel5_c8", "image_panel6_c12",
		"image_panel7_c12", "ColorPickerButton", "image_panel8_c7"]


	for c in b_images:
		var node = find_node(c)
		node.connect("toggled", self, "color_button_pressed", [node])


func select_parent():
	if !focused:
		var focus = get_focus_owner()
		.select()
		yield(get_tree(), "idle_frame")
		if focus != null: focus.grab_focus()


func load_texture(img):
	return load(img)
	# Obsolete??? vvv
	var i = Image.new()
	i.load(img)
	var t = ImageTexture.new()
	t.create_from_image(i)
	return t


func connect_collapse_labels(obj):
	if obj is Label and obj.name.find("CollapseLabel") == 0:
		if !obj.is_connected("gui_input", self, "_on_collapse_Label_gui_input"):
			obj.connect("gui_input", self, "_on_collapse_Label_gui_input", [obj])
		obj.mouse_filter = MOUSE_FILTER_STOP
		obj.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		obj.get_child(0).texture = collapse_images.open
		expand_or_collapse(obj)
		
	if "focus_mode" in obj and \
		!obj.is_connected("focus_entered", self, "select_parent"):
		obj.connect("focus_entered", self, "select_parent")
		
	if obj.get_child_count() > 0:
		for child in obj.get_children():
			connect_collapse_labels(child)

func set_auto_apply_to_spinboxes(obj):
	if obj is SpinBox:
		var lineedit = obj.get_line_edit()
		lineedit.connect("focus_exited", obj, "apply")
		lineedit.caret_blink = true

	if obj.get_child_count() > 0:
		for child in obj.get_children():
			set_auto_apply_to_spinboxes(child)

func _on_CustomGraphNode_focus_entered_new():
	pass
#	yield(get_tree(), "idle_frame")



func select(force_select = false) -> void:
	.select(force_select)
	if !force_select:
		_on_CustomGraphNode_focus_entered_new()


func _on_ColorPickerButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		yield(get_tree(), "idle_frame")
		var margin = 40
		var p = color_picker_button.get_picker().get_parent()
		var s = get_viewport().size - Vector2(margin, margin)
		p.rect_global_position = (get_global_mouse_position() -
			p.rect_size * 0.5 + Vector2(0, 230))
		if p.rect_global_position.x < margin:
			p.rect_global_position.x = margin
		elif p.rect_global_position.x + p.rect_size.x > s.x:
			p.rect_global_position.x = s.x - p.rect_size.x
		if p.rect_global_position.y < margin:
			p.rect_global_position.y = margin
		elif p.rect_global_position.y + p.rect_size.y > s.y:
			p.rect_global_position.y = s.y - p.rect_size.y


func get_data() -> Dictionary:
	var config = {
		"letter_by_letter"				: get_letter_by_letter_config(),
		"default_font"					: get_default_font_config(),
		"dialog_box_config"				: get_dialog_box_config(),
		"left_box_name_config"			: get_left_box_name_config(),
		"right_box_name_config"			: get_right_box_name_config(),
		"options_box_config"			: get_options_box_config(),
		"background_image"				: get_image_data(0),
		"name_box_background_image"		: get_image_data(1),
		"options_box_background_image"	: get_image_data(2),
		"options_answerd_background_image"	: {
			"no_selected"		: get_image_data(5),
			"selected"			: get_image_data(6),
			"page_indicator"	: get_image_data(7)
		},
		"options_cursor_image"			: get_image_data(3),
		"resume_button_image"			: get_image_data(4),
		"contents_expanded"				: find_node("EXPANDBUTTON").pressed,
		"input_actions"					: input_actions,
	}
	var data = {
		"name"				: name,
		"id"				: id,
		"title"				: title,
		"frame_color"		: frame_color,
		"position"			: rect_position,
		"size"				: rect_size,
		"connections"		: connections,
		"collapsed"			: typeof(collapsed) == TYPE_DICTIONARY,
		"type"				: "config",
		"config"			: config,
		"hide_close_button"	: !show_close_btn,
	}
	return data

func set_data(data):
	name = data.name
	id = data.id
	set_title_text(data.title)
	color_picker_button.color = data.frame_color
	set_frame_color(color_picker_button.color)
	rect_position = data.position
	rect_size = data.size
	connections = data.connections
	if data.hide_close_button:
		set_close_btn_visibility(false)
	if data.collapsed: expand_collapse()
	set_config(data.config)
	if !data.collapsed and data.config.contents_expanded:
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		_on_expand_collapse_Button_toggled(true)
		find_node("EXPANDBUTTON").pressed = true
		expand_or_collapse_all(1, self)

func set_config(config):
	set_letter_by_letter_config(config.letter_by_letter)
	set_default_font_config(config.default_font)
	set_dialog_box_config(config.dialog_box_config)
	set_left_box_name_config(config.left_box_name_config)
	set_right_box_name_config(config.right_box_name_config)
	set_options_box_config(config.options_box_config)
	set_background_image_config(config.background_image)
	set_name_box_background_image_config(config.name_box_background_image)
	set_options_background_image_config(config.options_box_background_image)
	set_options_answers_images_config(config.options_answerd_background_image)
	set_options_cursor_image_config(config.options_cursor_image)
	set_resume_button_image_config(config.resume_button_image)
	input_actions = config.input_actions
	set_images()

func set_letter_by_letter_config(data):
	find_node("letter_by_letter_c1").pressed = data.enabled
	find_node("letter_by_letter_c2").text = data.sound
	find_node("letter_by_letter_c3").value = data.text_speed
	find_node("letter_by_letter_c2b").text = data.ok_sound
	find_node("letter_by_letter_c4").pressed = data.skip


func get_letter_by_letter_config() -> Dictionary:
	var data = {}
	data.enabled = find_node("letter_by_letter_c1").pressed
	data.sound = find_node("letter_by_letter_c2").text
	data.ok_sound = find_node("letter_by_letter_c2b").text
	data.text_speed = find_node("letter_by_letter_c3").value
	data.skip = find_node("letter_by_letter_c4").pressed
	return data

func set_default_font_config(data):
	find_node("default_font_c1").text = data.normal
	find_node("default_font_c2").text = data.bold
	find_node("default_font_c3").text = data.italic
	find_node("default_font_c4").text = data.bold_italic
	find_node("default_font_c5").color = data.color

func get_default_font_config() -> Dictionary:
	var data = {}
	data.normal = find_node("default_font_c1").text
	data.bold = find_node("default_font_c2").text
	data.italic = find_node("default_font_c3").text
	data.bold_italic = find_node("default_font_c4").text
	data.color = find_node("default_font_c5").color
	return data

func set_dialog_box_config(data):
	find_node("dialog_box_c1").value = data.size.x
	find_node("dialog_box_c2").value = data.size.y
	find_node("dialog_box_c3").pressed = data.fit_width
	find_node("dialog_box_c8").select(data.position.type)
	find_node("dialog_box_c9").value = data.position.dest.x
	find_node("dialog_box_c10").value = data.position.dest.y
	find_node("dialog_box_c14").value = data.lines_shown
	find_node("dialog_box_c15").value = data.face_size.x
	find_node("dialog_box_c16").value = data.face_size.y
	find_node("dialog_box_c11").value = data.parent_margins.left
	find_node("dialog_box_c11b").value = data.parent_margins.right
	find_node("dialog_box_c12").value = data.parent_margins.top
	find_node("dialog_box_c12b").value = data.parent_margins.bottom
	find_node("dialog_box_c4").value = data.message_margins.left
	find_node("dialog_box_c5").value = data.message_margins.right
	find_node("dialog_box_c6").value = data.message_margins.top
	find_node("dialog_box_c7").value = data.message_margins.bottom
	find_node("dialog_box_c17").pressed = data.pause_game
	find_node("dialog_box_c18").value = data.face_text_separation
	find_node("dialog_box_c19").select(data.appearance_animation)
	find_node("dialog_box_c20").select(data.disappearance_animation)
	find_node("dialog_box_c21").select(data.default_align)
	find_node("dialog_box_c22").pressed = data.autowrap
	find_node("dialog_box_c23").pressed = data.clip_text

func get_dialog_box_config() -> Dictionary:
	var data = {}
	data.size = Vector2()
	data.size.x = find_node("dialog_box_c1").value
	data.size.y = find_node("dialog_box_c2").value
	data.fit_width = find_node("dialog_box_c3").pressed
	var pos = Vector2(find_node("dialog_box_c9").value,
		find_node("dialog_box_c10").value)
	data.position = {
		"type"		: find_node("dialog_box_c8").get_selected_id(),
		"dest"		: pos
	}
	data.lines_shown = find_node("dialog_box_c14").value
	data.face_size = Vector2()
	data.face_size.x = find_node("dialog_box_c15").value
	data.face_size.y = find_node("dialog_box_c16").value
	data.parent_margins = {
		"left"		: find_node("dialog_box_c11").value,
		"right"		: find_node("dialog_box_c11b").value,
		"top"		: find_node("dialog_box_c12").value,
		"bottom"	: find_node("dialog_box_c12b").value,
	}
	data.message_margins = {
		"left"		: find_node("dialog_box_c4").value,
		"right"		: find_node("dialog_box_c5").value,
		"top"		: find_node("dialog_box_c6").value,
		"bottom"	: find_node("dialog_box_c7").value,
	}
	data.pause_game = find_node("dialog_box_c17").pressed
	data.face_text_separation = find_node("dialog_box_c18").value
	data.appearance_animation = find_node("dialog_box_c19").get_selected_id()
	data.disappearance_animation = find_node("dialog_box_c20").get_selected_id()
	data.default_align = find_node("dialog_box_c21").get_selected_id()
	data.autowrap = find_node("dialog_box_c22").pressed
	data.clip_text = find_node("dialog_box_c23").pressed
	return data

func set_left_box_name_config(data):
	find_node("left_box_name_c1").value = data.size.x
	find_node("left_box_name_c2").value = data.size.y
	find_node("left_box_name_c3").pressed = data.fit_width
	find_node("left_box_name_c8").text = data.font
	find_node("left_box_name_c9").select(data.align)
	find_node("left_box_name_c10").color = data.color
	find_node("left_box_name_c13").value = data.text_margins.left
	find_node("left_box_name_c14").value = data.text_margins.right
	find_node("left_box_name_c15").value = data.text_margins.top
	find_node("left_box_name_c16").value = data.text_margins.bottom
	find_node("left_box_name_c13b").value = data.parent_margins.left
	find_node("left_box_name_c14b").value = data.parent_margins.right
	find_node("left_box_name_c15b").value = data.parent_margins.top
	find_node("left_box_name_c16b").value = data.parent_margins.bottom

func get_left_box_name_config() -> Dictionary:
	var data = {}
	data.size = Vector2()
	data.size.x = find_node("left_box_name_c1").value
	data.size.y = find_node("left_box_name_c2").value
	data.fit_width = find_node("left_box_name_c3").pressed
	data.font = find_node("left_box_name_c8").text
	data.align = find_node("left_box_name_c9").get_selected_id()
	data.color = find_node("left_box_name_c10").color
	data.parent_margins = {
		"left"		: find_node("left_box_name_c13b").value,
		"right"		: find_node("left_box_name_c14b").value,
		"top"		: find_node("left_box_name_c15b").value,
		"bottom"	: find_node("left_box_name_c16b").value,
	}
	data.text_margins = {
		"left"		: find_node("left_box_name_c13").value,
		"right"		: find_node("left_box_name_c14").value,
		"top"		: find_node("left_box_name_c15").value,
		"bottom"	: find_node("left_box_name_c16").value,
	}
	return data

func set_right_box_name_config(data):
	find_node("right_box_name_c1").value = data.size.x
	find_node("right_box_name_c2").value = data.size.y
	find_node("right_box_name_c3").pressed = data.fit_width
	find_node("right_box_name_c8").text = data.font
	find_node("right_box_name_c9").select(data.align)
	find_node("right_box_name_c10").color = data.color
	find_node("right_box_name_c13").value = data.text_margins.left
	find_node("right_box_name_c14").value = data.text_margins.right
	find_node("right_box_name_c15").value = data.text_margins.top
	find_node("right_box_name_c16").value = data.text_margins.bottom
	find_node("right_box_name_c13b").value = data.parent_margins.left
	find_node("right_box_name_c14b").value = data.parent_margins.right
	find_node("right_box_name_c15b").value = data.parent_margins.top
	find_node("right_box_name_c16b").value = data.parent_margins.bottom

func get_right_box_name_config() -> Dictionary:
	var data = {}
	data.size = Vector2()
	data.size.x = find_node("right_box_name_c1").value
	data.size.y = find_node("right_box_name_c2").value
	data.fit_width = find_node("right_box_name_c3").pressed
	data.font = find_node("right_box_name_c8").text
	data.align = find_node("right_box_name_c9").get_selected_id()
	data.color = find_node("right_box_name_c10").color
	data.parent_margins = {
		"left"		: find_node("right_box_name_c13b").value,
		"right"		: find_node("right_box_name_c14b").value,
		"top"		: find_node("right_box_name_c15b").value,
		"bottom"	: find_node("right_box_name_c16b").value,
	}
	data.text_margins = {
		"left"		: find_node("right_box_name_c13").value,
		"right"		: find_node("right_box_name_c14").value,
		"top"		: find_node("right_box_name_c15").value,
		"bottom"	: find_node("right_box_name_c16").value,
	}
	return data

func set_options_box_config(data):
	find_node("options_box_c1").value = data.size.x
	find_node("options_box_c2").value = data.size.y
	find_node("options_box_c3").pressed = data.fit_width
	find_node("options_box_c8").text = data.font
	find_node("options_box_c9").select(data.align)
	find_node("options_box_c10").color = data.color
	find_node("options_box_c11").select(data.position)
	find_node("options_box_c14").value = data.text_margins.left
	find_node("options_box_c15").value = data.text_margins.right
	find_node("options_box_c16").value = data.text_margins.top
	find_node("options_box_c17").value = data.text_margins.bottom
	find_node("options_box_c14b").value = data.offset.x
	find_node("options_box_c15b").value = data.offset.y
	find_node("options_box_c21").value = data.vertical_separation
	find_node("options_box_c22").text = data.cursor_fx
	find_node("options_box_c22b").text = data.ok_fx

func get_options_box_config() -> Dictionary:
	var data = {}
	data.size = Vector2()
	data.size.x = find_node("options_box_c1").value
	data.size.y = find_node("options_box_c2").value
	data.fit_width = find_node("options_box_c3").pressed
	data.font = find_node("options_box_c8").text
	data.align = find_node("options_box_c9").get_selected_id()
	data.color = find_node("options_box_c10").color
	data.position = find_node("options_box_c11").get_selected_id()
	data.offset = Vector2(
		find_node("options_box_c14b").value,
		find_node("options_box_c15b").value
	)
	data.text_margins = {
		"left"		: find_node("options_box_c14").value,
		"right"		: find_node("options_box_c15").value,
		"top"		: find_node("options_box_c16").value,
		"bottom"	: find_node("options_box_c17").value,
	}
	data.vertical_separation = find_node("options_box_c21").value
	data.cursor_fx = find_node("options_box_c22").text
	data.ok_fx = find_node("options_box_c22b").text
	return data

func _on_collapse_Label_gui_input(event: InputEvent, label = null) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and \
		event.is_pressed():
		expand_or_collapse(label)

func expand_or_collapse(label, mode = null):
	var index = label.get_index() + 1
	var tex = label.get_child(0)
	if mode != null:
		if mode == 0:
			tex.texture = collapse_images.close
			label.get_parent().get_child(index).visible = false
		else:
			tex.texture = collapse_images.open
			label.get_parent().get_child(index).visible = true
	else:
		if tex.texture == collapse_images.open:
			tex.texture = collapse_images.close
			label.get_parent().get_child(index).visible = false
		else:
			tex.texture = collapse_images.open
			label.get_parent().get_child(index).visible = true
		select()

func expand_or_collapse_all(mode, obj):
	if obj is Label and obj.name.find("CollapseLabel") == 0:
		expand_or_collapse(obj, mode)
	if obj.get_child_count() > 0:
		for child in obj.get_children():
			expand_or_collapse_all(mode, child)
	if mode == 1:
		rect_size.y = 752
	else:
		rect_size.y = 227
	select()

func _on_expand_collapse_Button_toggled(button_pressed: bool) -> void:
	var node = find_node("EXPANDBUTTON")
	if button_pressed:
		node.text = "Collapse All"
	else:
		node.text = "Expand All"
	var mode = 0 if !button_pressed else 1
	expand_or_collapse_all(mode, self)


func _on_default_normal_font_LineEdit_gui_input(event: InputEvent) -> void:
	var node = find_node("default_font_c1")
	check_for_dialog_font_request(event, node, 0)

func _on_default_bold_font_LineEdit_gui_input(event: InputEvent) -> void:
	var node = find_node("default_font_c2")
	check_for_dialog_font_request(event, node, 1)

func _on_default_italic_font_LineEdit_gui_input(event: InputEvent) -> void:
	var node = find_node("default_font_c3")
	check_for_dialog_font_request(event, node, 2)

func _on_default_bold_italic_font_LineEdit_gui_input(event: InputEvent) -> void:
	var node = find_node("default_font_c4")
	check_for_dialog_font_request(event, node, 3)

func _on_left_box_name_font_LineEdit_gui_input(event: InputEvent) -> void:
	var node = find_node("left_box_name_c8")
	check_for_dialog_font_request(event, node, 0)

func _on_right_box_name_font_LineEdit_gui_input(event: InputEvent) -> void:
	var node = find_node("right_box_name_c8")
	check_for_dialog_font_request(event, node, 0)

func _on_options_box_font_LineEdit_gui_input(event: InputEvent) -> void:
	var node = find_node("options_box_c8")
	check_for_dialog_font_request(event, node, 0)

func check_for_dialog_font_request(event, node, id):
	if event is InputEventMouseButton and event.button_index == 1 and \
		event.is_pressed():
		emit_signal("show_font_dialog_request", node, id)


func _on_letter_by_leter_fx_LineEdit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and \
		event.is_pressed():
		var node = find_node("letter_by_letter_c2")
		emit_signal("show_audio_dialog_request", node)

func _on_letter_by_leter_fx2_LineEdit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and \
		event.is_pressed():
		var node = find_node("letter_by_letter_c2b")
		emit_signal("show_audio_dialog_request", node)

func _on_options_cursor_fx_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and \
		event.is_pressed():
		var node = find_node("options_box_c22")
		emit_signal("show_audio_dialog_request", node)

func _on_options_cursor_ok_fx_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and \
		event.is_pressed():
		var node = find_node("options_box_c22b")
		emit_signal("show_audio_dialog_request", node)

func _on_play_audio_TextureButton_button_down(id : int) -> void:
	var text
	match id:
		0: text = find_node("letter_by_letter_c2").text
		1: text = find_node("letter_by_letter_c2b").text
		2: text = find_node("options_box_c22").text
		3: text = find_node("options_box_c22b").text
	if text.length() > 0:
		emit_signal("play_audio_request", text)


func _on_dialog_box_fit_width_CheckBox_toggled(button_pressed: bool) -> void:
	var node = find_node("dialog_box_c1")
	var node2 = find_node("dialog_box_c8")
	node.editable = !button_pressed
	node = find_node("dialog_box_c9")
	node.editable = !button_pressed and node2.get_selected_id() == 3
	node = find_node("dialog_box_c10")
	node.editable = !button_pressed and node2.get_selected_id() == 3
	node = find_node("dialog_box_c11")
	node.editable = button_pressed
	node = find_node("dialog_box_c11b")
	node.editable = button_pressed
	node = find_node("dialog_box_c12")
	node.editable = button_pressed
	node = find_node("dialog_box_c12b")
	node.editable = button_pressed
	node2.set_item_disabled(3, button_pressed)
	if button_pressed and node2.get_selected_id() == 3:
		node2.select(2)


func _on_dialog_box_position_OptionButton_item_selected(index: int) -> void:
	var node = find_node("dialog_box_c9")
	var node2 = find_node("dialog_box_c3")
	node.editable = index == 3 and !node2.pressed
	node = find_node("dialog_box_c10")
	node.editable = index == 3 and !node2.pressed
	node = find_node("dialog_box_c11")
	node.editable = index != 3 or node2.pressed
	node = find_node("dialog_box_c11b")
	node.editable = index != 3 or node2.pressed
	node = find_node("dialog_box_c12")
	node.editable = index != 3 or node2.pressed
	node = find_node("dialog_box_c12b")
	node.editable = index != 3 or node2.pressed


func _on_remove_imagen_Button_down(id: int) -> void:
	var node = get_image(id)
	node.remove_image()
	node.get_parent().get_parent().propagate_call("set_disabled", [true])
	node.get_parent().get_parent().propagate_call("set_editable", [false])

func get_image(id):
	var node
	match id:
		0: node = find_node("image_panel1_c1")
		1: node = find_node("image_panel2_c1")
		2: node = find_node("image_panel3_c1")
		3: node = find_node("image_panel4_c1")
		4: node = find_node("image_panel5_c1")
		5: node = find_node("image_panel6_c1")
		6: node = find_node("image_panel7_c1")
		7: node = find_node("image_panel8_c1")
	return node


func _on_image_dialog_show_request(obj, id: int) -> void:
	emit_signal("show_image_dialog_request", obj)


func update_image_value(value, id: int) -> void:
	if !update_patchs_limits_enabled: return
	var data = get_image_data(id)
	var img = get_image(id)
	img.set_frames(data)
	img.set_texture_modulate(data.color)
	if data.has("patch_margin_left"):
		img.set_patch(data)
	var node = img.find_node("TextureRect")
	if node.rect_size > img.rect_min_size:
		var scale = node.rect_size / img.rect_min_size
		img.rect_scale = scale


func set_background_image_config(data):
	find_node("image_panel1_c1").load_image(data.image)
	find_node("image_panel1_c2").value = data.patch_margin_left
	find_node("image_panel1_c3").value = data.patch_margin_right
	find_node("image_panel1_c4").value = data.patch_margin_top
	find_node("image_panel1_c5").value = data.patch_margin_bottom
	find_node("image_panel1_c6").select(data.axis_stretch_horizontal)
	find_node("image_panel1_c7").select(data.axis_stretch_vertical)
	find_node("image_panel1_c8").value = data.frames.x
	find_node("image_panel1_c9").value = data.frames.y
	find_node("image_panel1_c10").value = data.delay
	find_node("image_panel1_c11").pressed = data.draw_center
	find_node("image_panel1_c12").color = data.color

func set_name_box_background_image_config(data):
	find_node("image_panel2_c1").load_image(data.image)
	find_node("image_panel2_c2").value = data.patch_margin_left
	find_node("image_panel2_c3").value = data.patch_margin_right
	find_node("image_panel2_c4").value = data.patch_margin_top
	find_node("image_panel2_c5").value = data.patch_margin_bottom
	find_node("image_panel2_c6").select(data.axis_stretch_horizontal)
	find_node("image_panel2_c7").select(data.axis_stretch_vertical)
	find_node("image_panel2_c8").value = data.frames.x
	find_node("image_panel2_c9").value = data.frames.y
	find_node("image_panel2_c10").value = data.delay
	find_node("image_panel2_c11").pressed = data.draw_center
	find_node("image_panel2_c12").color = data.color

func set_options_background_image_config(data):
	find_node("image_panel3_c1").load_image(data.image)
	find_node("image_panel3_c2").value = data.patch_margin_left
	find_node("image_panel3_c3").value = data.patch_margin_right
	find_node("image_panel3_c4").value = data.patch_margin_top
	find_node("image_panel3_c5").value = data.patch_margin_bottom
	find_node("image_panel3_c6").select(data.axis_stretch_horizontal)
	find_node("image_panel3_c7").select(data.axis_stretch_vertical)
	find_node("image_panel3_c8").value = data.frames.x
	find_node("image_panel3_c9").value = data.frames.y
	find_node("image_panel3_c10").value = data.delay
	find_node("image_panel3_c11").pressed = data.draw_center
	find_node("image_panel3_c12").color = data.color

func set_options_answers_images_config(data):
	# no selected
	data = [data.no_selected, data.selected, data.page_indicator]
	for i in range(6, 8):
		var n = "image_panel%s_c" % i
		find_node("%s1" % n).load_image(data[i-6].image)
		find_node("%s2" % n).value = data[i-6].patch_margin_left
		find_node("%s3" % n).value = data[i-6].patch_margin_right
		find_node("%s4" % n).value = data[i-6].patch_margin_top
		find_node("%s5" % n).value = data[i-6].patch_margin_bottom
		find_node("%s6" % n).select(data[i-6].axis_stretch_horizontal)
		find_node("%s7" % n).select(data[i-6].axis_stretch_vertical)
		find_node("%s8" % n).value = data[i-6].frames.x
		find_node("%s9" % n).value = data[i-6].frames.y
		find_node("%s10" % n).value = data[i-6].delay
		find_node("%s11" % n).pressed = data[i-6].draw_center
		find_node("%s12" % n).color = data[i-6].color
	find_node("image_panel8_c1").load_image(data[2].image)
	find_node("image_panel8_c2").value = data[2].frames.x
	find_node("image_panel8_c3").value = data[2].frames.y
	find_node("image_panel8_c4").value = data[2].delay
	find_node("image_panel8_c5").value = data[2].size.x
	find_node("image_panel8_c6").value = data[2].size.y
	find_node("image_panel8_c8").pressed = data[2].auto_size
	find_node("image_panel8_c9").value = data[2].offset.x
	find_node("image_panel8_c11").value = data[2].offset.y
	find_node("image_panel8_c7").color = data[2].color

func set_options_cursor_image_config(data):
	find_node("image_panel4_c1").load_image(data.image)
	find_node("image_panel4_c2").value = data.frames.x
	find_node("image_panel4_c3").value = data.frames.y
	find_node("image_panel4_c4").value = data.delay
	find_node("image_panel4_c5").value = data.size.x
	find_node("image_panel4_c6").value = data.size.y
	find_node("image_panel4_c8").pressed = data.auto_size
	find_node("image_panel4_c9").value = data.offset.x
	find_node("image_panel4_c11").value = data.offset.y
	find_node("image_panel4_c7").color = data.color

func set_resume_button_image_config(data):
	find_node("image_panel5_c1").load_image(data.image)
	find_node("image_panel5_c2").value = data.frames.x
	find_node("image_panel5_c3").value = data.frames.y
	find_node("image_panel5_c4").value = data.delay
	find_node("image_panel5_c5").select(data.position)
	find_node("image_panel5_c6").value = data.size.x
	find_node("image_panel5_c7").value = data.size.y
	find_node("image_panel5_c8").pressed = data.auto_size
	find_node("image_panel5_c9").value = data.offset.x
	find_node("image_panel5_c11").value = data.offset.y
	find_node("image_panel5_c13").color = data.color
	

func get_image_data(id) -> Dictionary:
	var data = {}; var node; var v = Vector2.ZERO;
	match id:
		0:
			node = find_node("image_panel1_c1")
			data.image = node.image
			node = find_node("image_panel1_c2")
			data.patch_margin_left = node.value
			node = find_node("image_panel1_c3")
			data.patch_margin_right = node.value
			node = find_node("image_panel1_c4")
			data.patch_margin_top = node.value
			node = find_node("image_panel1_c5")
			data.patch_margin_bottom = node.value
			node = find_node("image_panel1_c6")
			data.axis_stretch_horizontal = node.get_selected_id()
			node = find_node("image_panel1_c7")
			data.axis_stretch_vertical = node.get_selected_id()
			node = find_node("image_panel1_c8")
			v.x = node.value
			node = find_node("image_panel1_c9")
			v.y = node.value
			data.frames = v
			node = find_node("image_panel1_c10")
			data.delay = float(node.value)
			node = find_node("image_panel1_c11")
			data.draw_center = node.pressed
			node = find_node("image_panel1_c12")
			data.color = node.color
		1:
			node = find_node("image_panel2_c1")
			data.image = node.image
			node = find_node("image_panel2_c2")
			data.patch_margin_left = node.value
			node = find_node("image_panel2_c3")
			data.patch_margin_right = node.value
			node = find_node("image_panel2_c4")
			data.patch_margin_top = node.value
			node = find_node("image_panel2_c5")
			data.patch_margin_bottom = node.value
			node = find_node("image_panel2_c6")
			data.axis_stretch_horizontal = node.get_selected_id()
			node = find_node("image_panel2_c7")
			data.axis_stretch_vertical = node.get_selected_id()
			node = find_node("image_panel2_c8")
			v.x = node.value
			node = find_node("image_panel2_c9")
			v.y = node.value
			data.frames = v
			node = find_node("image_panel2_c10")
			data.delay = float(node.value)
			node = find_node("image_panel2_c11")
			data.draw_center = node.pressed
			node = find_node("image_panel2_c12")
			data.color = node.color
		2:
			node = find_node("image_panel3_c1")
			data.image = node.image
			node = find_node("image_panel3_c2")
			data.patch_margin_left = node.value
			node = find_node("image_panel3_c3")
			data.patch_margin_right = node.value
			node = find_node("image_panel3_c4")
			data.patch_margin_top = node.value
			node = find_node("image_panel3_c5")
			data.patch_margin_bottom = node.value
			node = find_node("image_panel3_c6")
			data.axis_stretch_horizontal = node.get_selected_id()
			node = find_node("image_panel3_c7")
			data.axis_stretch_vertical = node.get_selected_id()
			node = find_node("image_panel3_c8")
			v.x = node.value
			node = find_node("image_panel3_c9")
			v.y = node.value
			data.frames = v
			node = find_node("image_panel3_c10")
			data.delay = float(node.value)
			node = find_node("image_panel3_c11")
			data.draw_center = node.pressed
			node = find_node("image_panel3_c12")
			data.color = node.color
		3:
			node = find_node("image_panel4_c1")
			data.image = node.image
			node = find_node("image_panel4_c2")
			v.x = node.value
			node = find_node("image_panel4_c3")
			v.y = node.value
			data.frames = v
			node = find_node("image_panel4_c4")
			data.delay = float(node.value)
			node = find_node("image_panel4_c8")
			data.auto_size = node.pressed
			data.size = Vector2(find_node("image_panel4_c5").value,
				find_node("image_panel4_c6").value)
			data.offset = Vector2(find_node("image_panel4_c9").value,
				find_node("image_panel4_c11").value)
			node = find_node("image_panel4_c7")
			data.color = node.color
		4:
			node = find_node("image_panel5_c1")
			data.image = node.image
			node = find_node("image_panel5_c2")
			v.x = node.value
			node = find_node("image_panel5_c3")
			v.y = node.value
			data.frames = v
			node = find_node("image_panel5_c4")
			data.delay = float(node.value)
			node = find_node("image_panel5_c5")
			data.position = node.get_selected_id()
			node = find_node("image_panel5_c8")
			data.auto_size = node.pressed
			data.size = Vector2(find_node("image_panel5_c6").value,
				find_node("image_panel5_c7").value)
			data.offset = Vector2(find_node("image_panel5_c9").value,
				find_node("image_panel5_c11").value)
			node = find_node("image_panel5_c13")
			data.color = node.color
		5:
			node = find_node("image_panel6_c1")
			data.image = node.image
			node = find_node("image_panel6_c2")
			data.patch_margin_left = node.value
			node = find_node("image_panel6_c3")
			data.patch_margin_right = node.value
			node = find_node("image_panel6_c4")
			data.patch_margin_top = node.value
			node = find_node("image_panel6_c5")
			data.patch_margin_bottom = node.value
			node = find_node("image_panel6_c6")
			data.axis_stretch_horizontal = node.get_selected_id()
			node = find_node("image_panel6_c7")
			data.axis_stretch_vertical = node.get_selected_id()
			node = find_node("image_panel6_c8")
			v.x = node.value
			node = find_node("image_panel6_c9")
			v.y = node.value
			data.frames = v
			node = find_node("image_panel6_c10")
			data.delay = float(node.value)
			node = find_node("image_panel6_c11")
			data.draw_center = node.pressed
			node = find_node("image_panel6_c12")
			data.color = node.color
		6:
			node = find_node("image_panel7_c1")
			data.image = node.image
			node = find_node("image_panel7_c2")
			data.patch_margin_left = node.value
			node = find_node("image_panel7_c3")
			data.patch_margin_right = node.value
			node = find_node("image_panel7_c4")
			data.patch_margin_top = node.value
			node = find_node("image_panel7_c5")
			data.patch_margin_bottom = node.value
			node = find_node("image_panel7_c6")
			data.axis_stretch_horizontal = node.get_selected_id()
			node = find_node("image_panel7_c7")
			data.axis_stretch_vertical = node.get_selected_id()
			node = find_node("image_panel7_c8")
			v.x = node.value
			node = find_node("image_panel7_c9")
			v.y = node.value
			data.frames = v
			node = find_node("image_panel7_c10")
			data.delay = float(node.value)
			node = find_node("image_panel7_c11")
			data.draw_center = node.pressed
			node = find_node("image_panel7_c12")
			data.color = node.color
		7:
			node = find_node("image_panel8_c1")
			data.image = node.image
			node = find_node("image_panel8_c2")
			v.x = node.value
			node = find_node("image_panel8_c3")
			v.y = node.value
			data.frames = v
			node = find_node("image_panel8_c4")
			data.delay = float(node.value)
			node = find_node("image_panel8_c8")
			data.auto_size = node.pressed
			data.size = Vector2(find_node("image_panel8_c5").value,
				find_node("image_panel8_c6").value)
			data.offset = Vector2(find_node("image_panel8_c9").value,
				find_node("image_panel8_c11").value)
			node = find_node("image_panel8_c7")
			data.color = node.color
			
	return data


func _on_image_changed(obj, id) -> void:
	obj.get_parent().get_parent().propagate_call("set_disabled", [false])
	obj.get_parent().get_parent().propagate_call("set_editable", [true])
	var data = get_image_data(id)
	obj.set_frames(data)
	
func color_button_pressed(button_pressed : bool, obj : ColorPickerButton = null):
	if button_pressed:
		emit_signal("show_dialog_color_request", obj)
		yield(get_tree(), "idle_frame")
		obj.get_popup().hide()




func _on_SelectInputActionButton_button_down() -> void:
	emit_signal("show_dialog_input_actions_request", input_actions)


func _on_left_box_name_fix_width_toggled(button_pressed: bool) -> void:
	find_node("left_box_name_c1").editable = !button_pressed


func _on_right_box_name_fix_width_toggled(button_pressed: bool) -> void:
	find_node("right_box_name_c1").editable = !button_pressed


func _on_option_box_name_fix_width_toggled(button_pressed: bool) -> void:
	find_node("options_box_c1").editable = !button_pressed


func _on_copy_parameters_button_down() -> void:
	emit_signal("set_as_default_config", get_data().config)


func _on_options_cursor_autosize_toggled(button_pressed: bool) -> void:
	find_node("image_panel4_c5").editable = !button_pressed
	find_node("image_panel4_c6").editable = !button_pressed

func _on_resume_button_autosize_toggled(button_pressed: bool) -> void:
	find_node("image_panel5_c6").editable = !button_pressed
	find_node("image_panel5_c7").editable = !button_pressed


func _on_ninepatch_button_down(id: int) -> void:
	var ids
	match id:
		0: ids = [1, [2, 3, 4, 5]]
		1: ids = [2, [2, 3, 4, 5]]
		2: ids = [3, [2, 3, 4, 5]]
		5: ids = [6, [2, 3, 4, 5]]
		6: ids = [7, [2, 3, 4, 5]]
	var img = find_node("image_panel%s_c1" % ids[0]).get_texture()
	var patchs = {
		"left"		: find_node("image_panel%s_c%s" % [ids[0], ids[1][0]]),
		"right"		: find_node("image_panel%s_c%s" % [ids[0], ids[1][1]]),
		"top"		: find_node("image_panel%s_c%s" % [ids[0], ids[1][2]]),
		"bottom"	: find_node("image_panel%s_c%s" % [ids[0], ids[1][3]])
	}
	emit_signal("show_dialog_ninepatch", img, patchs)

func update_patchs_limits(value, id1=-1, id2=-1):
	if !update_patchs_limits_enabled: return
	update_patchs_limits_enabled = false
	var img = find_node("image_panel%s_c%s" % [id1, 1])
	var size = img.get_texture().get_data().get_size()
	var node1 = find_node("image_panel%s_c%s" % [id1, id2])
	match id2:
		2:
			if node1.value > size.x: node1.value = size.x
			var node2 = find_node("image_panel%s_c%s" % [id1, 3])
			if node1.value > size.x - node2.value:
				node1.value = size.x - node2.value
		3:
			if node1.value > size.x: node1.value = size.x
			var node2 = find_node("image_panel%s_c%s" % [id1, 2])
			if node1.value > size.x - node2.value:
				node1.value = size.x - node2.value
		4:
			pass
#			if node1.value > size.y: node1.value = size.y
#			var node2 = find_node("image_panel%s_c%s" % [id1, 5])
#			if node1.value > size.y - node2.value:
#				node1.value = size.y - node2.value
		5:
			if node1.value > size.y: node1.value = size.y
			var node2 = find_node("image_panel%s_c%s" % [id1, 4])
			if node1.value > size.y - node2.value:
				node1.value = size.y - node2.value
	update_patchs_limits_enabled = true



func _on_page_indicator_autosize_toggled() -> void:
	pass # Replace with function body.


func _on_preview_config_Button_button_down():
	emit_signal("show_preview_config", get_data().config)
