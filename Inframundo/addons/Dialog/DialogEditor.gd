tool
extends Control


export(int) var grid_size = 20 setget change_grid_size
export(Color) var grid_color = Color(1, 1, 1, 0.8) setget change_grid_color



onready var background_texture			= $BackgroundLayer/ParallaxLayer/Texture
onready var background_layer			= $BackgroundLayer
onready var background_parallax			= $BackgroundLayer/ParallaxLayer
onready var graph_node_container		= $GraphNode_Container
onready var current_line_bottom_layer	= $CurrentLineBottomLayer
onready var current_line_top_layer		= $CurrentLineTopLayer
onready var auto_save_spinbox			= $Tools/LeftMenu/ScrollContainer/VboxContainer/TopPanel/VBoxContainer/HBoxContainer2/auto_save_SpinBox
onready var offset_x_spin_box			= $Tools/TopBackground/TopContainer/OffsetXSpinBox
onready var offset_y_spin_box			= $Tools/TopBackground/TopContainer/OffsetYSpinBox
onready var zoom_spin_box				= $Tools/TopBackground/TopContainer/ZoomSpinBox
onready var slider_bottom				= $Tools/SliderBottom
onready var slider_right				= $Tools/SliderRight
onready var graph_node_item_list		= $Tools/TopBackground/TopContainer/graph_nodes_ItemList
onready var animator 					= $Tween
onready var left_menu_container			= $Tools/LeftMenu
onready var grid_color_button			= $Tools/TopBackground/TopContainer/GridColorButton
onready var grid_size_button			= $Tools/TopBackground/TopContainer/GridSizeSpinBox
onready var right_click_menu_1			= $Menus_and_Dialogs/RightClickMenu1
onready var top_canvas_layer			= $Menus_and_Dialogs

onready var hide_all_layer				= $Menus_and_Dialogs/hide_all_dialogs
onready var hide_all_layer2				= $Menus_and_Dialogs/hide_all_dialogs2
onready var file_dialog					= $Menus_and_Dialogs/CustomFileDialog
onready var save_dialog_folder_lineedit	= $Tools/LeftMenu/ScrollContainer/VboxContainer/TopPanel/VBoxContainer/SelectSaveFolderLineEdit
onready var save_dialog_image_lineedit	= $Tools/LeftMenu/ScrollContainer/VboxContainer/TopPanel/VBoxContainer/SelectImageFolderLineEdit
onready var save_dialog_font_lineedit	= $Tools/LeftMenu/ScrollContainer/VboxContainer/TopPanel/VBoxContainer/SelectFontFolderLineEdit
onready var save_dialog_audio_lineedit	= $Tools/LeftMenu/ScrollContainer/VboxContainer/TopPanel/VBoxContainer/SelectSoundFolderLineEdit

onready var simple_edit_text_dialog		= $Menus_and_Dialogs/SimpleEditTextDialog

onready var language_itemlist			= $Tools/LeftMenu/ScrollContainer/VboxContainer/Languages/VBoxContainer/HBoxBottomContainer/ItemList
onready var language_add_button			= $Tools/LeftMenu/ScrollContainer/VboxContainer/Languages/VBoxContainer/HBoxBottomContainer/VBoxContainer/Button
onready var language_duplicate_button	= $Tools/LeftMenu/ScrollContainer/VboxContainer/Languages/VBoxContainer/HBoxBottomContainer/VBoxContainer/Button2
onready var language_remove_button		= $Tools/LeftMenu/ScrollContainer/VboxContainer/Languages/VBoxContainer/HBoxBottomContainer/VBoxContainer/Button3
onready var language_default_button		= $Tools/LeftMenu/ScrollContainer/VboxContainer/Languages/VBoxContainer/HBoxBottomContainer/VBoxContainer/CheckButton

onready var character_itemlist			= $Tools/LeftMenu/ScrollContainer/VboxContainer/Characters/VBoxContainer/HBoxBottomContainer/ItemList
onready var character_add_button		= $Tools/LeftMenu/ScrollContainer/VboxContainer/Characters/VBoxContainer/HBoxBottomContainer/VBoxContainer/Button
onready var character_remove_button		= $Tools/LeftMenu/ScrollContainer/VboxContainer/Characters/VBoxContainer/HBoxBottomContainer/VBoxContainer/Button3

onready var signal_itemlist				= $Tools/LeftMenu/ScrollContainer/VboxContainer/Signals/VBoxContainer/HBoxBottomContainer/ItemList
onready var signal_remove_button		= $Tools/LeftMenu/ScrollContainer/VboxContainer/Signals/VBoxContainer/HBoxBottomContainer/VBoxContainer/Button3

onready var advance_text_editor_dialog	= $Menus_and_Dialogs/TextEditDialog

onready var create_variable_dialog		= $Menus_and_Dialogs/create_variable_dialog
onready var variable_itemlist			= $Tools/LeftMenu/ScrollContainer/VboxContainer/Variables/VBoxContainer/HBoxBottomContainer/ItemList
onready var variable_delete_button		= $Tools/LeftMenu/ScrollContainer/VboxContainer/Variables/VBoxContainer/HBoxBottomContainer/VBoxContainer/Button3
onready var select_variable_dialog		= $Menus_and_Dialogs/select_variable_dialog
onready var select_lang_dialog			= $Menus_and_Dialogs/select_lang_dialog
onready var font_dialog					= $Menus_and_Dialogs/font_dialog
onready var select_color_dialog			= $Menus_and_Dialogs/color_dialog
onready var confirm_dialog				= $Menus_and_Dialogs/ConfirmDialog
onready var terms_dialog				= $Menus_and_Dialogs/TermsDialog
onready var input_actions_dialog		= $Menus_and_Dialogs/SelectActionInput
onready var patch_grid_dialog			= $Menus_and_Dialogs/PatchGridDialog
onready var preview_dialog_config		= $Menus_and_Dialogs/PreviewDialogConfig

onready var terms_itemlist				= $Tools/LeftMenu/ScrollContainer/VboxContainer/Terms/VBoxContainer/HBoxBottomContainer/ItemList
onready var terms_add_button			= $Tools/LeftMenu/ScrollContainer/VboxContainer/Terms/VBoxContainer/HBoxBottomContainer/VBoxContainer/Button

onready var preview_dialog				= $Menus_and_Dialogs/WindowPreviewDialog

var custom_graph_node_minimal = preload("res://addons/Dialog/CustomGraphNode_minimal.tscn")
var custom_graph_node_01 = preload("res://addons/Dialog/CustomGraphNode_01.tscn")
var custom_graph_node_02 = preload("res://addons/Dialog/CustomGraphNode_02.tscn")
var custom_graph_node_03 = preload("res://addons/Dialog/CustomGraphNode_03.tscn")
var custom_graph_node_04 = preload("res://addons/Dialog/CustomGraphNode_04.tscn")
var icon_alert = preload("res://addons/Dialog/Graphics/alert_icon2.png")
var floating_text = preload("res://addons/Dialog/FloatWord.tscn")

var zoom := 1.0
var offset := Vector2()
var slider_offset := 0
var moving = null
var target_point = null
var connections = []
var auto_save_cnt = 0

var current_graph_node_id = 0
var available_graph_node_ids = []
var current_graph_node_config_id = 0
var available_graph_node_config_ids = []
var menu_left_opened = false
var current_drag_point = null

var scroll = {
	"min_x"	: 0,
	"max_x"	: 0,
	"min_y"	: 0,
	"max_y"	: 0
}

var no_action = false

var custon_tool_tip = preload("res://addons/Dialog/CustomToolTip.tscn")

enum DIALOG_FILE_TYPE { FOLDER, LANGDATA, TEXT_EDITOR_FONT, CONFIG_FONT,
						IMAGE, FONT, AUDIO }

var DATA = {}

var last_lang = null
var last_character = null

var sub_dialog_open = []

var LEFT_PANEL_SIZES = {}

var default_config = null

var last_graph_node_created = null
var all_erased = false
var last_character_created = null
var last_lang_created = null

var dialog_preview_shown = false

var waiting_for_node_creating = false

signal all_graph_nodes_deleted()


func _ready() -> void:
	if !Engine.editor_hint:
		stylize_controls(self)
		fix_graph_node_position()
		set_node_connections()
		set_custom_tool_tip(self)
		show_or_hide_left_menu()
		create_initial_data()
		advance_text_editor_dialog.set_paths(DATA.editor_config.folders)
		advance_text_editor_dialog.connect("preview_dialog", self, "preview_dialog")
		font_dialog.paths = DATA.editor_config.folders

func check_if_default_files_exists():
	var dir = Directory.new()
	var files = [
		"verdana-normal.ttf", "verdana-bold.ttf",
		"verdana-bold-italic.ttf", "verdana-italic.ttf",
		
		"default_choice_cursor.png", "default_dialog_background.png",
		"default_page_indicator.png", "default_resume_button.png",
		"default_option_background.png", "default_option_animated_background.png",
		
		"default_cursor_fx.wav", "default_letter_by_letter_fx.wav",
		"default_ok_fx.wav", "default_resume_fx.wav"
	]
	var f = File.new()
	f.open("res://addons/Dialog/DialogBox/Fonts/dynamic_font_template.txt",
		File.READ)
	var template = f.get_as_text()
	f.close()
	for _folder in DATA.editor_config.folders.values():
		if !dir.dir_exists(_folder):
			dir.make_dir_recursive(_folder)
	var _folder; var _default_folder; var _filename;
	for _file in files:
		match _file.get_extension():
			"ttf":
				_folder = DATA.editor_config.folders.fonts
				_default_folder = "res://addons/Dialog/DialogBox/Fonts/"
			"png", "tres":
				_folder = DATA.editor_config.folders.graphics
				_default_folder = "res://addons/Dialog/DialogBox/Graphics/"
			"wav":
				_folder = DATA.editor_config.folders.sounds
				_default_folder = "res://addons/Dialog/DialogBox/Audio/"
		_filename = _folder + _file
		if !dir.file_exists(_filename):
			_filename = _default_folder + _file
			advance_text_editor_dialog.copy_file(_filename, _folder)
		if _file.get_extension() == "ttf":
			_filename = _folder + \
				_file.replace(".ttf", "(16).tres").replace(
					"verdana-", "default_font-")
			if !dir.file_exists(_filename):
				var _filename2 = _folder + _file
				var tmp = template.replace("_PATH_", _filename2)
				dir.make_dir_recursive(_folder)
				f.open(_filename, File.WRITE)
				f.store_string(tmp)
				f.close()

func stylize_controls(obj):
	if obj is SpinBox:
		var lineedit = obj.get_line_edit()
		lineedit.caret_blink = true
		lineedit.set("custom_fonts/font", theme.default_font)
#	if obj is PopupMenu or LineEdit or PopupMenu:
#		obj.set("custom_fonts/font", theme.default_font)
	if obj.get_child_count() > 0:
		for child in obj.get_children():
			stylize_controls(child)

func set_node_connections():
	right_click_menu_1.get_popup().connect("hide", self,
		"_on_select_right_menu_1")
	simple_edit_text_dialog.connect("OK", self, "create_")
	simple_edit_text_dialog.connect("Cancel", self, "hide_all")
	advance_text_editor_dialog.connect("close_request", self,
		"_on_advance_text_editor_close_request")

func get_lang(_name : String) -> Dictionary:
	var lang = {}
	lang.name = _name
#	lang.messages = []
	return lang

func get_character(_name : String) -> Dictionary:
	var character = {}
	character.name = _name
	return character

func create_initial_data():
	DATA.clear()
	DATA.langs = [] 		# [lang, lang, lang, lamg, ...]
	DATA.messages = []		# List of IDs
	DATA.characters = []	# [character, character, character, ...]
	DATA.dialogs = {}
	DATA.dialogs_text = {}
	DATA.default_lang = -1
	DATA.editor_config = {
		"grid_size"				: grid_size_button.value,
		"grid_color"			: grid_color_button.color,
		"zoom"					: zoom_spin_box.value,
		"offset"				: Vector2(
			offset_x_spin_box.value,
			offset_y_spin_box.value
		),
		"folders"				: {
			"dialogs"			: "res://Langs/",
			"graphics"			: "res://Graphics/",
			"fonts"				: "res://Fonts/",
			"sounds"			: "res://Audio/",
		},
		"last_character"		: null,
		"last_lang"				: null,
		"left_panel"			: {
			"expanded"			: true,
			"sub_panels_open"	: [true, true, true, true, true, true],
			"scroll"			: 0
		},
		"autosave"				: 0
	}
	DATA.message_config = {}
	DATA.message_config_connections = []
	DATA.message_config_position = []
	DATA.messages_need_translation = {}
	DATA.variables = []
	DATA.signals = []
	DATA.terms = []

func set_custom_tool_tip(obj, add_child_tool_tip = true):
	for child in obj.get_children():
		if (child.has_method("_get_tooltip") and
			child.hint_tooltip.length() > 0):
			var hint = child.hint_tooltip
			child.hint_tooltip = ""
			child.connect("mouse_entered", self, "show_tooltip", [hint, child])
			child.connect("mouse_exited", self, "hide_tooltip")
			if child.has_signal("gui_input"):
				child.connect("gui_input", self, "check_for_hide_tooltip")
		if child.get_child_count() > 0:
			set_custom_tool_tip(child, false)
	if add_child_tool_tip:
		var tooltip = custon_tool_tip.instance()
		tooltip.name = "_tooltip"
		top_canvas_layer.add_child(tooltip)

