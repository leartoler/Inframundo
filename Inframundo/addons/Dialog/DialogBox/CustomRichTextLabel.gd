tool
extends Control
class_name CustomRichTextLabel

var x = 0
var y = 0

var effects_stack = []
var characters_stack = []
var fonts_stack = {
	"normal_font"			: [],
	"bold_font"				: [],
	"italic_font"			: [],
	"bold_italic_font"		: [],
	"bold"					: 0,
	"italic"				: 0,
	"strike"				: 0,
	"underline"				: 0,
	"color"					: [],
	"line_align"			: []
}
var default_fonts = {
	"normal"		: "default_font-normal(16).tres",
	"bold"			: "default_font-bold(16).tres",
	"italic"		: "default_font-italic(16).tres",
	"bold_italic"	: "default_font-normal(16).tres",
	"color"			: Color.white,
	"align"			: "left"
}
var current_font =  []
var default_font

var running = false
var letter_by_letter  = true
var letter_by_letter_fast_display = true
var letter_by_letter_fx = null
var letter_by_letter_resume_fx = null
var line_data = {
	"current_page"	: 0,
	"current_line"	: 1,
	"current_char"	: 1,
	"completed"		: false,
	"next_page"		: false,
}
var break_page_found = false
var current_text = ""
var max_lines = 4
var line_height = 0
var lines_height = []
var line_width = 0
var lines_width = []
var total_height = 0
var total_width = 0
var line = []
var waiting = false setget set_waiting
var waittime = 0
var autocontinue = false
var delay_beetween_characters = 0.05
var pause_game = true
var appearance_animation_id = 0
var disappearance_animation_id = 0
var wordwrap = true
var input_actions
var force_process = false

var parent = null setget set_parent
var folders = null
var readonly = false

var wait_for_resume = false
var resumed = false

var is_in_editor = false

var CACHE = {} # store fonts and images. CACHE get empty when message hide

var valid_effects = ["b", "i", "u", "s", "center", "right", "left", "font",
	"color", "face", "character", "img", "image_effect", "remove_image",
	"show_box_name", "remove_box_name", "ident", "wave", "tornado", "shake",
	"fade", "zoom", "angle", "pause", "pagebreak", "play_sound", "set_lbl",
	"emit_signal", "var", "term", "rainbow", "ghost", "pulse", "matrix",
	"fade_animation", "character_name", "indent", "set_config"]
	
signal perform_action(data)
signal text_processed()
signal text_cleared()
signal all_text_shown()
signal configured()

func _ready() -> void:
	fill_initial_data()
	
func clear(clear_cache=false):
	set_process(false)
	running = false
	force_process = false
	effects_stack.clear()
	characters_stack.clear()
	yield(get_tree(), "idle_frame")
	fonts_stack.normal_font.clear()
	fonts_stack.bold_font.clear()
	fonts_stack.italic_font.clear()
	fonts_stack.bold_italic_font.clear()
	fonts_stack.color.clear()
	fonts_stack.line_align.clear()
	fonts_stack.bold = 0
	fonts_stack.italic = 0
	fonts_stack.strike = 0
	fonts_stack.underline = 0
	current_font.clear()
	current_font.append(default_fonts.normal)
	default_font = null
	current_text = ""
	max_lines = 4
	line_height = 0
	lines_height.clear()
	line_width = 0
	lines_width.clear()
	total_height = 0
	total_width = 0
	line_data = {
		"current_page"	: 0,
		"current_line"	: 1,
		"current_char"	: 1,
		"completed"		: false,
		"next_page"		: false,
		"delay"			: 0
	}
	x = 0
	y = 0
	set("waiting", false)
	waittime = 0
	autocontinue = false
	delay_beetween_characters = 0.05
	wait_for_resume = false
	resumed = false
#	var main_node = get_parent().get_parent().get_parent().get_parent()
#	main_node.find_node("NameBoxLeft").modulate.a = 0
#	main_node.find_node("NameBoxRight").modulate.a = 0
#	main_node.find_node("Face").texture = null
#	for child in main_node.find_node("full_character_images").get_children():
#		main_node.find_node("full_character_images").remove_child(child)
#		child.queue_free()

	update()
	if clear_cache: CACHE.clear()
	fill_initial_data()
	emit_signal("text_cleared")
	

func set_parent(value):
	parent = value


func set_waiting(value):
	waiting = value
	if (Engine.editor_hint or readonly) and waiting and !autocontinue:
		waittime = 2.5
		autocontinue = true
	if waittime == 0 or !value or(waittime > 0 and (
		Engine.editor_hint or readonly)):
		var main_node = get_parent().get_parent().get_parent().get_parent()
		main_node.find_node("ResumeButton").visible = value
	if !value and line_data.next_page:
		line_data.next_page = false
		line_data.current_page += 1
		line_data.current_char = 1
		line_data.current_line = 1


func fill_initial_data():
	var label = Label.new()
	default_font = label.get_font("")
	var file = File.new()
	var default_folder = "" if folders == null else folders.fonts
	var path = default_folder + default_fonts.normal
	if file.file_exists(path):
		fonts_stack.normal_font.append(path)
		current_font.append(path)
	else:
		current_font.append(null)
	path = default_folder + default_fonts.bold
	if file.file_exists(path):
		fonts_stack.bold_font.append(path)
	path = default_folder + default_fonts.italic
	if file.file_exists(path):
		fonts_stack.italic_font.append(path)
	path = default_folder + default_fonts.bold_italic
	if file.file_exists(path):
		fonts_stack.bold_italic_font.append(path)
	fonts_stack.color.append(default_fonts.color)
	fonts_stack.line_align.append(default_fonts.align)

func get_cache_data(path):
	if !path is String:
		return null
	if CACHE.has(path):
		return CACHE[path]
	else:
		if ResourceLoader.exists(path):
			CACHE[path] = ResourceLoader.load(path)
			return CACHE[path]
	return null
	
func get_cache_font(path):
	if path != null and path.find("res://") == -1 and folders != null:
		path = folders.fonts + path
	var font = get_cache_data(path)
	if font is DynamicFont:
		return font
	else:
		return default_font

func print_data_in_tree(data, tab=0):
	if data is Dictionary:
		var t = ""
		for i in tab:
			t += "\t"
		t += "- "
		for key in data.keys():
			if data[key] is Dictionary:
				print(t + key + ":")
			else:
				print(t + key + ": " + str(data[key]))
			if data[key] is Dictionary:
				print_data_in_tree(data[key], tab+1)