func show_tooltip(hint, node):
	if node.hint_tooltip != "":
		hint = node.hint_tooltip
		node.hint_tooltip = ""
	hint = str(hint).strip_edges()
	if hint.length() > 0:
		var tooltip = top_canvas_layer.get_node("_tooltip")
		tooltip.set_text(hint)
		tooltip.show()

func hide_tooltip():
	var tooltip = top_canvas_layer.get_node("_tooltip")
	tooltip.hide()

func check_for_hide_tooltip(event: InputEvent):
	if event is InputEventMouseButton:
		hide_tooltip()

func _on_select_right_menu_1():
	var popup = right_click_menu_1.get_popup()
	var index = popup.get_current_index()
	if index == 0:
		create_graph_node(custom_graph_node_02,
			get_global_mouse_position() / zoom - offset / zoom, "CONFIG ID # ")
		while last_graph_node_created == null:
			yield(get_tree(), "idle_frame")
		var c = last_graph_node_created
		last_graph_node_created = null
		var data = c.get_data()
		DATA.message_config[data.id] = data
		
		for i in DATA.characters.size():
			DATA.message_config_position[i][data.id] = c.rect_position
		update_graph_node_item_list(c)
	elif index == 1:
		create_graph_node(custom_graph_node_01,
			get_global_mouse_position() / zoom - offset / zoom)
		while last_graph_node_created == null:
			yield(get_tree(), "idle_frame")
		var c = last_graph_node_created
		last_graph_node_created = null
		var character_index = character_itemlist.get_selected_items()[0]
		DATA.dialogs_text[c.id] = []
		for i in DATA.langs.size():
			DATA.dialogs_text[c.id].append([""])
		c = c.get_data()
		DATA.dialogs[c.id] = c
		update_graph_node_item_list(c)
	elif index == 2:
		create_graph_node(custom_graph_node_03,
			get_global_mouse_position() / zoom - offset / zoom, "SET VARIABLE ID # ")
		while last_graph_node_created == null:
			yield(get_tree(), "idle_frame")
		var c = last_graph_node_created
		last_graph_node_created = null
		var character_index = character_itemlist.get_selected_items()[0]
		c = c.get_data()
		DATA.dialogs[c.id] = c
		update_graph_node_item_list(c)
	elif index == 3:
		create_graph_node(custom_graph_node_04,
			get_global_mouse_position() / zoom - offset / zoom, "CONDITIONALITY ID # ")
		while last_graph_node_created == null:
			yield(get_tree(), "idle_frame")
		var c = last_graph_node_created
		last_graph_node_created = null
		var character_index = character_itemlist.get_selected_items()[0]
		c = c.get_data()
		DATA.dialogs[c.id] = c
		update_graph_node_item_list(c)

func get_graph_node_id() -> int:
	var n
	if available_graph_node_ids.size() > 0:
		n = available_graph_node_ids.pop_front()
	else:
		n = current_graph_node_id
		current_graph_node_id += 1
	return n
	
func get_graph_node_config_id() -> int:
	var n
	if available_graph_node_config_ids.size() > 0:
		n = available_graph_node_config_ids.pop_front()
	else:
		n = current_graph_node_config_id
		current_graph_node_config_id += 1
	return n

func get_random_string():
	randomize()
	var letters = "abcdefghijklmnopqrtuvwxyz"
	var numbers = "0123456789"
	var s = "Box_"
#	for i in 8:
#		s = s + letters[randi()% letters.length()]
	for i in 16:
		s = s + numbers[randi()% numbers.length()]
	return s

func create_graph_node(graph_node, position, title=null,
	horizontal_align = true,
	vertical_align = true, id = null, _name = null):
		
	last_graph_node_created = null
	var c = graph_node.instance()
	
	if c is CustomGraphNode_02:
		c.set_paths(DATA.editor_config.folders)
		c.connect("show_preview_config", self, "show_preview_config")
	
	if c is CustomGraphNode_01:
		c.connect("preview_dialog", self, "preview_dialog")

	c.connect("tree_entered", self, "check_graph_node_visibility", [c])
	c.connect("on_screen_exited", self, "hide_a_graphnode")
	c.connect("focus_entered", self, "hide_all")
	c.connect("deselect", self, "update_langs")
	c.connect("deselect_all", self, "deselect_all")
	c.connect("end_move_and_resizing", self,
		"_on_CustomGraphNode_end_move_and_resizing")
	c.connect("moving", self, "move_graph_nodes_selected")
	c.connect("resizing", self, "resize_selected_graph_nodes")
	c.connect("start_move_point", self,
		"_on_CustomGraphNode_start_move_point")
	c.connect("end_move_point", self,
		"_on_CustomGraphNode_end_move_point")
	c.connect("delete_connection_request", self,
		"_on_CustomGraphNode_delete_connection_request")
	if c.has_signal("remove_slot"):
		c.connect("remove_slot", self, "fix_connections")
	c.connect("close_request", self, "remove_graph_edit")
	if c.has_signal("request_open_advance_text_editor"):
		c.connect("request_open_advance_text_editor", self,
			"show_advance_text_dialog")
	if c.has_signal("open_select_variable_request"):
		c.connect("open_select_variable_request", self,
			"show_select_variable_dialog")
	if c.has_signal("text_updated"):
		c.connect("text_updated", self,
			"save_text_in_langs")
	if c.has_signal("replace_text_with_other_request"):
		c.connect("replace_text_with_other_request", self,
			"replace_text_with_other_for_graphnode1")
	if c.has_signal("show_font_dialog_request"):
		c.connect("show_font_dialog_request", self,
			"show_font_dialog_request")
	if c.has_signal("show_audio_dialog_request"):
		c.connect("show_audio_dialog_request", self,
			"show_audio_dialog_request")
	if c.has_signal("play_audio_request"):
		c.connect("play_audio_request",
			advance_text_editor_dialog.play_sound_dialog,
			"play_sound")
	if c.has_signal("show_image_dialog_request"):
		c.connect("show_image_dialog_request", self,
			"show_image_dialog_request")
	if c.has_signal("show_dialog_color_request"):
		c.connect("show_dialog_color_request", self,
			"show_dialog_color_request")
	if c.has_signal("show_dialog_input_actions_request"):
		c.connect("show_dialog_input_actions_request", self,
			"show_dialog_input_actions_request")
	if c.has_signal("set_as_default_config"):
		c.connect("set_as_default_config", self,
			"set_as_default_config")
	if c.has_signal("show_dialog_ninepatch"):
		c.connect("show_dialog_ninepatch", self,
			"show_dialog_ninepatch")
	
	if _name != null:
		c.name = _name
		var node_in_tree = false
		for child in graph_node_container.get_children():
			if child.name == c.name:
				node_in_tree = child
				break
		if node_in_tree:
			remove_child_in_graph_node(node_in_tree)
			while !node_in_tree.is_queue_to_delete():
				yield(get_tree(),"idle_frame")
	else:
		c.name = get_random_string()
	while graph_node_container.has_node(c.name):
		c.name = get_random_string()
	graph_node_container.add_child(c)
	if id != null:
		c.id = id
	else:
		if c is CustomGraphNode_02:
			c.id = get_graph_node_config_id()
		else:
			c.id = get_graph_node_id()
	if horizontal_align:
		position.x -= c.rect_size.x * 0.5
	if vertical_align:
		position.y -= c.rect_size.y * 0.5
	c.rect_position = position
	if !title:
		title = "Message ID # "
	title += str(c.id)
	c.set_title_text(title)
	if c is CustomGraphNode_02 and default_config != null:
		c.set_config(default_config.duplicate(true))
	set_custom_tool_tip(c)
	if !c is CustomGraphNode_02:
		find_node("ToJSONButton").set_disabled(false)
	last_graph_node_created = c

func sort_items_in_graph_node_item_list():
	var keys = []

	for i in range(1, graph_node_item_list.get_item_count()):
		if graph_node_item_list.get_item_text(i) == "DEFAULT CONFIG ID # 0":
			continue
		keys.append([graph_node_item_list.get_item_icon(i),
			graph_node_item_list.get_item_text(i)])
	keys.sort_custom(self, "sort_graph_node_keys")
	keys.insert(0, [null, "DEFAULT CONFIG ID # 0"])
	keys.insert(0, [null, "Select Node"])
	graph_node_item_list.clear()
	for key in keys: graph_node_item_list.add_icon_item(key[0], key[1])

func sort_graph_node_keys(a, b):
	var regex = RegEx.new()
	regex.compile("(\\D+)(\\d+)")
	var result = regex.search(a[1])
	var s1 = result.get_string(1)
	var i1 = int(result.get_string(2))
	result = regex.search(b[1])
	var s2 = result.get_string(1)
	var i2 = int(result.get_string(2))
	if (s1 == s2 and i1 < i2) or s1 < s2:
		return true
	return false

func remove_graph_edit(obj, force_remove = false):
	if !force_remove:
		var t = "[color=red]%s[/color]" % obj.title
		t = "Do you want to delete the box\n\n%s  ?" % t
		confirm_dialog.label.bbcode_text = t
		show_dialog(confirm_dialog)
		yield(confirm_dialog, "hide")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		if !confirm_dialog.is_ok: return

	var remove_ids = []
	for i in connections.size():
		var c = connections[i]
		if c.from == obj.name or c.to == obj.name:
			remove_ids.append(c)
	
	if obj is CustomGraphNode_01:
		if obj.config != null:
			var character_index = character_itemlist.get_selected_items()[0]
			DATA.message_config_connections[character_index].erase(obj.config)
			DATA.message_config_position[character_index].erase(obj.config)
			obj.config = null
		DATA.dialogs_text.erase(obj.id)
		for i in DATA.langs.size():
			var key = "%s_%s" % [i, obj.id]
			DATA.messages_need_translation.erase(key)
	
	remove_ids.invert()
	for id in remove_ids:
		erase_connection(id)
	current_line_bottom_layer.update()
	
	remove_child_in_graph_node(obj)

	if obj is CustomGraphNode_02:
		available_graph_node_config_ids.append(obj.id)
		available_graph_node_config_ids.sort()
	else:
		available_graph_node_ids.append(obj.id)
		available_graph_node_ids.sort()
	
	for i in graph_node_item_list.get_item_count():
		if graph_node_item_list.get_item_text(i) == obj.title:
			graph_node_item_list.remove_item(i)
			break
	
	if obj is CustomGraphNode_02:
		DATA.message_config.erase(obj.id)
		for character in DATA.message_config_connections:
			character.erase(obj.id)
		for character in DATA.message_config_position:
			character.erase(obj.id)
		for messages in DATA.messages:
			for id in messages:
				var node = DATA.dialogs[id]
				if node.has("config") and node.config == obj.id:
					node.config = null
	else:
		for character_index in DATA.characters.size():
			DATA.dialogs.erase(obj.id)
			var messages = DATA.messages[character_index]
			messages.erase(obj.id)
	find_node("ToJSONButton").set_disabled(DATA.dialogs.size() == 0)


func fix_connections(obj_name, l_index, r_index):
	if l_index or r_index:
		for connection in connections:
			var c = connection
			if ((l_index and c.to == obj_name and c.to_port == l_index) or
				(r_index and c.from == obj_name and c.from_port == r_index)):
				erase_connection(c)
	for c in connections:
		if r_index and c.from == obj_name and c.from_port > r_index:
			c.from_port -= 1
		if l_index and c.to == obj_name and c.to_port > l_index:
			c.to_port -= 1
	current_line_bottom_layer.update()

func change_grid_size(value):
	grid_size = value
	if background_texture:
		change_grid_texture()
		set_offset(Vector2.ZERO)

func change_grid_color(value):
	grid_color = value
	if background_texture:
		change_grid_texture()
		set_offset(Vector2.ZERO)

func move_graph_nodes_selected(obj_name: String, position: Vector2):
	if right_click_menu_1.get_popup().visible:
		right_click_menu_1.get_popup().visible = false
	for child in graph_node_container.get_children():
		if child.name != obj_name and child.focused:
			child.rect_position += position
	current_line_bottom_layer.update()

func resize_selected_graph_nodes(obj_name, coord, size, position):
	if right_click_menu_1.get_popup().visible:
		right_click_menu_1.get_popup().visible = false
	for child in graph_node_container.get_children():
		if child.name != obj_name and child.focused and child.resizable:
			if coord == "x":
				child.rect_size.x += size
				child.rect_position.x += position
			else:
				child.rect_size.y += size
				child.rect_position.y += position
	current_line_bottom_layer.update()

func erase_connection(c):
	connections.erase(c)
	var start_graph_node = graph_node_container.get_node(c.from)
	var end_graph_node = graph_node_container.get_node(c.to)
	if start_graph_node is CustomGraphNode_01:
		if end_graph_node == CustomGraphNode_02: # config
			start_graph_node.set_config(null)
		elif end_graph_node is CustomGraphNode_01 or \
			end_graph_node is CustomGraphNode_04:
			if c.from_port == 1:
				start_graph_node.remove_next_text(end_graph_node.id)
			else:
				start_graph_node.remove_next_choice_text(c.from_port,
					end_graph_node.id)
		elif end_graph_node is CustomGraphNode_03:
			start_graph_node.remove_variable(end_graph_node.id)
	elif start_graph_node is CustomGraphNode_02 and \
		end_graph_node != null:
		end_graph_node.set_config(null)
	elif start_graph_node is CustomGraphNode_03:
		start_graph_node.remove_next_text(end_graph_node.id)
	elif start_graph_node is CustomGraphNode_04:
		start_graph_node.remove_next_text(end_graph_node.id)
	start_graph_node.remove_connection(c)

func check_connections(current_dot, _moving_data):
	if current_dot != null and current_dot.max_connections != 0:
		var obj_name
		var current_connections = get_connections_for_current_point(_moving_data)
		if current_connections.size() >= current_dot.max_connections:
			erase_connection(current_connections[-1])
			current_line_bottom_layer.update()
			var connection = current_connections[-1]
			if _moving_data.layer == 1:
				obj_name = connection.to
				var c = graph_node_container.get_node(obj_name)
				current_dot = c.get_point("left", connection.to_port)
				_on_CustomGraphNode_start_move_point(obj_name, current_dot,
					c.id, false)
			else:
				obj_name = connection.from
				var c = graph_node_container.get_node(obj_name)
				current_dot = c.get_point("right", connection.from_port)
				_on_CustomGraphNode_start_move_point(obj_name, current_dot,
					c.id, false)
			for i in 3:
				yield(get_tree(), "idle_frame")
			current_line_top_layer.update()

func _on_CustomGraphNode_start_move_point(obj_name, current_dot,
	graph_node_id, check_connections = true) -> void:
	if right_click_menu_1.get_popup().visible:
		right_click_menu_1.get_popup().visible = false
	if current_dot.get("layer") == null: return
	moving = {
		"name"			:	obj_name,
		"index"			:	current_dot.get_index(),
		"layer"			:	current_dot.layer,
		"type"			:	current_dot.type,
		"point"			:	(current_dot.rect_global_position +
			current_dot.rect_size * 0.5 * zoom),
		"color"			:	current_dot.color,
		"current_dot"	:	current_dot
	}
	if check_connections:
		check_connections(current_dot, moving)

func get_connections_for_current_point(_moving_data) -> Array:
	var dots = []
	for connection in connections:
		if _moving_data.layer == 0:
			if (connection.to == _moving_data.name and
				connection.to_port == _moving_data.index):
				dots.append(connection)
		else:
			if (connection.from == _moving_data.name and
				connection.from_port == _moving_data.index):
				dots.append(connection)
	return dots

func _on_CustomGraphNode_end_move_point(obj_name, current_dot,
	graph_node_id) -> void:
	if target_point != null:
		var tree = "left" if target_point.layer == 0 else "right"
		var cd = graph_node_container.get_node(target_point.name).get_point(
			tree, target_point.index
		)
		var m = moving
		check_connections(cd, target_point)
		moving = m
		# Define start and end conections
		var sc = target_point if target_point.layer == 1 else moving
		var ec = target_point if sc == moving else moving
		var connection = {
			"from"			: sc.name,
			"from_port"		: sc.index,
			"to"			: ec.name,
			"to_port"		: ec.index
		}
		var is_duplicated = false
		for item in connections:
			if (item.from 		== connection.from and
				item.from_port 	== connection.from_port and
				item.to 		== connection.to and
				item.to_port 	== connection.to_port):
				is_duplicated = true
				break
		if !is_duplicated:
			connections.append(connection)
			var start_graph_node = graph_node_container.get_node(sc.name)
			var end_graph_node = graph_node_container.get_node(ec.name)
			if start_graph_node is CustomGraphNode_02 and \
				end_graph_node is CustomGraphNode_01:
				end_graph_node.set_config(start_graph_node.id)
				start_graph_node.add_connection(connection)
			else:
				start_graph_node.add_connection(connection)
				if start_graph_node is CustomGraphNode_01:
					if end_graph_node is CustomGraphNode_01 or \
						end_graph_node is CustomGraphNode_04:
						if connection.from_port == 1:
							start_graph_node.add_next_text(
								{
									"id"			: end_graph_node.id,
									"probability"	: end_graph_node.get_probability()
								}
							)
						elif connection.from_port > 1:
							start_graph_node.add_next_choice_text(
								connection.from_port, end_graph_node.id,
								end_graph_node.get_probability()
							)
					elif end_graph_node is CustomGraphNode_03:
						start_graph_node.add_variable(end_graph_node.id)
				elif start_graph_node is CustomGraphNode_04:
					start_graph_node.add_next_text(
						{
							"id"			: end_graph_node.id,
							"probability"	: end_graph_node.get_probability()
						}
					)
		target_point = null
		current_line_bottom_layer.update()
		moving = null
		for i in 3:
			yield(get_tree(), "idle_frame")
		current_line_top_layer.update()
	elif moving != null:
		var node = graph_node_container.get_node(moving.name)
		var popup = right_click_menu_1.get_popup()
		var show_popup = false
		waiting_for_node_creating = true
		if node is CustomGraphNode_01:
			show_popup = true
			if moving.layer == 0: # Left Point
				if moving.index == 0: # Left Point Yellow
					popup.set_item_disabled(0, false)
					popup.set_item_disabled(1, true)
					popup.set_item_disabled(3, true)
				elif moving.index == 1: # Left Point Gray
					popup.set_item_disabled(0, true)
					popup.set_item_disabled(1, false)
					popup.set_item_disabled(3, DATA.variables.size() == 0)
				popup.set_item_disabled(2, true)
			elif moving.layer == 1: # Right Point
				if moving.index == 0: # Right Point Green
					popup.set_item_disabled(0, true)
					popup.set_item_disabled(1, true)
					popup.set_item_disabled(2, false)
					popup.set_item_disabled(3, true)
				elif moving.index >= 1: # Right Points Gray and Reds
					popup.set_item_disabled(0, true)
					popup.set_item_disabled(1, false)
					popup.set_item_disabled(2, true)
					popup.set_item_disabled(3, DATA.variables.size() == 0)
		elif node is CustomGraphNode_02: # Only has Yellow Point Right
			show_popup = true
			popup.set_item_disabled(0, true)
			popup.set_item_disabled(1, false)
			popup.set_item_disabled(2, true)
			popup.set_item_disabled(3, true)
		elif node is CustomGraphNode_03: # Only has Green Point Left
			show_popup = true
			popup.set_item_disabled(0, true)
			popup.set_item_disabled(1, false)
			popup.set_item_disabled(2, true)
			popup.set_item_disabled(3, true)
		elif node is CustomGraphNode_04: # Single Left and Right Pink Point
			show_popup = true
			popup.set_item_disabled(0, true)
			popup.set_item_disabled(1, false)
			popup.set_item_disabled(2, true)
			popup.set_item_disabled(3, DATA.variables.size() == 0)
		if show_popup:
			show_special_popup(popup)
			var last_child_count = graph_node_container.get_child_count()
			yield(popup, "hide")
			if last_child_count != graph_node_container.get_child_count():
				# Create connection
				var last_child = graph_node_container.get_child(last_child_count)
				target_point = {
					"name"		: last_child.name,
					"layer"		: 0 if moving.layer == 1 else 1,
					"type"		: moving.type
				}
				if moving.type == 0 or moving.type == 8: # Config / Yellow Point
					target_point.index = 0
				elif moving.type == 1: # texts / Conditionals / Gray, Red and Pink Points
					if last_child is CustomGraphNode_01:
						target_point.index = 1
					else:
						target_point.index = 0
				_on_CustomGraphNode_end_move_point(obj_name, current_dot, graph_node_id)
				return

	target_point = null
	current_line_bottom_layer.update()
	moving = null
	waiting_for_node_creating = false
	for i in 3:
		yield(get_tree(), "idle_frame")
	current_line_top_layer.update()

func show_special_popup(popup) -> void:
	popup.rect_global_position = get_global_mouse_position()
	popup.rect_global_position.x -= popup.rect_size.x / 2
	popup.rect_global_position.y -= 20
	var margin = 20
	var s = get_viewport().size
	if popup.rect_global_position.x < margin:
		popup.rect_global_position.x = margin
	elif (popup.rect_global_position.x +
		popup.rect_size.x + margin > s.x):
		popup.rect_global_position.x = s.x - \
			margin - popup.rect_size.x
	if popup.rect_global_position.y < margin:
		popup.rect_global_position.y = margin
	elif (popup.rect_global_position.y +
		popup.rect_size.y + margin > s.y):
		popup.rect_global_position.y = s.y - \
			margin - popup.rect_size.y
	popup.show()

func _on_CustomGraphNode_delete_connection_request(obj_name, current_dot,
	graph_node_id) -> void:
	var _max_connections = current_dot.max_connections
	current_dot.max_connections = 1
	_on_CustomGraphNode_start_move_point(obj_name, current_dot, graph_node_id)
	current_dot.max_connections = _max_connections

func change_grid_texture() -> void:
	var img = Image.new()
	var s = round(grid_size * zoom)
	img.create(s, s, false, Image.FORMAT_RGBA8)
	var color = grid_color
	img.lock()
	for n in s:
		img.set_pixel(n, 0, color)
		img.set_pixel(0, n, color)
	img.unlock()
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	background_texture.texture = tex
	background_texture.rect_size = Vector2(
		round(rect_size.x / s) * s,
		round(rect_size.y / s) * s
	)
	background_parallax.motion_mirroring = background_texture.rect_size

func _input(event: InputEvent) -> void:
	if hide_all_layer.visible: return
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
			# MOVE CANVAS
			set_offset(event.relative)
			current_line_bottom_layer.update()
			if moving:
				moving.point += event.relative
				for i in 3:
					yield(get_tree(), "idle_frame")
				current_line_top_layer.update()
		elif moving and not waiting_for_node_creating:
			# Update line_draw
			for i in 3:
				yield(get_tree(), "idle_frame")
			current_line_top_layer.update()
	elif event is InputEventKey and event.is_pressed() and \
		event.scancode == KEY_A and event.control and \
		is_any_graph_node_selected():
		select_color_dialog.dialog_id = "change_graph_nodes_color"
		show_dialog(select_color_dialog)
	elif event is InputEventKey and event.is_pressed() and \
		event.scancode == KEY_DELETE:
		remove_all_graph_nodes_selected()
	elif event is InputEventKey and event.is_pressed() and \
		event.scancode == KEY_S and event.control:
			save_data()

func is_any_graph_node_selected() -> bool:
	var anything_selected = false
	for node in graph_node_container.get_children():
		if node.focused:
			anything_selected = true
			break
	return anything_selected 

func remove_all_graph_nodes_selected():
	var ids = []
	var nodes = []
	for node in graph_node_container.get_children():
		if node.focused and node.can_be_closed():
			var type = node.get_data().type
			var s = "[code][color=red]%s[/color][/code]" % \
				"%s - [color=#cce7a5]%s[/color]" % [type, node.id]
			if ids.size() % 2 == 0:	
				s = s + "\t"
			if ids.size() % 2 == 1:
				s = s + "\n"
			ids.append(s)
			nodes.append(node)
	if ids.size() == 0: return
	var t = PoolStringArray(ids).join("")
	var s = "s" if ids.size() > 1 else ""
	t = "Do you want to delete the selected node%s?\n\n%s\n" % [s, t]
	confirm_dialog.label.set_bbcode(t)
	show_dialog(confirm_dialog)
	yield(confirm_dialog, "hide")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if !confirm_dialog.is_ok: return
	for node in nodes:
		remove_graph_edit(node, true)

func _on_DialogEditor_gui_input(event: InputEvent) -> void:
	if (!current_drag_point and event is InputEventMouseButton and
		event.is_pressed()):
		#if moving: return
		if (event.button_index == BUTTON_LEFT or
			event.button_index == BUTTON_RIGHT):
			if !Input.is_key_pressed(KEY_SHIFT):
				deselect_all()
			var popup = right_click_menu_1.get_popup()
			var options_disabled = DATA.characters.size() == 0 or \
				DATA.langs.size() == 0
			popup.set_item_disabled(0, options_disabled)
			popup.set_item_disabled(1, options_disabled)
			options_disabled = DATA.variables.size() == 0 or \
				DATA.characters.size() == 0 or \
				DATA.langs.size() == 0
			popup.set_item_disabled(2, options_disabled)
			popup.set_item_disabled(3, options_disabled)
			if popup.visible:
				no_action = true
				popup.hide()
				no_action = false
			elif event.button_index == BUTTON_RIGHT:
				popup.rect_global_position = event.position
				popup.rect_global_position.x -= popup.rect_size.x / 2
				popup.rect_global_position.y -= 20
				var margin = 20
				var s = get_viewport().size
				if popup.rect_global_position.x < margin:
					popup.rect_global_position.x = margin
				elif (popup.rect_global_position.x +
					popup.rect_size.x + margin > s.x):
					popup.rect_global_position.x = s.x - \
						margin - popup.rect_size.x
				if popup.rect_global_position.y < margin:
					popup.rect_global_position.y = margin
				elif (popup.rect_global_position.y +
					popup.rect_size.y + margin > s.y):
					popup.rect_global_position.y = s.y - \
						margin - popup.rect_size.y
				popup.show()
			elif event.button_index == BUTTON_LEFT:
				current_drag_point = get_global_mouse_position()
	elif (current_drag_point and event is InputEventMouseButton and
		event.button_index == BUTTON_LEFT and !event.is_pressed()):
		try_select_anything()
		current_drag_point = null
		for i in 3:
			yield(get_tree(), "idle_frame")
		current_line_top_layer.update()
	elif current_drag_point and event is InputEventMouseMotion:
		for i in 3:
			yield(get_tree(), "idle_frame")
		current_line_top_layer.update()
	if event is InputEventMouseButton and event.is_pressed():
		if Input.is_key_pressed(KEY_CONTROL):
			# ZOOM
			var zoom_factor = 0.08 if zoom >= 0.4 else 0.02
			var _zoom = 0
			if event.button_index == BUTTON_WHEEL_DOWN:
				_zoom = zoom - zoom_factor
			elif event.button_index == BUTTON_WHEEL_UP:
				_zoom = zoom + zoom_factor
			if _zoom != 0:
				zoom = max(0.05, min(10, _zoom))
				no_action = true
				zoom_spin_box.value = zoom
				no_action = false
				fix_position_by_zoom()