func set_config(data):
	#print_data_in_tree(data)
	yield(get_tree(), "idle_frame")
	set_config_letter_by_letter(data.letter_by_letter)
	set_config_default_font(data.default_font)
	set_config_dialog_box(data.dialog_box_config)
	set_config_left_name_box(data.left_box_name_config,
		data.name_box_background_image)
	set_config_right_name_box(data.right_box_name_config,
		data.name_box_background_image)
	set_config_options_box(data.options_box_config)
	set_config_background_image(data.background_image)
	set_config_name_box_background_image(data.name_box_background_image)
	set_config_options_background_image(data.options_box_background_image,
		data.options_answerd_background_image)
	set_config_options_cursor_image(data.options_cursor_image)
	set_config_resume_button_image(data.resume_button_image)
	input_actions = data.input_actions
	if Engine.editor_hint:
		property_list_changed_notify()
	emit_signal("configured")

func set_config_letter_by_letter(data):
	letter_by_letter = data.enabled
	letter_by_letter_fx = data.sound
	letter_by_letter_resume_fx = data.ok_sound
	delay_beetween_characters = data.text_speed
	letter_by_letter_fast_display = data.skip

func set_config_default_font(data):
	default_fonts.normal = data.normal
	default_fonts.bold = data.bold
	default_fonts.italic = data.italic
	default_fonts.bold_italic = data.bold_italic

func set_config_dialog_box(data):
	var main = get_parent().get_parent().get_parent().get_parent()
	var viewport_size
	if is_in_editor:
		viewport_size = main.get_parent().get_parent().get_parent().rect_size
	else:
		if !readonly:
			viewport_size = Vector2(
				ProjectSettings.get("display/window/size/width"),
				ProjectSettings.get("display/window/size/height")
			)
		else:
			viewport_size = main.get_parent().get_parent().rect_size
	if data.fit_width:
		main.rect_size.x = viewport_size.x - data.parent_margins.left - \
			data.parent_margins.right
		main.rect_position.x = viewport_size.x * 0.5 - main.rect_size.x * 0.5
	else:
		main.rect_size.x = data.size.x
		main.rect_position.x = data.position.dest.x
	main.rect_size.y = data.size.y
	match data.position.type:
		0: # Top
			main.rect_position.y = 0
			if data.fit_width:
				main.rect_position.y -= data.parent_margins.top
		1: # Mid
			main.rect_position.y = viewport_size.y * 0.5 - rect_size.y * 0.5
			if data.fit_width:
				main.rect_position.y -= data.parent_margins.top + \
					 data.parent_margins.bottom
		2: # Bottom
			main.rect_position.y = viewport_size.y - rect_size.y
			if data.fit_width:
				main.rect_position.y -= data.parent_margins.bottom
		3: # Custom
			main.rect_position.y = data.position.dest.y
	if readonly:
		var p = main.get_parent().get_parent().rect_position
		main.rect_position += p
	max_lines = int(data.lines_shown)
	main.find_node("Face").rect_min_size = data.face_size
	main.find_node("Face").rect_size = data.face_size
	main.find_node("Face").rect_pivot_offset = data.face_size * 0.5
	main.find_node("HBoxContainer").set("custom_constants/separation",
		data.face_text_separation)
	var obj = main.find_node("MessageMarginContainer")
	obj.set("custom_constants/margin_right", data.message_margins.right)
	obj.set("custom_constants/margin_left", data.message_margins.left)
	obj.set("custom_constants/margin_top", data.message_margins.top)
	obj.set("custom_constants/margin_bottom", data.message_margins.bottom)
	main.rect_clip_content = data.clip_text
	main.property_list_changed_notify()
	pause_game = data.pause_game
	appearance_animation_id = data.appearance_animation
	disappearance_animation_id = data.disappearance_animation
	default_fonts.align = data.default_align
	wordwrap = data.autowrap

func set_config_left_name_box(data1, data2):
	var main = get_parent().get_parent().get_parent().get_parent()
	var obj = main.find_node("NameBoxLeft")
	obj.set_data_text(data1)
	obj.set_image_data(data2)

func set_config_right_name_box(data1, data2):
	var main = get_parent().get_parent().get_parent().get_parent()
	var obj = main.find_node("NameBoxRight")
	obj.set_data_text(data1)
	obj.set_image_data(data2)

func set_config_options_box(data):
	if parent != null or is_in_editor:
		var main = get_parent().get_parent().get_parent().get_parent()
		var obj = main.find_node("SelectOptions")
		obj.set_config(data)

func set_config_background_image(data):
	if parent != null or is_in_editor:
		var main = get_parent().get_parent().get_parent().get_parent()
		var node = main.find_node("Dialog")
		if data.image != null and data.image != "":
			var path
			if folders != null:
				path = folders.graphics + data.image
			else:
				path = data.image
			node.texture = get_cache_data(path)
			node.patch_margin_left = data.patch_margin_left
			node.patch_margin_right = data.patch_margin_right
			node.patch_margin_top = data.patch_margin_top
			node.patch_margin_bottom = data.patch_margin_bottom
			node.axis_stretch_horizontal = data.axis_stretch_horizontal
			node.axis_stretch_vertical = data.axis_stretch_vertical
			node.draw_center = data.draw_center
			node.self_modulate = data.color
			node.animation = {
				"max_frames"	: data.frames,
				"current_frame"	: Vector2(0, 0),
				"delay"			: data.delay,
				"time"			: 0
			}
			node.update_texture()
		else:
			node.texture = null

func set_config_name_box_background_image(data):
	if parent != null or is_in_editor:
		var main = get_parent().get_parent().get_parent().get_parent()
		main.find_node("NameBoxLeft").set_image_data(data)
		main.find_node("NameBoxRight").set_image_data(data)
		
func set_config_options_background_image(data1, data2):
	if parent != null or is_in_editor:
		var main = get_parent().get_parent().get_parent().get_parent()
		var obj = main.find_node("SelectOptions")
		obj.set_images_config(data1, data2)
		
func set_config_options_cursor_image(data):
	if parent != null or is_in_editor:
		var main = get_parent().get_parent().get_parent().get_parent()
		var node = main.find_node("Cursor")
		if data.image != null and data.image != "":
			var path
			if folders != null:
				path = folders.graphics + data.image
			else:
				path = data.image
			node.texture = get_cache_data(path)
			if node.texture != null:
				var size = node.texture.get_data().get_size() / data.frames
				if data.auto_size:
					node.scale = Vector2.ONE
				else:
					node.scale = data.size / size
				size *= node.scale
			node.self_modulate = data.color
			node.offset = data.offset
			node.animation = {
				"max_frames"	: data.frames,
				"current_frame"	: Vector2(0, 0),
				"delay"			: data.delay,
				"time"			: 0
			}
			node.update_texture()
		else:
			node.texture = null
		