func try_select_anything():
	var dest = get_global_mouse_position()
	var rect = Rect2(current_drag_point, dest - current_drag_point)
	if rect.size.x < 0:
		rect.position.x += rect.size.x
		rect.size.x *= -1
	if rect.size.y < 0:
		rect.position.y += rect.size.y
		rect.size.y *= -1
	for child in graph_node_container.get_children():
		if child.is_on_screen():
			var rect2 = child.get_global_rect()
			rect2.size *= zoom
			if rect.intersects(rect2, true):
				child.select(true)

func fix_position_by_zoom():
	change_grid_texture()
	set_offset(Vector2.ZERO)
	var node; var r1; var r2;
	if graph_node_container.get_child_count() != 0:
		node = graph_node_container.get_child(0)
	if node: r1 = node.get_local_mouse_position()
	graph_node_container.rect_scale = Vector2(zoom, zoom)
	if node:
		fix_graph_node_position()
		r2 = node.get_local_mouse_position()
		var mod = (r2-r1) * zoom
		set_offset(mod)
	current_line_bottom_layer.update()
	if moving:
		if moving.current_dot == null: return
		moving.point = (moving.current_dot.rect_global_position +
			moving.current_dot.rect_size * 0.5 * zoom)
		for i in 3:
			yield(get_tree(), "idle_frame")
		current_line_top_layer.update()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	current_line_bottom_layer.update()

func set_offset(_offset, is_fixed_value = false):
	if is_fixed_value:
		var diff = _offset - offset
		offset = _offset
		background_layer.scroll_offset = offset
		graph_node_container.rect_position += diff
	else:
		offset += _offset
		background_layer.scroll_offset = offset
		graph_node_container.rect_position += _offset
	no_action = true
	offset_x_spin_box.value = offset.x
	offset_y_spin_box.value = offset.y
	no_action = false
	for node in graph_node_container.get_children():
		var r = graph_node_is_on_screen(node)
		if r == 1:
			redo_graphnode(node)
		elif r == 0:
			hide_a_graphnode(node)

func graph_node_is_on_screen(node):
	var ss = get_viewport().size
	var s = node.rect_size * graph_node_container.rect_scale
	var p = node.rect_global_position
	if node is GraphNodeMinimal and \
		p.x <= ss.x and p.x + s.x > 0 and \
		p.y <= ss.y and p.y + s.y > 0:
		return 1
	elif !node is GraphNodeMinimal  and \
		p.x + s.x < 0 or p.x > ss.x or \
		p.y + s.y < 0 or p.y > ss.y:
		return 0
	else:
		return -1

func bring_graph_node_into_view(graph_node):
	var offset = rect_size * 0.5 - graph_node.rect_size * 0.5 * zoom
	offset -= graph_node.rect_global_position
	set_offset(offset, false)
	fix_graph_node_position()

func _on_CustomGraphNode_end_move_and_resizing(obj) -> void:
	var s = grid_size
	obj.rect_position = (obj.rect_position / s).round() * s
	var s2 = rect_size * 0.5
	for child in graph_node_container.get_children():
		if child.name != obj.name and child.focused:
			child.rect_position = (child.rect_position / s).round() * s
			
		var rp = child.rect_global_position
		var rs = child.rect_size * zoom
		scroll.min_x = min(scroll.min_x, rp.x - s2.x)
		scroll.max_x = max(scroll.max_x, rp.x + rs.x - s2.x)
		scroll.min_y = min(scroll.min_x, rp.y - s2.y)
		scroll.max_y = max(scroll.max_x, rp.y + rs.y - s2.y)
	current_line_bottom_layer.update()
	$Tools/SliderRight.min_value = scroll.min_x
	$Tools/SliderRight.max_value = scroll.min_x

func fix_graph_node_position():
	for child in graph_node_container.get_children():
		child.emit_signal("end_move_and_resizing", child)

func deselect_all():
	for child in graph_node_container.get_children():
		if child.focused:
			child.deselect()
	var current_focus_control = get_focus_owner()
	if current_focus_control:
		current_focus_control.release_focus()


func update_langs(obj):
	pass

func _on_DialogEditor_item_rect_changed() -> void:
	if background_texture:
		change_grid_texture()
		set_offset(Vector2.ZERO)
	if advance_text_editor_dialog:
		advance_text_editor_dialog.fix_hide_layer_size()
	for i in 10:
		yield(get_tree(), "idle_frame")
	current_line_bottom_layer.update()

func update_back_lines_draw():
	current_line_bottom_layer.update()

func _on_CurrentLineBottomLayer_draw() -> void:
	for d in connections:
		if !graph_node_container.get_node_or_null(d.from) or \
			!graph_node_container.get_node_or_null(d.to):
			continue
		var obj1 = graph_node_container.get_node(d.from)
		if obj1 == null:
			continue
		var p1 = obj1.get_point("right", d.from_port)
		var obj2 = graph_node_container.get_node(d.to)
		if obj2 == null:
			continue
		var p2 = obj2.get_point("left", d.to_port)
		if p1 == null or p2 == null: continue
		if obj1.is_on_screen() or obj2.is_on_screen():
			var c1 = p1.color
			var c2 = p2.color
			p1 = p1.rect_global_position + p1.rect_size * 0.5 * zoom
			p2 = p2.rect_global_position + p2.rect_size * 0.5 * zoom
			var v = PoolVector2Array([p1, p1 + (p2 - p1), p2])
			var c = PoolColorArray([c1, c2, c2])
			current_line_bottom_layer.draw_polyline_colors(v, c, 2)

func _on_CurrentLineTopLayer_draw() -> void:
	if current_drag_point:
		var dest = get_global_mouse_position()
		var rect = Rect2(current_drag_point, dest - current_drag_point)
		var c = Color(0.6,0.6,0.6)
		var from; var to;
		from = rect.position
		to = Vector2(from.x + rect.size.x, from.y)
		current_line_top_layer.draw_line(from, to, c, 4, true)
		from = to
		to = Vector2(from.x, from.y + rect.size.y)
		current_line_top_layer.draw_line(from, to, c, 4, true)
		from = to
		to = Vector2(rect.position.x, from.y)
		current_line_top_layer.draw_line(from, to, c, 4, true)
		from = to
		to = rect.position
		current_line_top_layer.draw_line(from, to, c, 4, true)
		current_line_top_layer.draw_rect(rect, Color(0.9,0.9,0.9,0.4), true)
	elif moving:
		var v; var c;
		set_target_point()
		if target_point:
			var from = moving if moving.layer == 1 else target_point
			var to = target_point if from == moving else moving
			var m = from.point + (to.point - from.point)
			v = PoolVector2Array([from.point, m, to.point])
			c = PoolColorArray([from.color, to.color, to.color])
		else:
			var to = get_global_mouse_position()
			v = PoolVector2Array([moving.point, to])
			c = PoolColorArray([moving.color, moving.color])
		current_line_top_layer.draw_polyline_colors(v, c, 2)

func set_target_point():
	if !moving:
		target_point = null
		return
	var mouse = get_global_mouse_position()
	target_point = null
	var points = {
		"name"	: "",
		"data"	: null
	}
	for child in graph_node_container.get_children():
		if child.name == moving.name: continue
		if child.is_on_screen():
			points.data = null
			var rect = child.get_global_rect()
			rect.size *= zoom
			var n = 16 / zoom
			var n2 = n * 2
			rect.position -= Vector2(n, n)
			rect.size += Vector2(n2, n2)
			if rect.has_point(mouse):
				points.name = child.name
				if moving.layer == 0:
					points.data = child.get_right_points()
				else:
					points.data = child.get_left_points()
			if points.data:
				for p in points.data:
					if p.type == moving.type:
						var pos = p.rect_global_position + \
							p.rect_size * 0.5 * zoom
						if mouse.distance_to(pos) < 20 * zoom:
							target_point = {
								"name"		:	points.name,
								"index"		:	p.get_index(),
								"layer"		:	p.layer,
								"type"		:	p.type,
								"point"		:	pos,
								"color"		:	p.color
							}
							break
		if target_point != null:
			break

func _on_SliderRight_value_changed(_value) -> void:
	_value = -_value / zoom
	set_offset(Vector2(0, _value))
	current_line_bottom_layer.update()

func _on_SliderBottom_value_changed(_value) -> void:
	_value = -_value / zoom
	set_offset(Vector2(_value, 0))
	current_line_bottom_layer.update()

func _on_GridSizeSpinBox_value_changed(value: float) -> void:
	grid_size = value
	if background_texture:
		change_grid_texture()
		fix_position_by_zoom()

func _on_GridColorButton_color_changed(color: Color) -> void:
	grid_color = color
	if background_texture:
		change_grid_texture()
		fix_position_by_zoom()

func _on_ZoomSpinBox_value_changed(value: float) -> void:
	if !no_action:
		zoom = max(0.1, min(value, 10))
		fix_position_by_zoom()

func _on_CenterCanvas_button_down() -> void:
	set_offset(Vector2.ZERO, true)
	current_line_bottom_layer.update()

func _on_OffsetXSpinBox_value_changed(value: float) -> void:
	if !no_action:
		set_offset(Vector2(offset_x_spin_box.value,
			offset_y_spin_box.value), true)
		current_line_bottom_layer.update()

func _on_OffsetYSpinBox_value_changed(value: float) -> void:
	if !no_action:
		set_offset(Vector2(offset_x_spin_box.value,
			offset_y_spin_box.value), true)
		current_line_bottom_layer.update()

func _on_graph_nodes_ItemList_item_selected(index: int) -> void:
	if index != 0:
		var name = graph_node_item_list.get_item_text(index)
		for child in graph_node_container.get_children():
			if child.title == name:
				bring_graph_node_into_view(child)
				var child_name = child.name
				for i in 6:
					yield(get_tree(),"idle_frame")
				if child != null:
					child.select()
				else:
					child = graph_node_container.get_node_or_null(child_name)
					if child != null:
						child.select()
				break
	graph_node_item_list.select(0)

func _on_Handle_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and
		event.button_index == BUTTON_LEFT and event.is_pressed()):
		show_or_hide_left_menu()

func show_or_hide_left_menu():
	hide_all()
	var i = left_menu_container.rect_position
	var f
	var _ease
	if !menu_left_opened:
		f = Vector2(-82, 50)
		_ease = Tween.EASE_OUT
	else:
		f = Vector2(-407, 50)
		_ease = Tween.EASE_OUT
	animator.interpolate_property(left_menu_container, "rect_position",
		i, f, 0.4, Tween.TRANS_BOUNCE, _ease)
	animator.reset(left_menu_container, "rect_position")
	animator.start()
	menu_left_opened = !menu_left_opened

func _on_GridColorButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		yield(get_tree(), "idle_frame")
		var p = grid_color_button.get_picker().get_parent()
		var x = -p.rect_size.x * 0.5
		p.rect_global_position = get_global_mouse_position() + Vector2(x, 10)

func hide_all(obj = null):
	get_tree().set_input_as_handled()
	if sub_dialog_open.size() > 1:
		var dialog = sub_dialog_open.pop_back()
		dialog.visible = false
	elif sub_dialog_open.size() == 1:
		var popup = right_click_menu_1.get_popup()
		popup.hide()
		var dialog = sub_dialog_open.pop_back()
		dialog.visible = false
		hide_all_layer.visible = false
		top_canvas_layer.get_node("_tooltip").hide()
	else:
		var popup = right_click_menu_1.get_popup()
		popup.hide()
		hide_all_layer.visible = false
		top_canvas_layer.get_node("_tooltip").hide()

func _on_hide_all_dialogs_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and
		event.button_index == BUTTON_LEFT):
		hide_all()

func show_dialog(dialog, pre_hide = true):
	if pre_hide: hide_all()
	hide_all_layer.visible = true
	dialog.show()
	sub_dialog_open.append(dialog)

func show_advance_text_dialog(obj):
	advance_text_editor_dialog.set_current_parent(obj)
	advance_text_editor_dialog.variables = DATA.variables
	advance_text_editor_dialog.characters = DATA.characters
	advance_text_editor_dialog.signals = DATA.signals
	advance_text_editor_dialog.terms = DATA.terms
	advance_text_editor_dialog.config_ids = DATA.message_config.keys()
	var id = obj.config if obj.config != null else 0
	var config
	for child in graph_node_container.get_children():
		if child is CustomGraphNode_02 and child.id == id:
			config = child.get_data().config
			break
		elif child is GraphNodeMinimal and child.data.type == "config" and \
			child.data.id == id:
			config = child.get_data().config
			break
	preview_dialog.find_node("MessageBox").set_config(config)
	show_dialog(advance_text_editor_dialog)

func show_select_folder_dialog():
	file_dialog.set_valid_files(["all"])
	file_dialog.set_title("Folder to save lang files")
	file_dialog.set_allow_external_files_visibility(false)
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = true
	var text = save_dialog_folder_lineedit.text
	file_dialog.set_initial_folder(text)
	show_dialog(file_dialog)
	file_dialog.id = DIALOG_FILE_TYPE.FOLDER

func show_select_image_dialog():
	file_dialog.set_valid_files(["all"])
	file_dialog.set_title("Folder to save image files")
	file_dialog.set_allow_external_files_visibility(false)
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = true
	var text = save_dialog_image_lineedit.text
	file_dialog.set_initial_folder(text)
	show_dialog(file_dialog)
	file_dialog.id = DIALOG_FILE_TYPE.IMAGE

func show_select_font_dialog():
	file_dialog.set_valid_files(["all"])
	file_dialog.set_title("Folder to save font files")
	file_dialog.set_allow_external_files_visibility(false)
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = true
	var text = save_dialog_font_lineedit.text
	file_dialog.set_initial_folder(text)
	show_dialog(file_dialog)
	file_dialog.id = DIALOG_FILE_TYPE.FONT

func show_select_audio_dialog():
	file_dialog.set_valid_files(["all"])
	file_dialog.set_title("Folder to save sound files")
	file_dialog.set_allow_external_files_visibility(false)
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = true
	var text = save_dialog_audio_lineedit.text
	file_dialog.set_initial_folder(text)
	show_dialog(file_dialog)
	file_dialog.id = DIALOG_FILE_TYPE.AUDIO

func show_select_valid_lang_dialog():
	file_dialog.set_valid_files(["lang.data"])
	file_dialog.set_title("Select a valid file 'lang.data'")
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = false
	file_dialog.set_allow_external_files_visibility(false)
	show_dialog(file_dialog)
	file_dialog.id = DIALOG_FILE_TYPE.LANGDATA

func show_font_dialog(id = null, pre_hide = true,
	title = "Select a valid Font '*.ttf'", valids = ["ttf"]):
	file_dialog.set_valid_files(valids)
	file_dialog.set_title(title)
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = false
	file_dialog.set_allow_external_files_visibility(true)
	show_dialog(file_dialog, pre_hide)
	file_dialog.id = id
	if typeof(id) == typeof(DIALOG_FILE_TYPE):
		if id == DIALOG_FILE_TYPE.TEXT_EDITOR_FONT:
			advance_text_editor_dialog.visible = true

func show_audio_dialog(id = null, pre_hide = true):
	var title = "Select a valid Audio"
	var valids = ["ogg", "wav"]
	file_dialog.set_valid_files(valids)
	file_dialog.set_title(title)
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = false
	file_dialog.set_allow_external_files_visibility(true)
	show_dialog(file_dialog, pre_hide)
	file_dialog.id = id

func show_image_dialog(id = null, pre_hide = true):
	var title = "Select a valid Image"
	var valids = ["png"]
	file_dialog.set_valid_files(valids)
	file_dialog.set_title(title)
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = false
	file_dialog.set_allow_external_files_visibility(true)
	show_dialog(file_dialog, pre_hide)
	file_dialog.id = id

func _on_SelectProjectButton_button_down() -> void:
	if DATA.langs.size() != 0:
		var t = "\nDo you want to save the current "
		t += "project before loading another?"
		confirm_dialog.label.bbcode_text = t
		show_dialog(confirm_dialog)
		yield(confirm_dialog, "hide")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		if confirm_dialog.is_ok:
			save_data()
	if Input.is_key_pressed(KEY_ESCAPE):
		return
	show_select_valid_lang_dialog()

func _on_SelectSaveFolderLineEdit_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and
		event.button_index == BUTTON_LEFT):
		show_select_folder_dialog()

func _on_SelectImageFolderLineEdit_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and
		event.button_index == BUTTON_LEFT):
		show_select_image_dialog()

func _on_SelectFontFolderLineEdit_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and
		event.button_index == BUTTON_LEFT):
		show_select_font_dialog()

func _on_SelectAudioFolderLineEdit_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and
		event.button_index == BUTTON_LEFT):
		show_select_audio_dialog()

func _on_CustomFileDialog_select_files(files_string_array) -> void:
	if files_string_array.size() == 0: return
	var file = files_string_array[0]
	if typeof(file_dialog.id) == TYPE_INT:
		var previous_folder
		if file_dialog.id == DIALOG_FILE_TYPE.FOLDER:
			previous_folder = save_dialog_folder_lineedit.text
			save_dialog_folder_lineedit.text = file
			DATA.editor_config.folders.dialogs = file
		elif file_dialog.id == DIALOG_FILE_TYPE.IMAGE:
			previous_folder = save_dialog_image_lineedit.text
			save_dialog_image_lineedit.text = file
			DATA.editor_config.folders.graphics = file
		elif file_dialog.id == DIALOG_FILE_TYPE.FONT:
			previous_folder = save_dialog_font_lineedit.text
			save_dialog_font_lineedit.text = file
			DATA.editor_config.folders.fonts = file
		elif file_dialog.id == DIALOG_FILE_TYPE.AUDIO:
			previous_folder = save_dialog_audio_lineedit.text
			save_dialog_audio_lineedit.text = file
			DATA.editor_config.folders.sounds = file
		elif file_dialog.id == DIALOG_FILE_TYPE.LANGDATA:
			var path = file.get_base_dir()
			if path[path.length() - 1] != "/": path += "/"
			save_dialog_folder_lineedit.text = path
			load_data(file)
		elif file_dialog.id == DIALOG_FILE_TYPE.TEXT_EDITOR_FONT:
			pass # TODO???
		while sub_dialog_open.size() > 0:
			hide_all()
		if previous_folder != null and previous_folder != file:
			confirm_move_files(previous_folder, file)
	else:
		if file_dialog.id == "fonts_01":
			var dest = DATA.editor_config.folders.fonts
			file = advance_text_editor_dialog.copy_file(file, dest)
			font_dialog.set_font(ProjectSettings.localize_path(file).get_file())
		elif file_dialog.id == "fonts_02":
			var dest = DATA.editor_config.folders.fonts
			file = advance_text_editor_dialog.copy_file(file, dest)
			font_dialog.set_dynamic_font(ProjectSettings.localize_path(file).get_file())
		elif file_dialog.id == "audio_01":
			var dest = DATA.editor_config.folders.sounds
			file = advance_text_editor_dialog.copy_file(file, dest)
			file_dialog.target_node.text = ProjectSettings.localize_path(file).get_file()
			hide_all()
		elif file_dialog.id == "image_01":
			var dest = DATA.editor_config.folders.graphics
			file = advance_text_editor_dialog.copy_file(file, dest)
			file_dialog.target_node.load_image(ProjectSettings.localize_path(file))
			hide_all()

func confirm_move_files(previous_folder, next_folder):
	var f = "\t[color=red]%s[/color]" % previous_folder
	var t = "\t[color=#b4ea96]%s[/color]" % next_folder
	var bbcode = "Copy files in\n\n%s\n\nto\n\n%s ?\n" % [f, t]
	confirm_dialog.label.bbcode_text = bbcode
	show_dialog(confirm_dialog)
	confirm_dialog.rect_position = Vector2(305, 147)
	yield(confirm_dialog, "hide")
	yield(get_tree(), "idle_frame")
	if confirm_dialog.is_ok:
		# Move files from old folder to new folder
		var files = list_files_in_directory(previous_folder)
		var dir := Directory.new()
		for file in files:
			var filename = next_folder + file.replace(previous_folder, "")
			var base_dir = filename.get_base_dir()
			if !dir.dir_exists(base_dir):
				dir.make_dir_recursive(base_dir)
			dir.copy(file, filename)
		confirm_remove_old_files(previous_folder)

func confirm_remove_old_files(previous_folder):
	var f = "\t[color=red]%s[/color]" % previous_folder
	var bbcode = "Delete files in old folder\n\n%s ?\n" % f
	confirm_dialog.label.bbcode_text = bbcode
	show_dialog(confirm_dialog)
	confirm_dialog.rect_position = Vector2(305, 147)
	yield(confirm_dialog, "hide")
	yield(get_tree(), "idle_frame")
	if confirm_dialog.is_ok:
		# make 2 pass to delete for sure
		for i in 2:
			var files = list_files_in_directory(previous_folder, true)
			files.invert()
			var dir = Directory.new()
			for file in files:
				dir.remove(file)

func list_files_in_directory(path, get_directories = false):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			if dir.current_is_dir():
				if get_directories:
					files.append(path + file + "/")
				files += list_files_in_directory(path + file + "/", get_directories)
			else:
				files.append(path + file)
	dir.list_dir_end()
	return files

func _on_CustomFileDialog_hide() -> void:
	if sub_dialog_open.size() == 1:
		hide_all()

func display_info_text(text):
	var node = floating_text.instance()
	node.set_text(text)
	node.start_position = get_viewport().size - Vector2(30, 30)
	add_child(node)
	

func load_data(file):
	# clear all
	clear()
	while !all_erased:
		yield(get_tree(), "idle_frame")
	all_erased = true
	# Set Data
	var path = save_dialog_folder_lineedit.text
	var f = File.new()
	f.open("%slang.data" % path, File.READ)
	DATA = f.get_var()
	f.close()
	DATA.dialogs_text = {}
	for i in DATA.langs.size():
		f.open("%s%s.lang" % [path, DATA.langs[i].name], File.READ)
		var texts = f.get_var()
		f.close()
		for id in texts.keys():
			if !DATA.dialogs_text.has(id):
				DATA.dialogs_text[id] = []
			DATA.dialogs_text[id].append(texts[id])
	# Set used IDs
	current_graph_node_id = DATA.used_ids.current_graph_node_id
	available_graph_node_ids = DATA.used_ids.available_graph_node_ids
	current_graph_node_config_id = DATA.used_ids.current_graph_node_config_id
	available_graph_node_config_ids = DATA.used_ids.available_graph_node_config_ids
	DATA.erase("used_ids")
	# set editor config
	grid_size_button.set_value(DATA.editor_config.grid_size)
	grid_color_button.set_pick_color(DATA.editor_config.grid_color)
	grid_color_button.emit_signal("color_changed", grid_color_button.color)
	zoom_spin_box.set_value(DATA.editor_config.zoom)
	offset_x_spin_box.set_value(DATA.editor_config.offset.x)
	offset_y_spin_box.set_value(DATA.editor_config.offset.y)
	save_dialog_folder_lineedit.text = DATA.editor_config.folders.dialogs
	save_dialog_image_lineedit.text = DATA.editor_config.folders.graphics
	save_dialog_font_lineedit.text = DATA.editor_config.folders.fonts
	save_dialog_audio_lineedit.text = DATA.editor_config.folders.sounds
	auto_save_spinbox.value = DATA.editor_config.autosave
	if DATA.editor_config.left_panel.expanded != menu_left_opened:
		show_or_hide_left_menu()
	select_color_dialog.clear_color_presets()
	select_color_dialog.set_presets(DATA.editor_config.color_presets)
	advance_text_editor_dialog.clear_color_presets()
	advance_text_editor_dialog.set_presets(DATA.editor_config.color_presets)
	default_config = DATA.editor_config.default_config
	preview_dialog.find_node("MessageBox").folders = DATA.editor_config.folders
	# Fill all
	fill_lang_itemlist(DATA.editor_config.last_lang)
	fill_character_itemlist(DATA.editor_config.last_character)
	fill_variable_item_list()
	fill_terms_list()
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	fill_signals_list()

	display_info_text("Data Loaded.")

func save_data():
	check_if_default_files_exists()
	save_last_character()
	if DATA.langs.size() == 0: return
	var data = get_data()
	var path = save_dialog_folder_lineedit.text
	var langs = []
	for i in data.langs.size():
		var f = File.new()
		f.open("%s%s.lang" % [path, data.langs[i].name], File.WRITE)
		var texts = {}
		for key in DATA.dialogs_text.keys():
			texts[key] = DATA.dialogs_text[key][i]
		f.store_var(texts)
		f.close()
	data.erase("dialogs_text")
	var f = File.new()
	f.open("%slang.data" % path, File.WRITE)
	f.store_var(data)
	f.close()
	
	display_info_text("Data Saved.")