func set_config_resume_button_image(data):
	if parent != null or is_in_editor:
		var main = get_parent().get_parent().get_parent().get_parent()
		var node = main.find_node("ResumeButton")
		if data.image != null and data.image != "":
			var path
			if folders != null:
				path = folders.graphics + data.image
			else:
				path = data.image
			node.texture = get_cache_data(path)
			if node.texture != null:
				var size = node.texture.get_data().get_size() / data.frames
				if data.auto_size:
					node.scale = Vector2.ONE
				else:
					node.scale = data.size / size
				size *= node.scale
				node.position.y = main.rect_size.y - size.y
				match data.position:
					0: # Bottom Left
						node.position.x = size.x
					1: # Bottom Mid
						node.position.x = main.rect_size.x * 0.5
					2: # Bottom Right
						node.position.x = main.rect_size.x - size.x
				node.position.y = main.rect_size.y - size.y
			node.self_modulate = data.color
			node.offset = data.offset
			node.animation = {
				"max_frames"	: data.frames,
				"current_frame"	: Vector2(0, 0),
				"delay"			: data.delay,
				"time"			: 0
			}
			node.update_texture()
		else:
			node.texture = null

func process_text(text : String):
	yield(get_tree(), "idle_frame")
	# replaces [var id=n], [term id=n], [character_name=id], [indent] for
	# variable value, term translated, name of character, "    " respectively
	var regex = RegEx.new()
	# Replace [indent] with \t
	text = text.replace("[indent]", "\t")
	text = text.replace("[pagebreak]\n", "[pagebreak]")
	text = text.replace("\n■\n", "")
	# Replaces [var id=n] with variable value
	regex.compile("(\\[var id=(\\d+)\\])")
	for m in regex.search_all(text):
		text = text.replace(m.get_string(),
			get_variable(int(m.get_string(2))))
	# Replaces [term id=n] with term translated
	regex.compile("(\\[term id=([^ \\]]+)\\])")
	for m in regex.search_all(text):
		text = text.replace(m.get_string(),
			get_term(m.get_string(2)))
	# Replaces [character_name=id] with the name of the character specified in id 
	regex.compile("(\\[character_name=(\\d+)\\])")
	for m in regex.search_all(text):
		text = text.replace(m.get_string(),
			get_character_name(int(m.get_string(2))))
	# Process rest of text and commands
	characters_stack.clear()
	characters_stack.append([])
	current_text = ""
	line_data.line_count = 0
	var regex1 = RegEx.new()
	#regex1.compile("\\[([^\\[\\]]+)\\]|([^\\[\\]]+)")
	regex1.compile("([^\\[]*)(\\[[^\\]]+\\])?")
	var regex2 = RegEx.new()
	regex2.compile("\\[([^ =\\]]+[^\\]]*)\\]|([^\\[]+)")
	for m in regex1.search_all(text):
		if m.get_string().length() > 0:
			for m2 in regex2.search_all(m.get_string()):
				if m2.get_string(1).length() > 0: # Check for valid command
					var data = m2.get_string(1).split(" ")
					if data[0].find("=") != -1:
						var data2 = data[0].split("=")
						data = [data2[0], "%s=%s" % [data2[0], data2[1]]]
					var effect_name = data[0] if data[0].find("/") != 0 else \
						data[0].right(1)
					if valid_effects.has(effect_name):
						var command = get_command(data)
						if command != null:
							if command.has("type") and command["type"] == "img":
								line.append(command)
							elif command.parameters.has("ImmediateEffect"):
								command.type = "effect"
								if command.name != "set_config":
									line.append(command)
								if command.name == "pagebreak" or \
									command.name == "set_config":
									total_width += line_width
									total_height += line_height
									lines_height.append(line_height)
									lines_width.append(line_width)
									characters_stack[-1].append(line)
									characters_stack.append([])
									line = []
									if command.name == "set_config":
										line.append(command)
									x = 0; y = 0;
									line_height = 0; line_width = 0
									line_data.line_count = 0;
									break_page_found = true
							else:
								effects_stack.append(command)
					else:
						create_characteres(m2.get_string(0))
				elif m2.get_string(2).length() > 0: # Normal text
					create_characteres(m2.get_string(2))
	if line.size() > 0:
		total_width += line_width
		total_height += line_height
		lines_height.append(line_height)
		lines_width.append(line_width)
		characters_stack[-1].append(line)
		line = []
	# Final Checks, Fix aligns
	for page in characters_stack:
		for line in page:
			var align = "left"
			for i in line.size():
				var obj = line.size() - i - 1
				if obj is Dictionary and obj.has(align):
					align = obj.align
					break
			for chr in line:
				if chr is Dictionary and chr.has(align):
					chr.align = align
	# Process text Completed
	emit_signal("text_processed")

func set_embed_image(img):
	return
#	var chr = {
#		"size"			: Vector2(img.width, img.height),
#		"effects"		: [],
#		"angle"			: 0,
#		"zoom"			: 1,
#		"position"		: Vector2(x, y),
#		"offset"		: Vector2.ZERO,
#		"fx_offset"		: {},
#		"color"			: fonts_stack.color[-1],
#		"align"			: fonts_stack.line_align[-1],
#		"img"			: img.parameters.
#		"type"			: "img"
#	}
#	x += img.width
#	var effects_added = {}
#	for effect in effects_stack:
#		effects_added[effect.name] = effect
#	for effect in effects_added.values():
#		chr.effects.append(effect.duplicate(true))
#		effect.index += 1
#	line.append(chr)

func get_term(id):
	if parent  != null:
		for term in parent.lang_data.terms:
			if term.id == id:
				var lang_name = parent.current_lang.get_file().trim_suffix(".lang")
				for i in parent.lang_data.langs.size():
					if parent.lang_data.langs[i].name == lang_name:
						return term.values[i]
	return ""
	
func get_variable(id):
	if parent != null:
		if parent.lang_data.variables.size() > id:
			return parent.lang_data.variables[id].value
	return ""
	
func get_character_name(id):
	if parent != null:
		if parent.lang_data.characters.size() > id:
			return parent.lang_data.characters[id].name
	return ""