func get_data():
	var data = DATA.duplicate(true)
	data.used_ids = {
		"current_graph_node_id"				: current_graph_node_id,
		"available_graph_node_ids"			: available_graph_node_ids,
		"current_graph_node_config_id"		: current_graph_node_config_id,
		"available_graph_node_config_ids"	: available_graph_node_config_ids,
	}
	grid_size_button.apply()
	zoom_spin_box.apply()
	offset_x_spin_box.apply()
	offset_y_spin_box.apply()
	auto_save_spinbox.apply()
	data.editor_config.grid_size = grid_size_button.value
	data.editor_config.grid_color = grid_color_button.color
	data.editor_config.zoom = zoom_spin_box.value
	data.editor_config.offset.x = offset_x_spin_box.value
	data.editor_config.offset.y = offset_y_spin_box.value
	data.editor_config.folders.dialogs = save_dialog_folder_lineedit.text 
	data.editor_config.folders.graphics = save_dialog_image_lineedit.text 
	data.editor_config.folders.fonts = save_dialog_font_lineedit.text 
	data.editor_config.folders.sounds = save_dialog_audio_lineedit.text
	data.editor_config.last_character = last_character
	data.editor_config.last_lang = last_lang
	data.editor_config.left_panel.expanded = menu_left_opened
	data.editor_config.sub_panels_open = [
		true, true, true, true, true, true
	]
	data.editor_config.scroll = find_node("ScrollContainer").scroll_vertical
	data.editor_config.color_presets = select_color_dialog.get_presets()
	data.editor_config.default_config = default_config
	data.editor_config.autosave = auto_save_spinbox.value
	for key in data.message_config:
		var node = graph_node_container.get_node(data.message_config[key].name)
		data.message_config[key] = node.get_data()
	return data

func get_fix_name_for_variable(text : String) -> String:
	text = get_fix_name_for(text, DATA.variables)
	return text

func get_fix_name_for(text : String, _DATA : Array) -> String:
	text = text.replace(" ", "_")
	text = text.lstrip("_")
	text = text.rstrip("_")
	var illegal = ["<",">",":","\"","/","\\","|","?","*"]
	for _char in illegal: text = text.replace(_char, "")
	text = get_path_name(text, _DATA)
	return text

func get_path_name(text : String, _DATA : Array) -> String:
	var n = 2
	var duplicated = true
	var new_text = text
	var regex = RegEx.new()
	regex.compile("(.*_)(\\d+)$")
	while duplicated:
		duplicated = false
		for _data in _DATA:
			if _data.name == new_text:
				var result = regex.search(new_text)
				if result:
					n = int(result.get_strings()[2]) + 1
					new_text = "%s%s" % [result.get_strings()[1], n]
				else:
					new_text = "%s_%s" % [text, n]
					n += 1
				duplicated = true
				break
				
	return new_text

func create_(text, id):
	match id:
		"language_filename":
			create_lang(text)
			while last_lang_created == null:
				yield(get_tree(), "idle_frame")
			var i = language_itemlist.get_item_count() - 1
			language_itemlist.select(i)
			language_itemlist.ensure_current_is_visible()
			language_itemlist.emit_signal("item_selected", i)
		"language_filename_duplicate":
			var i = language_itemlist.get_selected_items()[0]
			create_lang(text, i)
		"character_name":
			create_character(text)
			while last_character_created == null:
				yield(get_tree(), "idle_frame")
			last_character_created = false
			var i = character_itemlist.get_item_count() - 1
			character_itemlist.select(i)
			character_itemlist.ensure_current_is_visible()
			character_itemlist.emit_signal("item_selected", i)
		"character_name_edit":
			var i = character_itemlist.get_selected_items()[0]
			DATA.characters[i].name = text
			character_itemlist.set_item_text(i, "ID %s: %s" % [i, text])
			hide_all()
		"signal_name":
			create_signal(text)
			hide_all()
		"signal_name_edit":
			var i = signal_itemlist.get_selected_items()[0]
			DATA.signals[i] = text
			signal_itemlist.set_item_text(i, text)
			hide_all()

func create_signal(_name):
	_name = _name.replace(" ", "_")
	while _name.find("__") != -1:
		_name = _name.replace("__", "_")
	DATA.signals.append(_name)
	signal_itemlist.add_item(_name)
	signal_itemlist.select(DATA.signals.size() - 1)
	signal_itemlist.ensure_current_is_visible()
	signal_remove_button.set_disabled(false)

func _on_create_language_button_down() -> void:
	simple_edit_text_dialog.set_dialog_id("language_filename")
	var lang_name = "lang %s" % (DATA.langs.size() + 1)
	simple_edit_text_dialog.set_text("Language Filename:", lang_name)
	show_dialog(simple_edit_text_dialog)

func _on_duplicate_lang_button_down() -> void:
	simple_edit_text_dialog.set_dialog_id("language_filename_duplicate")
	var lang_name = "lang %s" % (DATA.langs.size() + 1)
	simple_edit_text_dialog.set_text("Language Filename:", lang_name)
	show_dialog(simple_edit_text_dialog)
	pass

func _on_remove_lang_button_down() -> void:
	if !language_itemlist.is_anything_selected(): return
	var index = language_itemlist.get_selected_items()[0]
	var t = "[color=#bafd87]%s[/color]" % DATA.langs[index].name
	t = "Do you want to delete the lang\n\n%s  ?" % t
	t += "\n\n[color=#dd6262]CAUTION! you will delete to the lang file in your HDD"
	if DATA.langs.size() == 1:
		t += "\n\n[color=#dd6262]if you delete this last language you also delete"
		t += " all the added characters[/color]"
	confirm_dialog.label.bbcode_text = t
	show_dialog(confirm_dialog)
	yield(confirm_dialog, "hide")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if !confirm_dialog.is_ok: return
	# delete data
	var lang_name = DATA.langs[index].name
	DATA.langs.remove(index)
	language_itemlist.remove_item(index)
	# delete texts in this language
	for text in DATA.dialogs_text.values():
		text.remove(index)
	# delete terms in this language
	for term in DATA.terms:
		term.values.remove(index)
	# Set default lang if this language is the 1st
	if DATA.default_lang == index: DATA.default_lang = 0
	# Select the next language available or clear all
	if DATA.langs.size() > 0:
		index = min(index, DATA.langs.size() - 1)
		last_lang = null
		language_itemlist.select(index)
		language_itemlist.ensure_current_is_visible()
		language_itemlist.emit_signal("item_selected", index)
	else:
		clear()
	# Delete the lang file in HDD
	var dir = Directory.new()
	var path = DATA.editor_config.folders.dialogs + lang_name + ".lang"
	if dir.file_exists(path):
		dir.remove(path)

func _on_set_default_lang_button_down(button_pressed: bool) -> void:
	if !language_itemlist.is_anything_selected(): return
	var lang_index = language_itemlist.get_selected_items()[0]
	if button_pressed:
		DATA.default_lang = lang_index
	else:
		if DATA.default_lang == lang_index:
			language_default_button.pressed = true

func create_lang(lang_name : String, id = null) -> void:
	if lang_name.length() == 0: return
	last_lang_created = null
	if character_itemlist.is_anything_selected():
		save_last_character()
	lang_name = get_fix_name_for(lang_name, DATA.langs)
	var lang
	if id != null:
		lang = DATA.langs[id].duplicate(true)
		lang.name = lang_name
	else:
		lang = get_lang(lang_name)
		if DATA.characters.size() > 0:
			for i in DATA.characters.size():
				lang.messages.append({})
	for dialog in DATA.dialogs_text.values():
		dialog.append(dialog[last_lang].duplicate(true))
	DATA.langs.append(lang)
	if DATA.langs.size() == 1:
		DATA.default_lang = 0
	fill_lang_itemlist()
	hide_all()
	character_add_button.set_disabled(false)
	if DATA.characters.size() > 0:
		character_remove_button.set_disabled(false)
	terms_add_button.set_disabled(false)

	for term in DATA.terms:
		term.values.append(term.values[DATA.default_lang])

	if character_itemlist.is_anything_selected():
		character_itemlist.emit_signal("item_selected",
			character_itemlist.get_selected_items()[0])
			
	last_lang_created = true

func fill_lang_itemlist(selected_index = -1):
	language_itemlist.clear()
	if DATA.langs.size() == 0: return
	for lang in DATA.langs:
		language_itemlist.add_item(lang.name)
	if selected_index == -1:
		selected_index = language_itemlist.get_item_count() - 1
	else:
		selected_index = min(selected_index,
			language_itemlist.get_item_count() - 1)
	language_itemlist.select(selected_index)
	language_itemlist.emit_signal("item_selected", selected_index)
	language_itemlist.ensure_current_is_visible()
	language_add_button.set_disabled(true)
	language_remove_button.set_disabled(false)
	language_duplicate_button.set_disabled(false)
	language_default_button.set_disabled(false)

func _on_language_ItemList_item_selected(index: int) -> void:
	hide_all()
	#if last_lang != index: save_last_lang()
	var _disabled = index == -1
	language_add_button.set_disabled(DATA.langs.size() != 0)
	language_duplicate_button.set_disabled(_disabled)
	language_remove_button.set_disabled(_disabled)
	language_default_button.set_disabled(_disabled)
	language_default_button.pressed = DATA.default_lang == index
	save_last_lang()
	last_lang = index
	translated_messages()
	update_graph_node_item_list()

func update_graph_node_item_list(obj=null):
	if obj != null:
		var key = "%s_%s" % [last_lang, obj.id]
		if DATA.messages_need_translation.has(key):
			graph_node_item_list.add_icon_item(icon_alert, obj.title)
		else:
			graph_node_item_list.add_icon_item(null, obj.title)
		sort_items_in_graph_node_item_list()
		return
		
	if DATA.langs.size() == 0: return
	if !language_itemlist.is_anything_selected() or \
		!character_itemlist.is_anything_selected():
		return
	var lang_index = language_itemlist.get_selected_items()[0]
	var character_index = character_itemlist.get_selected_items()[0]
	graph_node_item_list.clear()
	graph_node_item_list.add_icon_item(null, "")
	var title
	for id in DATA.messages[character_index]:
		if DATA.dialogs[id].type == "message":
			var key = "%s_%s" % [lang_index, id]
			title = "Message ID # %s" % id
			if DATA.messages_need_translation.has(key):
				graph_node_item_list.add_icon_item(icon_alert, title)
			else:
				graph_node_item_list.add_icon_item(null, title)
		else:
			if DATA.dialogs[id].type == "variable":
				title = "SET VARIABLE ID # %s" % id
			elif DATA.dialogs[id].type == "condition":
				title = "CONDITIONALITY ID # %s" % id
			else:
				title = ""
			graph_node_item_list.add_icon_item(null, title)
	for data in DATA.message_config.values():
		if data.id != 0:
			title = "CONFIG ID # "
			title += str(data.id)
			graph_node_item_list.add_icon_item(null, title)
	sort_items_in_graph_node_item_list()

func _on_character_ItemList_item_select(index: int) -> void:
	# Ensure all yields are completed
	for i in 3:
		yield(get_tree(), "idle_frame")
	hide_all()
	if index == -1: return
	if last_character != null:
		save_last_character()
	character_remove_button.set_disabled(DATA.langs.size() == 0)
	last_character = index
	fill_graph_nodes()

func fill_character_itemlist(selected_index = 0):
	character_itemlist.clear()
	if DATA.characters.size() == 0: return
	for i in DATA.characters.size():
		var character = DATA.characters[i]
		character_itemlist.add_item("ID %s: %s" % [i, character.name])
	if (selected_index != -1 and
		selected_index < DATA.characters.size()):
		character_itemlist.select(selected_index)
		character_itemlist.emit_signal("item_selected", selected_index)
		character_itemlist.ensure_current_is_visible()
	character_add_button.set_disabled(DATA.langs.size() == 0)
	character_remove_button.set_disabled(false)

func fill_graph_nodes():
	clear_graph_nodes()
	while graph_node_container.get_child_count() > 0:
		yield(get_tree(), "idle_frame")
	if DATA.langs.size() == 0: return
	if !language_itemlist.is_anything_selected() or \
		!character_itemlist.is_anything_selected():
		return
	var lang_index = language_itemlist.get_selected_items()[0]
	var character_index = character_itemlist.get_selected_items()[0]
	var node
	for data in DATA.message_config.values():
		var title = "CONFIG ID # " if data.id != 0 else "DEFAULT CONFIG ID # "
		create_graph_node(custom_graph_node_02,
			Vector2.ZERO, title, true, true,
			data.id, data.name)
		while last_graph_node_created == null:
			yield(get_tree(), "idle_frame")
		node = last_graph_node_created
		last_graph_node_created = null
		while !node or !node.has_method("set_data"):
			node = graph_node_container.get_node_or_null(data.name)
			yield(get_tree(),"idle_frame")
		if node:
			var c = DATA.message_config_connections
			if c[character_index].has(data.id):
				data.connections = c[character_index][data.id]
			data.position = DATA.message_config_position[last_character][data.id]
			node.set_data(data)
			connections += data.connections
	var cnt = 0
	for id in DATA.messages[character_index]:
		var data = DATA.dialogs[id]
		match data.type:
			"message":
				create_graph_node(custom_graph_node_01,
					Vector2.ZERO, null, true, true, data.id, data.name)
			"variable":
				create_graph_node(custom_graph_node_03,
					Vector2.ZERO, "SET VARIABLE ID # ", true, true,
					data.id, data.name)
			"condition":
				create_graph_node(custom_graph_node_04,
					Vector2.ZERO, "CONDITIONALITY ID # ", true, true,
					data.id, data.name)
		while last_graph_node_created == null:
			yield(get_tree(), "idle_frame")
		node = last_graph_node_created
		last_graph_node_created = null
		if node:
			data = data.duplicate(true)
			while !node or !node.has_method("set_data"):
				node = graph_node_container.get_node_or_null(data.name)
				yield(get_tree(),"idle_frame")
			node.set_data(data)
			connections += data.connections
		cnt += 1
		if cnt % 12 == 0:
			yield(get_tree(), "idle_frame")
	update_graph_node_item_list()

	current_line_bottom_layer.update()
	yield(get_tree(), "idle_frame")
	for _node in graph_node_container.get_children():
		_node.rect_position.x += 1
	yield(get_tree(), "idle_frame")
	for _node in graph_node_container.get_children():
		_node.rect_position.x -= 1
	yield(get_tree(), "idle_frame")
	current_line_bottom_layer.update()
	yield(get_tree(), "idle_frame")
	current_line_bottom_layer.update()
	
	for i in 6:
		yield(get_tree(),"idle_frame")
	update_graph_node_item_list()
	set_offset(offset, true)