func get_command(command : PoolStringArray):
	if command[0].find("/") == 0: # close command
		match command[0].right(1):
			"b" : fonts_stack.bold -= 1
			"i" : fonts_stack.italic -= 1
			"s" : fonts_stack.strike -= 1
			"u" : fonts_stack.underline -= 1
			"left", "center", "right":
				if fonts_stack.line_align.size() > 1:
					fonts_stack.line_align.pop_back()
			"color":
				if fonts_stack.color.size() > 1:
					fonts_stack.color.pop_back()
			"font":
				if command.size() == 2:
					var data = command[1].split("=")
					if data[0] == "type":
						match int(data[1]):
							0: # Normal Font
								if fonts_stack.normal_font.size() > 1:
									fonts_stack.normal_font.pop_back()
									current_font.pop_back()
							1: # Bold Font
								if fonts_stack.bold_font.size() > 1:
									fonts_stack.bold_font.pop_back()
									current_font.pop_back()
							2: # Italic Font
								if fonts_stack.italic_font.size() > 1:
									fonts_stack.italic_font.pop_back()
									current_font.pop_back()
							3: # Bold Italic Font
								if fonts_stack.bold_italic_font.size() > 1:
									fonts_stack.bold_italic_font.pop_back()
									current_font.pop_back()
						if current_font.size() == 0: current_font.append(null)
			_: # else (others close commands)
				var effect_name = command[0].right(1)
				for i in effects_stack.size():
					var id = effects_stack.size() - 1 - i
					if effects_stack[id].name == effect_name:
						effects_stack.remove(id)
					break
	else:
		match command[0]:
			"b" : fonts_stack.bold += 1
			"i" : fonts_stack.italic += 1
			"s" : fonts_stack.strike += 1
			"u" : fonts_stack.underline += 1
			"left", "center", "right":
				fonts_stack.line_align.append(command[0])
			"color":
				var effect = {}
				for i in range(1, command.size()):
					var data = command[i].split("=")
					effect[data[0]] = get_value(data)
				if effect.has("color"):
					fonts_stack.color.append(effect.color)
			"font":
				var effect = {}
				for i in range(1, command.size()):
					var data = command[i].split("=")
					effect[data[0]] = get_value(data)
				if effect.has("name") and effect.has("type"):
					var full_font_path
					if folders != null:
						full_font_path = folders.fonts + effect.name
					else:
						full_font_path = effect.name
					match effect.type:
						0: fonts_stack.normal_font.append(full_font_path)
						1: fonts_stack.bold_font.append(full_font_path)
						2: fonts_stack.italic_font.append(full_font_path)
						3: fonts_stack.bold_italic_font.append(full_font_path)
					current_font.append(full_font_path)
			_: # else
				var effect = {
					"index"			: 0,
					"name"			: "",
					"parameters"	: {},
					"elapsed_time"	: 0
				}
				effect.name = command[0]
				for i in range(1, command.size()):
					var data = command[i].split("=")
					effect.parameters[data[0]] = get_value(data)
				# Autocomplete effects parameters:
				get_right_parameters(effect)
				return effect
	return null

func get_right_parameters(effect):
	var params = effect.parameters
	# valid keys -> [Default value, min value, max value]
	var valid_keys = {}
	match effect.name:
		"matrix":
			valid_keys["clean"] = [2.1, null, null]
			valid_keys["dirty"] = [1.0, null, null]
			valid_keys["span"] = [12.0, null, null]
		"fade_animation":
			valid_keys["time"] = [5.0, 0.1, null]
			valid_keys["mode"] = [0, 0, 1]
		"wave":
			valid_keys["freq"] = [10.0, null, null]
			valid_keys["amp"] = [50.0, null, null]
		"tornado":
			valid_keys["freq"] = [2.0, null, null]
			valid_keys["radius"] = [5.0, null, null]
		"rainbow":
			valid_keys["freq"] = [-5.5, null, null]
			valid_keys["sat"] = [8.0, null, null]
			valid_keys["val"] = [5.5, null, null]
		"shake":
			valid_keys["level"] = [1.5, null, null]
			valid_keys["rate"] = [0.1, null, null]
		"fade":
			valid_keys["start"] = [2.0, null, null]
			valid_keys["length"] = [10.0, null, null]
		"ghost":
			valid_keys["freq"] = [2.0, null, null]
			valid_keys["span"] = [2.0, null, null]
		"pulse":
			valid_keys["freq"] = [10.0, null, null]
			valid_keys["color"] = [Color.red, null, null]
		"zoom":
			valid_keys["start"] = [3.5, null, null]
			valid_keys["end"] = [1.0, null, null]
			valid_keys["time"] = [0.5, 0.1, null]
			valid_keys["loop"] = [1, 0, null]
		"angle":
			valid_keys["start"] = [720, null, null]
			valid_keys["end"] = [0.0, null, null]
			valid_keys["time"] = [2.0, 0.1, null]
			valid_keys["loop"] = [1, 0, null]
		"face":
			valid_keys["img"] = [null, null, null]
			valid_keys["flip"] = [false, null, null]
			valid_keys["color"] = [Color.white, null, null]
			valid_keys["animation"] = [0, 0, null]
			valid_keys["params"] = [null, null, null]
			valid_keys["ImmediateEffect"] = [true, null, null]
		"character":
			valid_keys["img"] = [null, null, null]
			valid_keys["flip"] = [false, null, null]
			valid_keys["scale"] = ["1x1", null, null]
			valid_keys["height"] = [32, 0, null]
			valid_keys["id"] = [-1, null, null]
			valid_keys["mode"] = [0, 0, 1]
			valid_keys["color"] = [Color.white, null, null]
			valid_keys["pos"] = ["0,0,0", null, null]
			valid_keys["animation"] = [0, 0, null]
			valid_keys["params"] = [null, null, null]
			valid_keys["ImmediateEffect"] = [true, null, null]
		"img":
			valid_keys["name"] = [null, null, null]
			valid_keys["scale"] = ["1x1", null, null]
			valid_keys["flip"] = [false, null, null]
			valid_keys["offset"] = [0, null, null]
		"image_effect":
			valid_keys["id"] = [0, 0, null]
			valid_keys["effect_id"] = [null, null, null]
			valid_keys["image_type"] = [-1, null, null]
			valid_keys["rate"] = [5, null, null]
			valid_keys["level"] = [0.1, null, null]
			valid_keys["delay"] = [0.0, 0.0, null]
			valid_keys["set_pause"] = [false, null, null]
			valid_keys["time"] = [0.01, 0.01, null]
			valid_keys["opacity"] = [0.0, 0.0, 100.0]
			valid_keys["mode"] = [0, 1, null]
			valid_keys["color"] = [Color.white, null, null]
			valid_keys["x"] = [0, null, null]
			valid_keys["y"] = [0, null, null]
			valid_keys["angle"] = [0, null, null]
			valid_keys["ImmediateEffect"] = [true, null, null]
		"remove_image":
			valid_keys["type"] = [-1, null, null]
			valid_keys["id"] = [0, 0, null]
			valid_keys["ImmediateEffect"] = [true, null, null]
		"show_box_name":
			valid_keys["type"] = [-1, null, null]
			valid_keys["sub_type"] = [-1, null, null]
			valid_keys["id"] = [-1, null, null]
			valid_keys["name"] = ["", null, null]
			valid_keys["ImmediateEffect"] = [true, null, null]
		"remove_box_name":
			valid_keys["type"] = [-1, null, null]
			valid_keys["ImmediateEffect"] = [true, null, null]
		"pause":
			valid_keys["time"] = [0.1, 0.1, null]
			valid_keys["auto_continue"] = [true, null, null]
			valid_keys["ImmediateEffect"] = [true, null, null]
		"play_sound":
			valid_keys["path"] = ["", null, null]
			valid_keys["ImmediateEffect"] = [true, null, null]
		"set_lbl":
			valid_keys["enabled"] = [true, null, null]
			valid_keys["ImmediateEffect"] = [true, null, null]
		"emit_signal":
			valid_keys["id"] = [-1, null, null]
			valid_keys["ImmediateEffect"] = [true, null, null]
		"pagebreak":
			valid_keys["ImmediateEffect"] = [true, null, null]
		"set_config":
			valid_keys["id"] = [0, null, null]
			valid_keys["ImmediateEffect"] = [true, null, null]

	for key in params.keys():
		if !valid_keys.has(key):
			params.erase(key)
			
	for key in valid_keys.keys():
		if !params.has(key):
			params[key] = valid_keys[key][0]
		else:
			if valid_keys[key][1] != null:
				params[key] = max(valid_keys[key][1], params[key])
			if valid_keys[key][2] != null:
				params[key] = min(valid_keys[key][2], params[key])
				
	var key = null
	match effect.name:
		"face", "character":
			key = "img"
			if effect.name == "character":
				var pos = params["pos"].split(",")
				params["pos"] = pos[0]
				params["offset"] = Vector2(int(pos[1]), int(pos[2]))
		"img":
			key = "name"
			var img = get_cache_data(params.name)
			if img != null:
				params["width"] = img.get_width() * params.scale.x
				params["height"] =img.get_height() * params.scale.y
			else:
				params["width"] = 0
				params["height"] = 0
		"play_sound":
			key = "path"
	if key != null:
		var begin_path = ""
		if folders != null:
			if effect.name == "play_sound":
				begin_path = folders.sounds
			else:
				begin_path = folders.graphics
		params[key] = begin_path + params[key].replace("■", " ")
		var obj = get_cache_data(params[key]) # preload resource
		if obj != null and effect.name == "img":
			var s = Vector2(params["width"], params["height"])
			
			var chr = {
				"img"			: params[key],
				"size"			: s,
				"effects"		: [],
				"angle"			: 0,
				"zoom"			: 1,
				"position"		: Vector2(x, y),
				"offset"		: Vector2(0, -s.y + 2 + int(params["offset"])),
				"fx_offset"		: {},
				"color"			: fonts_stack.color[-1],
				"align"			: fonts_stack.line_align[-1],
				"flip"			: params["flip"],
				"type"			: "img"
			}
			x += chr.size.x + 2
			line_height = max(line_height, chr.size.y + 2)
			line_width += chr.size.x
			var effects_added = {}
			for _effect in effects_stack:
				effects_added[_effect.name] = _effect
			for _effect in effects_added.values():
				chr.effects.append(_effect.duplicate(true))
				_effect.index += 1
			effect.clear()
			for key2 in chr.keys():
				effect[key2] = chr[key2]

	params["process"] = true # if "process" is false the effect does not play

func create_characteres(text : String) -> void:
	var font
	if current_font.size() > 0:
		while current_font.size() > 0 and current_font[-1] == null:
			current_font.pop_back()
		if current_font.size() > 0:
			font = current_font[-1]
		else:
			font = default_fonts.normal
	else:
		font = null
	var real_font = get_cache_font(font)
	# wordwrap
	# ---------------------------------------------------
	if wordwrap:
		var xx = x
		var word = ""
		var new_text = ""
		for i in text.length():
			var size = real_font.get_string_size(text[i])
			if xx + size.x >= rect_size.x - 12:
				new_text += "\n"
				xx = 0
			elif text[i] == "\n":
				xx = 0
			else:
				xx += size.x
			if text[i] == " ":
				xx += size.x
				new_text += word + " "
				word = ""
			else:
				word += text[i]
		if word.length() > 0:
			if xx >= rect_size.x - 12:
				new_text += "\n"
			new_text += word
		text = new_text
		current_text += new_text
	# ---------------------------------------------------
	for i in text.length():
		if text[i] == "\n":
			total_width += line_width
			if line_height == 0:
				line_height = real_font.get_string_size(" ").y
			total_height += line_height
			lines_height.append(line_height)
			lines_width.append(line_width)
			characters_stack[-1].append(line)
			line = []
			x = 0
			if line_data.line_count >= max_lines - 1:
				y = 0
				line_data.line_count = 0
				characters_stack.append([])
			else:
				if characters_stack[-1].size() == 0:
					y = 0
				else:
					y += line_height
				if break_page_found:
					break_page_found = false
				line_data.line_count += 1
			line_height = 0
			line_width = 0
			continue
		var size = real_font.get_string_size(text[i])
		line_height = max(line_height, size.y)
		line_width += size.x
		if text[i] == " ": # Calculate size but no append to stack
			x += size.x
			continue
		elif text[i] == "\t": # tab
			size = real_font.get_string_size(" ").x * 6
			x = ceil((x + size) / size) * size
			continue
		var chr = {
			"text"			: text[i],
			"size"			: size,
			"effects"		: [],
			"angle"			: 0,
			"zoom"			: 1,
			"position"		: Vector2(x, y),
			"offset"		: Vector2.ZERO,
			"fx_offset"		: {},
			"font"			: font,
			"bold"			: fonts_stack.bold,
			"italic"		: fonts_stack.italic,
			"strike"		: fonts_stack.strike,
			"underline"		: fonts_stack.underline,
			"color"			: fonts_stack.color[-1],
			"align"			: fonts_stack.line_align[-1],
			"type"			: "text"
		}
		x += size.x
		var effects_added = {}
		for effect in effects_stack:
			effects_added[effect.name] = effect
		for effect in effects_added.values():
			chr.effects.append(effect.duplicate(true))
			effect.index += 1
		line.append(chr)