func _on_create_character_button_down() -> void:
	if !language_itemlist.is_anything_selected(): return
	var lang_index = language_itemlist.get_selected_items()[0]
	var text = "Character %s" % (DATA.characters.size() + 1)
	simple_edit_text_dialog.set_dialog_id("character_name")
	simple_edit_text_dialog.set_text("Character Name:", text)
	show_dialog(simple_edit_text_dialog)

func _on_advance_text_editor_close_request() -> void:
	if !advance_text_editor_dialog: return
	if advance_text_editor_dialog.current_parent == null: return
	advance_text_editor_dialog.current_parent.set_text(
		advance_text_editor_dialog.current_parent.text,
		true
	)
	advance_text_editor_dialog.current_parent = null
	dialog_preview_shown = false
	preview_dialog.find_node("MessageBox").stop()
	preview_dialog.hide()
	hide_all()

func _on_advance_text_editor_hide() -> void:
	_on_advance_text_editor_close_request()

func save_last_lang():
	if last_character != null:
		save_last_character()
	last_lang = null

func clear():
	all_erased = false
	clear_graph_nodes()
	while graph_node_container.get_child_count() > 0:
		yield(get_tree(), "idle_frame")
	character_add_button.set_disabled(true)
	character_remove_button.set_disabled(true)
	language_add_button.set_disabled(false)
	language_duplicate_button.set_disabled(true)
	language_remove_button.set_disabled(true)
	language_default_button.set_disabled(true)
	language_itemlist.clear()
	character_itemlist.clear()
	variable_itemlist.clear()
	variable_delete_button.set_disabled(true)
	signal_itemlist.clear()
	signal_remove_button.set_disabled(true)
	terms_itemlist.clear()
	terms_add_button.set_disabled(true)
	last_character = null
	last_lang = null
	create_initial_data()
	current_graph_node_id = 0
	available_graph_node_ids.clear()
	current_graph_node_config_id = 0
	available_graph_node_config_ids.clear()
	all_erased = true

func clear_characters():
	clear_graph_nodes()
	character_itemlist.clear()
	character_add_button.set_disabled(false)
	character_remove_button.set_disabled(true)
	last_character = null
	DATA.message_config.clear()
	DATA.message_config_connections.clear()
	DATA.message_config_position.clear()
	DATA.messages_need_translation.clear()

func clear_graph_nodes():
	find_node("ToJSONButton").set_disabled(true)
	connections.clear()
	graph_node_item_list.clear()
	graph_node_item_list.add_icon_item(null, "Select Node")
	for node in graph_node_container.get_children():
		remove_child_in_graph_node(node)
	while graph_node_container.get_child_count() > 0:
		yield(get_tree(),"idle_frame")
	for i in 3:
		yield(get_tree(), "idle_frame")
	current_line_bottom_layer.update()
	current_line_top_layer.update()
	emit_signal("all_graph_nodes_deleted")

func save_last_character():
	if last_lang == null: return
	if last_character == null: return
	if DATA.langs.size() == 0: return
	var dialogs = {}
	var messages = {}
	DATA.messages[last_character].clear()
	for node in graph_node_container.get_children():
		if node is GraphNodeMinimal:
			if node.data.type != "config":
				var data = node.get_data()
				DATA.dialogs[data.id] = data
				if !DATA.messages[last_character].has(data.id):
					DATA.messages[last_character].append(data.id)
			else:
				DATA.message_config_position[last_character][node.id] = node.rect_position
		elif !(node is CustomGraphNode_02):
			var data = node.get_data()
			DATA.dialogs[data.id] = data
			if !DATA.messages[last_character].has(data.id):
				DATA.messages[last_character].append(data.id)
		else:
			DATA.message_config_position[last_character][node.id] = node.rect_position
	for i in DATA.langs.size():
		DATA.messages[last_character] = \
			DATA.messages[last_character]


func _on_create_variable_button_down() -> void:
	show_dialog(create_variable_dialog)
	var _data = create_variable_dialog.get_data()
	create_variable_dialog.set_data(_data.type)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	create_variable_dialog.select()

func _on_create_variable_dialog_OK(text, dialog_id) -> void:
	hide_all()
	if dialog_id == null:
		text.name = get_fix_name_for_variable(text.name)
		DATA.variables.append(text)
	else:
		DATA.variables[dialog_id].name = ""
		text.name = get_fix_name_for_variable(text.name)
		DATA.variables[dialog_id] = text
	var i
	if dialog_id != null:
		i = dialog_id
	else:
		i = DATA.variables.size() - 1
	fill_variable_item_list(i)

func sort_variables(a, b):
	if a.name < b.name:
		return true
	return false

func fill_variable_item_list(selectedindex = null):
	variable_itemlist.clear()
	if selectedindex != null:
		var i = selectedindex
		selectedindex = "%s: %s" % [
			DATA.variables[selectedindex].name,
			DATA.variables[selectedindex].value
		]
	DATA.variables.sort_custom(self, "sort_variables")
	for variable in DATA.variables:
		variable_itemlist.add_item("%s: %s" % [variable.name, variable.value])
	if variable_itemlist.get_item_count() != 0:
		if selectedindex == null:
			variable_itemlist.select(0)
		else:
			for i in variable_itemlist.get_item_count():
				if variable_itemlist.get_item_text(i) == selectedindex:
					variable_itemlist.select(i)
					break
		variable_itemlist.ensure_current_is_visible()
	if variable_delete_button:
		if variable_itemlist.get_item_count() != 0:
			variable_delete_button.set_disabled(false)
		else:
			variable_delete_button.set_disabled(true)

func _on_variable_ItemList_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 \
		and event.doubleclick:
			var i = variable_itemlist.get_item_at_position(
				event.position, true)
			if i == -1:
				_on_create_variable_button_down()
				return
			show_dialog(create_variable_dialog)
			if variable_itemlist.get_item_count() != 0:
				var index = variable_itemlist.get_selected_items()[0]
				var d = DATA.variables[index]
				create_variable_dialog.set_data(0, d, index)

func create_character(character_name):
	save_last_character()
	if character_name.length() == 0: return
	last_character_created = null
	var character = get_character(character_name)
	DATA.characters.append(character)
	DATA.messages.append([])
	DATA.message_config_connections.append({})
	if DATA.message_config_position.size() == 0:
		DATA.message_config_position.append({})
	else:
		DATA.message_config_position.append(DATA.message_config_position[last_character].duplicate(true))
	if DATA.message_config.size() == 0:
		# create default config node
		create_graph_node(custom_graph_node_02,
			Vector2(500, 400) - offset, "DEFAULT CONFIG ID # ")
		while last_graph_node_created == null:
			yield(get_tree(), "idle_frame")
		var c = last_graph_node_created
		last_graph_node_created = null
		c.set_close_btn_visibility(false)
		var data = c.get_data()
		DATA.message_config[data.id] = data
		for i in DATA.characters.size():
			DATA.message_config_position[i][data.id] = data.position
		remove_child_in_graph_node(c)
	fill_character_itemlist(-1)
	hide_all()
	last_character_created = true

func show_select_variable_dialog(object, filter = null):
	select_variable_dialog.set_variables(DATA.variables, filter)
	select_variable_dialog.set_parent(object)
	show_dialog(select_variable_dialog)

func _on_select_variable_dialog_OK(text, dialog_id) -> void:
	var p = select_variable_dialog.get_parent()
	p.add_variable(text)
	hide_all()

func _on_TextEditDialog_dialog_image_request() -> void:
	pass # Replace with function body.

func translated_messages():
	if language_itemlist.get_item_count() == 0 or \
		character_itemlist.get_item_count() == 0: return
	var lang_index = language_itemlist.get_selected_items()[0]
	var character_index = character_itemlist.get_selected_items()[0]
	for node in graph_node_container.get_children():
		if node is CustomGraphNode_01:
			node.set_text(DATA.dialogs_text[node.id][lang_index][0])
			for i in range(1, DATA.dialogs_text[node.id][lang_index].size()):
				node.set_choice(i-1, DATA.dialogs_text[node.id][lang_index][i])

func save_text_in_langs(id, index, text, action):
	var lang_index = language_itemlist.get_selected_items()[0]
	var character_index =character_itemlist.get_selected_items()[0]
	if action == "replace":
		var lang = DATA.dialogs_text[id][lang_index][index]
		lang[0] = text[0]
		for i in text[1].size():
			lang[i] = text[1][i]
		var key = "%s_%s" % [last_lang, id]
		if DATA.messages_need_translation.has(key):
			DATA.messages_need_translation.erase(key)
			key = "Message ID # %s" % id
			for i in graph_node_item_list.get_item_count():
				if graph_node_item_list.get_item_text(i) == key:
					graph_node_item_list.set_item_icon(i, null)
					break
	else:
		if lang_index == DATA.default_lang or \
			action != "update": # UPDATE TEXT IN ALL LANGUAGES
			for i in DATA.langs.size():
				match action:
					"update":
						if index == 0:
							DATA.dialogs_text[id][i][index] = text
						else:
							DATA.dialogs_text[id][i][index] = text.text
					"create":
						DATA.dialogs_text[id][i].append(text.text)
					"delete":
						DATA.dialogs_text[id][i].remove(index)
				var key = "%s_%s" % [i, id]
				if i != DATA.default_lang:
					if !DATA.messages_need_translation.has(key):
						DATA.messages_need_translation[key] = [index]
					elif !DATA.messages_need_translation[key].has(index):
						DATA.messages_need_translation[key].append(index)
						
		else: # UPDATE TEXT IN CURRENT LANGUAGE
			if index == 0:
				DATA.dialogs_text[id][lang_index][index] = text
			else:
				DATA.dialogs_text[id][lang_index][index] = text.text
			var key = "%s_%s" % [last_lang, id]
			if DATA.messages_need_translation.has(key):
				DATA.messages_need_translation[key].erase(index)
				if DATA.messages_need_translation[key].size() == 0:
					DATA.messages_need_translation.erase(key)
					key = "Message ID # %s" % id
					for i in graph_node_item_list.get_item_count():
						if graph_node_item_list.get_item_text(i) == key:
							graph_node_item_list.set_item_icon(i, null)
							break

func show_lang_dialog(obj):
	select_lang_dialog.set_languages(DATA.langs)
	select_lang_dialog.set_parent(obj)
	show_dialog(select_lang_dialog)

func replace_text_with_other_for_graphnode1(obj):
	show_lang_dialog(obj)

func _on_characters_ItemList_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == BUTTON_LEFT and event.doubleclick:
		if DATA.langs.size() == 0: return
		var index = character_itemlist.get_item_at_position(event.position, true)
		if index == -1:
			_on_create_character_button_down() 
			return
		var text = DATA.characters[index].name
		simple_edit_text_dialog.set_dialog_id("character_name_edit")
		simple_edit_text_dialog.set_text("Character Name:", text)
		show_dialog(simple_edit_text_dialog)

func _on_select_lang_dialog_OK(index, dialog_id) -> void:
	var character_index = character_itemlist.get_selected_items()[0]
	var obj = select_lang_dialog.get_parent()
	var data = DATA.dialogs_text[obj.id][index]
	var text = data[0]
	var choices = data.slice(1, data.size())
	obj.replace_text(text, choices)
	hide_all()

func _on_signals_ItemList_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == BUTTON_LEFT and event.doubleclick:
		var index = signal_itemlist.get_item_at_position(event.position, true)
		if index == -1:
			_on_create_signal_button_down()
			return
		var text = signal_itemlist.get_item_text(index)
		simple_edit_text_dialog.set_dialog_id("signal_name_edit")
		simple_edit_text_dialog.set_text("Signal Name:", text)
		show_dialog(simple_edit_text_dialog)

func _on_create_signal_button_down() -> void:
	simple_edit_text_dialog.set_dialog_id("signal_name")
	var text = "Signal %s" % (DATA.signals.size() + 1)
	simple_edit_text_dialog.set_text("Signal Name:", text)
	show_dialog(simple_edit_text_dialog)

func _unhandled_input(event: InputEvent) -> void:
	if advance_text_editor_dialog.visible: return
	if event is InputEventKey and event.scancode == KEY_ESCAPE and \
		event.is_pressed():
		hide_all()
		get_tree().set_input_as_handled()

func _on_languages_ItemList_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == BUTTON_LEFT and event.doubleclick:
		if DATA.langs.size() == 0:
			_on_create_language_button_down()
		else:
			var index = language_itemlist.get_item_at_position(event.position)
			if index != -1:
				_on_duplicate_lang_button_down()

func _on_font_dialog_select_font_dialog_request(id) -> void:
	if id == "fonts_01":
		show_font_dialog(id, false)
	else:
		var title = "Select a Dynamic Font '*.tres'"
		var valids = ["tres"]
		show_font_dialog(id, false, title, valids)

func show_font_dialog_request(obj, id):
	font_dialog.dialog_id = obj
	font_dialog.set_font_type(id)
	font_dialog.set_dynamic_font(obj.text)
	show_dialog(font_dialog)

func show_audio_dialog_request(obj):
	file_dialog.target_node = obj
	show_audio_dialog("audio_01", false)

func show_image_dialog_request(obj):
	file_dialog.target_node = obj
	show_image_dialog("image_01", false)

func _on_font_dialog_OK(text, dialog_id) -> void:
	if text != null:
		font_dialog.dialog_id.text = font_dialog.path.get_file()
	while sub_dialog_open.size() > 0:
		hide_all()

func _on_font_dialog_Cancel() -> void:
	while sub_dialog_open.size() > 0:
		hide_all()

func show_dialog_color_request(obj):
	hide_all_layer2.visible = true
	select_color_dialog.dialog_id = "set_target_color"
	select_color_dialog.target_node = obj
	select_color_dialog.set_color(obj.color)
	show_dialog(select_color_dialog)

func _on_color_dialog_OK(text, dialog_id) -> void:
	if dialog_id == "set_target_color":
		select_color_dialog.target_node.color = select_color_dialog.color
		select_color_dialog.target_node.emit_signal(
			"color_changed", select_color_dialog.color)
	elif dialog_id == "set_target_color_text":
		select_color_dialog.target_node.edit_text(
			text.begin_text, text.end_text)
	elif dialog_id == "change_graph_nodes_color":
		change_graph_nodes_selected_color(select_color_dialog.color)
	hide_all()

func change_graph_nodes_selected_color(color):
	for child in graph_node_container.get_children():
		if child.focused:
			child.set_frame_color(color)
			child.color_picker_button.color = color

func _on_color_dialog_hide() -> void:
	hide_all_layer2.visible = false
	if select_color_dialog == null: return
	var presets = select_color_dialog.get_presets()
	if advance_text_editor_dialog != null:
		advance_text_editor_dialog.set_presets(presets)

func set_color_presets(presets : PoolColorArray) -> void:
	select_color_dialog.set_presets(presets)

func _on_ConfirmDialog_OK(text, dialog_id) -> void:
	hide_all()

func expand_or_collapse_left_panel(value, id: int) -> void:
	var node
	match id:
		0: node = find_node("TopPanel")
		1: node = find_node("Languages")
		2:
			node = find_node("Characters")
			if value:
				node.size_flags_vertical = SIZE_FILL
			else:
				node.size_flags_vertical = SIZE_EXPAND_FILL
		3: node = find_node("Variables")
		4: node = find_node("Signals")
		5: node = find_node("Terms")
	var node2 =  node.get_child(0)
	if value:
		LEFT_PANEL_SIZES[id] = node.rect_min_size.y
		node.rect_min_size.y = 40
		node.rect_size.y = node.rect_size.y
	else:
		node.rect_min_size.y = LEFT_PANEL_SIZES[id]
		node.rect_size.y = node.rect_size.y
	for i in range(1, node2.get_child_count()):
		node2.get_child(i).visible = !value

func _on_terms_ItemList_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == BUTTON_LEFT and event.doubleclick:
		_on_edit_terms_button_down()

func _on_edit_terms_button_down() -> void:
	if DATA.langs.size() == 0: return
	terms_dialog.languages = DATA.langs
	terms_dialog.terms = DATA.terms
	if terms_itemlist.is_anything_selected():
		terms_dialog.selectedIndex = terms_itemlist.get_selected_items()[0]
	show_dialog(terms_dialog)
	terms_dialog.rect_position = Vector2(212, 224)

func fill_terms_list() -> void:
	hide_all()
	var index = -1
	if terms_itemlist.is_anything_selected():
		index = terms_itemlist.get_selected_items()[0] 
	terms_itemlist.clear()
	for term in DATA.terms:
		terms_itemlist.add_item(term.id)
	if DATA.terms.size() > 0:
		index = max(0, min(index, DATA.terms.size() - 1))
		terms_itemlist.select(index)
		
	if terms_itemlist.get_item_count() != 0:
		terms_add_button.set_disabled(false)
	else:
		terms_add_button.set_disabled(true)
		
func fill_signals_list() -> void:
	hide_all()
	var index = -1
	if signal_itemlist.is_anything_selected():
		index = signal_itemlist.get_selected_items()[0] 
	signal_itemlist.clear()
	for s in DATA.signals:
		signal_itemlist.add_item(s)
	if DATA.signals.size() > 0:
		index = max(0, min(index, DATA.terms.size() - 1))
		signal_itemlist.select(index)
		
	if signal_itemlist.get_item_count() != 0:
		signal_remove_button.set_disabled(false)
	else:
		signal_remove_button.set_disabled(true)

func _on_remove_character_button_down() -> void:
	if !language_itemlist.is_anything_selected(): return
	if !character_itemlist.is_anything_selected(): return
	var index = character_itemlist.get_selected_items()[0]
	var t = "[color=#bafd87]%s[/color]" % DATA.characters[index].name
	t = "Do you want to delete the character\n\n%s  ?" % t
	confirm_dialog.label.bbcode_text = t
	show_dialog(confirm_dialog)
	yield(confirm_dialog, "hide")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if !confirm_dialog.is_ok: return
	
	# Delete character
	DATA.characters.remove(index)
	DATA.message_config_connections.remove(index)
	DATA.message_config_position.remove(index)
	for id in DATA.messages[index]:
		DATA.dialogs.erase(id)
		DATA.dialogs_text.erase(id)
	DATA.messages.remove(index)
	character_itemlist.remove_item(index)
	if DATA.characters.size() > 0:
		index = min(index, DATA.characters.size() - 1)
		character_itemlist.select(index)
		character_itemlist.ensure_current_is_visible()
		last_character = null
		character_itemlist.emit_signal("item_selected", index)
	else:
		clear_characters()


func _on_remove_signal_button_down() -> void:
	if !signal_itemlist.is_anything_selected(): return
	var index = signal_itemlist.get_selected_items()[0]
	var t = "[color=#bafd87]%s[/color]" % DATA.signals[index]
	t = "Do you want to delete the signal\n\n%s  ?" % t
	confirm_dialog.label.bbcode_text = t
	show_dialog(confirm_dialog)
	yield(confirm_dialog, "hide")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if !confirm_dialog.is_ok: return
	
	DATA.signals.remove(index)
	signal_itemlist.remove_item(index)
	if DATA.signals.size() > 0:
		index = min(index, DATA.signals.size() - 1)
		signal_itemlist.select(index)
		signal_itemlist.ensure_current_is_visible()
	else:
		signal_remove_button.set_disabled(true)

func _on_remove_variables_button_down() -> void:
	if !variable_itemlist.is_anything_selected(): return
	var index = variable_itemlist.get_selected_items()[0]
	var t = "[color=#bafd87]%s[/color]" % DATA.variables[index].name
	t = "Do you want to delete the variable\n\n%s  ?" % t
	confirm_dialog.label.bbcode_text = t
	show_dialog(confirm_dialog)
	yield(confirm_dialog, "hide")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if !confirm_dialog.is_ok: return
	
	DATA.variables.remove(index)
	variable_itemlist.remove_item(index)
	if DATA.variables.size() > 0:
		index = min(index, DATA.variables.size() - 1)
		variable_itemlist.select(index)
		variable_itemlist.ensure_current_is_visible()
	else:
		variable_delete_button.set_disabled(true)


func _on_TextEditDialog_dialog_color_request(obj) -> void:
	hide_all_layer2.visible = true
	select_color_dialog.dialog_id = "set_target_color_text"
	select_color_dialog.target_node = obj
	show_dialog(select_color_dialog, false)

func hide_a_graphnode(node):
	if node is GraphNodeMinimal: return
	var c = custom_graph_node_minimal.instance()
	c.resize(node.rect_size)
	c.data = node.get_data().duplicate(true)
	c.name = node.name
	c.title = node.title
	c.id = node.id
	c.rect_position = node.rect_position
	c.connections = node.get_connections()
	c.connect("tree_entered", self, "update_back_lines_draw")
	var _connections = connections
	graph_node_container.remove_child(node)
	node.queue_free()
	while is_instance_valid(node) and node.is_queued_for_deletion():
		yield(get_tree(), "idle_frame")
	graph_node_container.add_child(c)
	#graph_node_container.call_deferred("add_child", c)
	yield(get_tree(), "idle_frame")
	connections = _connections

func redo_graphnode(obj):
	if !obj is GraphNodeMinimal: return
	var data = obj.data.duplicate(true)
	graph_node_container.remove_child(obj)
	remove_child_in_graph_node(obj)
	while is_instance_valid(obj):
		yield(get_tree(), "idle_frame")
	var node
	match data.type:
		"message":
			create_graph_node(custom_graph_node_01,
				Vector2.ZERO, null, true, true, data.id, data.name)
			
		"variable":
			create_graph_node(custom_graph_node_03,
				Vector2.ZERO, "SET VARIABLE ID # ", true, true,
				data.id, data.name)
		"condition":
			create_graph_node(custom_graph_node_04,
				Vector2.ZERO, "CONDITIONALITY ID # ", true, true,
				data.id, data.name)
		"config":
			var title
			if DATA.message_config.size() == 1:
				title = "DEFAULT CONFIG"
			else:
				title = "CONFIG"
			create_graph_node(custom_graph_node_02,
				Vector2.ZERO, "%s ID # " % title, true, true,
				data.id, data.name)
	while last_graph_node_created == null:
		yield(get_tree(), "idle_frame")
	node = last_graph_node_created
	last_graph_node_created = null
	if node:
		while !node or !node.has_method("set_data"):
			node = graph_node_container.get_node_or_null(data.name)
			yield(get_tree(),"idle_frame")
		node.set_data(data)
		node.visible = true
		node.deselect()

func check_graph_node_visibility(node):
	for i in 10:
		yield(get_tree(), "idle_frame")
	set_offset(offset, true)
#	if node != null:
#		node.select()
	
func remove_child_in_graph_node(node):
	node.queue_free()

func show_dialog_input_actions_request(data):
	input_actions_dialog.set_data(data)
	show_dialog(input_actions_dialog)


func _on_SelectActionInput_OK(text, dialog_id) -> void:
	hide_all()

func set_as_default_config(data):
	default_config = data.duplicate(true)


func _on_ToJSONButton_button_down() -> void:
	if DATA.dialogs.size() == 0: return
	var f = File.new()
	f.open("res://dialog_exported.txt", File.WRITE)
	f.store_string(to_json(DATA))
	f.close()
	print("DATA exported to res://dialog_exported.txt")


func _on_NewProjectButton_button_down() -> void:
	if DATA.langs.size() != 0:
		var t = "\nDo you want to save the current project "
		t += "before creating a new one?"
		confirm_dialog.label.bbcode_text = t
		show_dialog(confirm_dialog)
		yield(confirm_dialog, "hide")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		if confirm_dialog.is_ok:
			save_data()
	if Input.is_key_pressed(KEY_ESCAPE):
		return
	clear()

func _process(delta: float) -> void:
	if !Engine.editor_hint:
		if DATA.size() > 0 and DATA.dialogs.size() > 0 and \
			auto_save_spinbox.value != 0:
			auto_save_cnt += delta
			if auto_save_cnt >= auto_save_spinbox.value:
				auto_save_cnt = 0
				save_data()
				
func show_dialog_ninepatch(img, patch):
	patch_grid_dialog.set_image(img, patch)
	show_dialog(patch_grid_dialog)


func _on_TextEditDialog_open_dialog_preview_request(id) -> void:
	dialog_preview_shown = true
	var node = preview_dialog.find_node("MessageBox")
	node.readonly = true
	node = preview_dialog.find_node("DialogBox")
	node.parse_data(get_data())
	yield(node, "parse_data_completed")
#	node.folders = DATA.editor_config.folders
#	node.process_text(text)
#	node.start()
	preview_dialog.rect_position = get_global_mouse_position() + Vector2(100, 0)
	preview_dialog.show()
	node.show_message(id)

func show_preview_config(config) -> void:
#	data.editor_config.folders.dialogs = save_dialog_folder_lineedit.text 
	var folders = {
		"graphics" : save_dialog_image_lineedit.text,
		"fonts" : save_dialog_font_lineedit.text,
		"sounds" : save_dialog_audio_lineedit.text
	}
	preview_dialog_config.set_config(config, folders)
	show_dialog(preview_dialog_config)

func preview_dialog(text : String, config_id : int, object = null) -> void:
	var config
	for child in graph_node_container.get_children():
		if child is CustomGraphNode_02 and child.id == config_id:
			config = child.get_data().config
			break
		elif child is GraphNodeMinimal and child.data.type == "config" and \
			child.data.id == config_id:
			config = child.get_data().config
			break
	preview_dialog_config.message_contents = text
	show_preview_config(config)
	if object != null:
		pass
#		object.visible = true