func get_value(data : PoolStringArray):
	if data.size() < 2: return ""
	match data[0]:
		"end", "start", "time", "opacity", "rate", "level", "amp", \
		"freq", "radius", "length", "span", "speed", \
		"width", "height", "clean", "dirty", "delay", "angle":
			return float(data[1])
		"mode", "id", "x", "y", "image_type", "type", \
		"sub_type", "loop", "character_name", "pos", "animation":
			if data[0] == "pos":
				if data[1].find(",") == -1:
					return int(data[1])
			else:
				return int(data[1])
		"color":
			return Color(data[1])
		"flip", "auto_continue", "enabled":
			return data[1].to_lower() == "true"
		"scale":
			var values = data[1].split("x")
			return Vector2(float(values[0]), float(values[1]))
	return str(data[1])

func update_effects(delta):
	if line_data.current_page > characters_stack.size() - 1: return
	var page = characters_stack[line_data.current_page]
	var max_value = min(line_data.current_line, page.size())
	for line in range(0, max_value):
		if line < line_data.current_line - 1:
			max_value = page[line].size()
		else:
			max_value = line_data.current_char + 1
		max_value = min(max_value, page[line].size())
		for i in range(0, max_value):
			var data = characters_stack[line_data.current_page][line][i]
			if data.has("effects"):
				if data.effects.size() > 0:
					process_effects(data, delta)


func process_effects(data, delta):
	for i in data.effects.size():
		var effect = data.effects[i]
		match effect.name:
			"wave": update_wave(data, i, delta)
			"tornado": update_tornado(data, i, delta)
			"rainbow": update_rainbow(data, i, delta)
			"shake": update_shake(data, i, delta)
			"fade": update_fade(data, i, delta)
			"ghost": update_ghost(data, i, delta)
			"pulse": update_pulse(data, i, delta)
			"matrix": update_matrix(data, i, delta)
			"fade_animation": update_fade_animation(data, i, delta)
			"zoom": update_zoom_animation(data, i, delta)
			"angle": update_angle_animation(data, i, delta)

func process_inmediate_effect(data):
	if !data.parameters.process: return
	match data.name:
		"pagebreak":
			line_data.next_page = true
			set("waiting", true)
			return
		"pause":
			waittime = max(0, data.parameters.time)
			autocontinue = data.parameters.auto_continue == true
			set("waiting", true)
		"image_effect":
			if data.parameters.set_pause and data.parameters.time > 0:
				if data.parameters.has("delay"):
					waittime = data.parameters.time + data.parameters.delay
				else:
					waittime = data.parameters.time
				autocontinue = true
				set("waiting", true)
				data.parameters.set_pause = false
				#print("SET WAITING")
			if data is Dictionary and data.has("parameters") and \
				data.parameters.has("delay") and data.parameters.delay > 0:
				data.parameters.delay -= get_process_delta_time()
				return
		"set_lbl":
			letter_by_letter = data.parameters.enabled
		"play_sound":
			var main_node = get_parent().get_parent().get_parent().get_parent()
			var sound = get_cache_data(data.parameters.path)
			if sound != null:
				var sound_player = main_node.find_node("AudioStreamPlayer6")
				sound_player.stream = sound
				sound_player.play()
		"set_config":
			wait_for_resume = true

	
	emit_signal("perform_action", data) # effect process by parent
	data.parameters.process = false # inmediate effects only run 1 time

func update_wave(data, effect_id, delta):
	var effect = data.effects[effect_id]
	effect.elapsed_time += delta # amp freq
	var value = sin(effect.parameters.freq * effect.elapsed_time +
		effect.index) * effect.parameters.amp / 10.0
	var p = Vector2(0, 1) * value
	data.fx_offset[effect.name] = p
	
func update_tornado(data, effect_id, delta):
	var effect = data.effects[effect_id]
	effect.elapsed_time += delta
	var torn_x = sin(effect.parameters.freq * effect.elapsed_time +
		effect.index / 5.0) * effect.parameters.radius / 50.0
	var torn_y = cos(effect.parameters.freq * effect.elapsed_time +
		effect.index / 5.0) * effect.parameters.radius / 50.0
	if data.fx_offset.has(effect.name):
		data.fx_offset[effect.name] += Vector2(torn_x, torn_y)
	else:
		data.fx_offset[effect.name] = Vector2(torn_x, torn_y)

func update_rainbow(data, effect_id, delta):
	var effect = data.effects[effect_id]
	effect.elapsed_time += delta
	data.color = Color.from_hsv(
		sin(effect.parameters.freq * effect.elapsed_time + effect.index),
		effect.parameters.sat,
		effect.parameters.val,
		data.color.a
	)

func update_shake(data, effect_id, delta):
	var effect = data.effects[effect_id]
	effect.elapsed_time += delta
	var offset_x = rand_range(-effect.parameters.level, effect.parameters.level) * 1
	var offset_y = rand_range(-effect.parameters.level, effect.parameters.level) * 1
	offset_x *= effect.parameters.rate
	data.fx_offset[effect.name] = Vector2(offset_x, offset_y)

func update_fade(data, effect_id, delta):
	var effect = data.effects[effect_id]
	effect.elapsed_time += delta
	var alpha = 1.0
	if effect.index > effect.parameters.start:
		var index = effect.index - effect.parameters.start
		var mod = 1.0 / effect.parameters.length
		alpha = max(0, min(1, 1.0 - mod * index))
	data.color.a = alpha
	
func update_ghost(data, effect_id, delta):
	var effect = data.effects[effect_id]
	effect.elapsed_time += delta
	var speed = effect.parameters.freq
	var span = effect.parameters.span
	var alpha = sin(effect.elapsed_time * speed + (effect.index / span)) * 0.5 + 0.5
	data.color.a = alpha
	
func update_pulse(data, effect_id, delta):
	var effect = data.effects[effect_id]
	effect.elapsed_time += delta
	var sined_time = (sin(effect.elapsed_time *
		effect.parameters.freq + 1.0)) / 1.0
	var color = effect.parameters.color
	if !effect.parameters.has("original_color"):
		effect.parameters["original_color"] = data.color
	data.color = effect.parameters["original_color"].linear_interpolate(
		color, sined_time)

func update_matrix(data, effect_id, delta):
	if !data.has("text"): return
	var value = ord(data.text)
	var effect = data.effects[effect_id]
	if value < 65 or value >= 126:
		data.effects.erase(effect)
		return
	effect.elapsed_time += delta
	var clear_time = effect.parameters.clean
	var dirty_time = effect.parameters.dirty
	var text_span = effect.parameters.span
	var matrix_time = fmod(effect.elapsed_time + (effect.index /
		float(text_span)), clear_time + dirty_time + 0.00001)
	matrix_time = 0.0 if matrix_time < clear_time else \
		(matrix_time - clear_time) / dirty_time
	if value >= 65 && value < 126 && matrix_time > 0.85:
		var v = value
		value -= 65
		value = value + int(1 * matrix_time * (126 - 65))
		value %= (126 - 65)
		value += 65
	data.text = char(value)

func update_fade_animation(data, effect_id, delta):
	var effect = data.effects[effect_id]
	effect.elapsed_time += delta
	var total_time = effect.parameters.time
	var alpha
	if effect.parameters.mode == 0:
		alpha = min(1.0, effect.elapsed_time / total_time)
	else:
		alpha = max(0, (1 - effect.elapsed_time / total_time))
	data.color.a = alpha

func update_zoom_animation(data, effect_id, delta):
	var effect = data.effects[effect_id]
	effect.elapsed_time += delta
	if !effect.parameters.has("mod"):
		effect.parameters["mod"] = (effect.parameters.end - 
			effect.parameters.start) / (effect.parameters.time * 60)
		effect.parameters["current_zoom"] = effect.parameters.start
		if effect.parameters.start > effect.parameters.end:
			effect.parameters["direction"] = 1
		else:
			effect.parameters["direction"] = -1
		effect.parameters["current_loop"] = 0
		data.zoom = effect.parameters.start
	else:
		if (effect.parameters["direction"] == 1 and
			effect.parameters["current_zoom"] > effect.parameters.end) or \
			(effect.parameters["direction"] == -1 and
			effect.parameters["current_zoom"] < effect.parameters.end):
			effect.parameters["current_zoom"] += effect.parameters["mod"]
		else:
			effect.parameters["current_zoom"] = effect.parameters.end
			if effect.parameters.loop == 0 or effect.parameters.loop > 1:
				var infinite = effect.parameters.loop == 0
				if !infinite:
					effect.parameters.current_loop += 1
				var end_value = effect.parameters.end
				effect.parameters.end = effect.parameters.start
				effect.parameters.start = end_value
				effect.parameters["mod"] = (effect.parameters.end - 
					effect.parameters.start) / (effect.parameters.time * 60)
				effect.parameters["current_zoom"] = effect.parameters.start
				effect.parameters["direction"] *= -1
				if !infinite and effect.parameters.current_loop >= effect.parameters.loop:
					effect.parameters.loop = -1
	data.zoom = effect.parameters["current_zoom"]

func update_angle_animation(data, effect_id, delta):
	var effect = data.effects[effect_id]
	effect.elapsed_time += delta
	if !effect.parameters.has("mod"):
		effect.parameters["mod"] = (effect.parameters.end - 
			effect.parameters.start) / (effect.parameters.time * 60)
		effect.parameters["current_angle"] = effect.parameters.start
		if effect.parameters.start > effect.parameters.end:
			effect.parameters["direction"] = 1
		else:
			effect.parameters["direction"] = -1
		effect.parameters["current_loop"] = 0
		data.angle = effect.parameters.start
	else:
		if (effect.parameters["direction"] == 1 and
			effect.parameters["current_angle"] > effect.parameters.end) or \
			(effect.parameters["direction"] == -1 and
			effect.parameters["current_angle"] < effect.parameters.end):
			effect.parameters["current_angle"] += effect.parameters["mod"]
		else:
			effect.parameters["current_angle"] = effect.parameters.end
			if effect.parameters.loop == 0 or effect.parameters.loop > 1:
				var infinite = effect.parameters.loop == 0
				if !infinite:
					effect.parameters.current_loop += 1
				var end_value = effect.parameters.end
				effect.parameters.end = effect.parameters.start
				effect.parameters.start = end_value
				effect.parameters["mod"] = (effect.parameters.end - 
					effect.parameters.start) / (effect.parameters.time * 60)
				effect.parameters["current_angle"] = effect.parameters.start
				effect.parameters["direction"] *= -1
				if !infinite and effect.parameters.current_loop >= \
					effect.parameters.loop:
					effect.parameters.loop = -1
	data.angle = effect.parameters["current_angle"]

func start():
	if !Engine.editor_hint and !readonly and !is_in_editor:
		if pause_game: get_tree().paused = true
	line_data.current_page = 0
	line_data.current_line = 1
	line_data.current_char = 1
	line_data.completed = false
	line_data.next_page = false
	line_data.delay = 0
	x = 0
	var main = get_parent().get_parent().get_parent().get_parent()
	if appearance_animation_id == 0: # Fade In
		var tween : Tween = main.find_node("TweenNode")
		tween.interpolate_property(main, "modulate", main.modulate,
			Color(1,1,1,1), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
	else: # Instant
		main.modulate.a = 1
	running = true
	if readonly:
		main.visible = true
	set_process(true)

func stop():
	running = false
	set_process(false)
	var main = get_parent().get_parent().get_parent().get_parent()
	if disappearance_animation_id == 0: # Fade Out
		var tween : Tween = main.find_node("TweenNode")
		tween.interpolate_property(main, "modulate", main.modulate,
			Color(1,1,1,0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
	else: # Instant
		main.modulate.a = 0
	clear(true)
	yield(self, "text_cleared")
	yield(get_tree(), "idle_frame")
	if pause_game: get_tree().paused = false


func display_current_page(delta):
	if !running or line_data.completed: return
	var page = line_data.current_page
	if page > characters_stack.size() - 1:
		line_data.delay = 0.1
		line_data.completed = true
		display_last_page()
		return
	for line in range(line_data.current_line-1, characters_stack[page].size()):
		if waiting: break
		for i in range(line_data.current_char-1, characters_stack[page][line].size()):
			var chr = characters_stack[page][line][i]
			if chr is Dictionary and chr.type != "text" and chr.name == "pause":
				line_data.current_line = line
				line_data.current_char = i
				set("waiting", true)
				break
	if !waiting:
		line_data.current_line = characters_stack[page].size()
		line_data.current_char = characters_stack[page][-1].size()
		line_data.next_page = true
		set("waiting", true)
	update_effects(delta)
	update()

func display_last_page():
	var page = characters_stack.size() - 1
	if page < 0: return
	line_data.current_page = page
	line_data.current_line = characters_stack[page].size()
	line_data.current_char = characters_stack[page][-1].size()
	force_process = true
	update_effects(get_process_delta_time())
	update()

func get_next_message():
	running = false
	yield(get_tree(),"idle_frame")
	line_data.completed = false
	if parent != null:
		emit_signal("all_text_shown")
		#print("get next message")

func recalculate_positions():
	return # TO DO
	running = false
	x = 0
	y = 0
	var new_characters_stack = [[]]
	var new_lines_width = []
	lines_height = []
	line_width = 0
	line_height = 0
	var size = rect_size - Vector2(12, 12)
	for line in characters_stack.size():
		for obj in characters_stack[line]:
			if obj.type == "text" or obj.type == "img":
				line_height = max(obj.size.y, line_height)
				if x + obj.size.x >= size.x:
					x = 0
					y += line_height
					lines_height.append(line_height)
					new_lines_width.append(lines_width[line])
					line_height = 0
					line_width = 0
					new_characters_stack.append([])
				else:
					x += size.x
					line_width = x 
				obj.position = Vector2(x, y)
			elif obj.type == "effect" and obj.name == "pagebreak":
				x = 0; y = 0;
				lines_height.append(line_height)
				new_lines_width.append(lines_width[line])
				line_height = 0
				line_width = 0
			new_characters_stack[-1].append(obj)
		new_characters_stack.append([])
	if line_height != 0: lines_height.append(line_height)
	if line_width != 0: new_lines_width.append(lines_width[-1])
	characters_stack = new_characters_stack
	lines_width = new_lines_width
	running = true

func _process(delta: float) -> void:
	if !visible: return
	if force_process and !line_data.completed:
		update_effects(delta)
		update()
		return
	if line_data.completed:
		if !waiting and line_data.delay <= 0:
			#print("MESSAGE COMPLETED")
			get_next_message()
		if line_data.delay > 0:
			line_data.delay -= delta
		update_effects(delta)
		update()
		return
	if !running:
		return
	if waittime > 0:
		update_wait_time(delta)
		return
	if !waiting:
		if letter_by_letter:
			get_next_character(delta)
		else:
			display_current_page(delta)
	update_effects(delta)
	update()


func update_wait_time(delta):
	waittime -= delta
	if waittime <= 0:
		waittime = 0
		if autocontinue:
			autocontinue = false
			set("waiting", false)
		else:
			var main_node = get_parent().get_parent().get_parent().get_parent()
			main_node.find_node("ResumeButton").visible = true
	update_effects(delta)
	update()

func resume():
	wait_for_resume = false
	resumed = true

func get_next_character(delta):
	if wait_for_resume: return
	if !waiting:
		if line_data.current_page > characters_stack.size() - 1:
			line_data.delay = 0.1
			line_data.completed = true
			display_last_page()
			return
		x += delta
		if x >= delay_beetween_characters:
			var c = characters_stack
			var l = line_data
			x = 0
			l.current_char += 1
 			if l.current_char > c[l.current_page][l.current_line-1].size():
				l.current_char = 0
				l.current_line += 1
				if l.current_line > c[l.current_page].size():
					l.current_line = c[l.current_page].size() - 1
					l.current_char = c[l.current_page][l.current_line].size()
					l.current_line += 1
					l.next_page = true
					set("waiting", true)
			var main_node = get_parent().get_parent().get_parent().get_parent()
			var begin_path = folders.sounds if folders != null else ""
			var sound = get_cache_data(begin_path + letter_by_letter_fx)
			if sound != null:
				var sound_player = main_node.find_node("AudioStreamPlayer1")
				sound_player.stream = sound
				sound_player.play()

func _input(event: InputEvent) -> void:
	if !visible: return
	if !waiting:
		if letter_by_letter and letter_by_letter_fast_display:
			if parent == null:
				if event is InputEventMouseButton and \
					event.button_index == BUTTON_LEFT and event.is_pressed():
					display_current_page(0)
			elif input_actions != null:
				for action in input_actions.resume_actions:
					if Input.is_action_just_pressed(action):
						display_current_page(0)
		return
	if waittime > 0: return
	if parent == null:
		if event is InputEventMouseButton and \
			event.button_index == BUTTON_LEFT and event.is_pressed():
			set("waiting", false)
	elif input_actions != null:
		for action in input_actions.resume_actions:
			if Input.is_action_just_pressed(action):
				set("waiting", false)

func _on_Control_draw() -> void:
	if lines_height.size() == 0: return
	if line_data.current_page > characters_stack.size() - 1: return
	if !force_process and (!running or line_data.completed): return
	var text = ""
	var matrix = Transform2D()
	var current_page = characters_stack[line_data.current_page]
	var current_line = min(line_data.current_line, current_page.size())
	for line in range(0, current_line):
		if !running and !force_process: return
		if line > current_page.size(): return
		var max_char
		if line < current_line - 1:
			max_char = current_page[line].size()
		else:
			max_char = min(line_data.current_char, current_page[line].size())
		for i in range(0, max_char):
			var data = current_page[line][i]
			if data.type == "effect" and data.has("parameters"):
				if data.parameters.process:
					running = false
					process_inmediate_effect(data)
					running = true
					if !waiting: return
				continue
			var z = data.zoom
			var text_pos = data.position + data.offset
			text_pos.y += lines_height[line]
			for offset in data.fx_offset.values():
				text_pos += offset
			var rot = deg2rad(data.angle)
			var mod_pos
			match data.align:
				"center": mod_pos = rect_size.x * 0.5 - lines_width[line] * 0.5
				"right": mod_pos = rect_size.x - lines_width[line]
				_: mod_pos = 0 # # Default Left align
			matrix.x.x = cos(rot) * z
			matrix.y.y = matrix.x.x
			matrix.x.y = sin(rot) * z
			matrix.y.x = -matrix.x.y
			matrix.origin = text_pos + Vector2(mod_pos, 0)
			draw_set_transform_matrix(matrix)
			if data.type == "img":
				var img = get_cache_data(data.img)
				var s = data.size * z
				if data.flip:
					s.x *= -1
				var rect = Rect2(Vector2(), s)
				draw_texture_rect(img, rect, false, data.color)
			else:
				text = data.text
				var font = get_cache_font(data.font)
				if font != null:
					if !resumed or true:
						draw_char(font, Vector2(), text, "", data.color)
					else:
						draw_char(font, Vector2(0, data.size.y),
							text, "", data.color)
				if data.underline:
					if !resumed or true:
						draw_line(Vector2(0, 0),
							Vector2(data.size.x, 0), data.color)
					else:
						draw_line(Vector2(0, data.size.y),
							Vector2(data.size.x, data.size.y), data.color)
				if data.strike:
					var y = -data.size.y * 0.25
					if !resumed or true:
						draw_line(Vector2(0, y),
							Vector2(data.size.x, y), data.color)
					else:
						draw_line(Vector2(0, y + data.size.y),
							Vector2(data.size.x, y + data.size.y), data.color)
