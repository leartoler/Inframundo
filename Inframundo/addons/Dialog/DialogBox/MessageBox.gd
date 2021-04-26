tool
extends RichTextLabel

var effects_path = "res://addons/Dialog/TextEffects/"
var stack = {}
var current_line = 0
var CACHE = {}
var use_cache = true
var letter_by_letter_enabled = true
var leter_by_letter_sound
var text_speed = 26
var max_lines = 4
var pause_game = true
var show_animation = null
var hide_animation = null

var images_animation = {}
var current_config = null

func _ready() -> void:
	install_effects()

func install_effects():
	var files = dir_contents(effects_path)
	for file in files:
		var res = ResourceLoader.load(file)
		if res is RichTextEffect:
			install_effect(res)
			if file.get_file() == "pause.tres":
				res.connect("pause", self, "set_pause")
			elif file.get_file() == "page_break.tres":
				res.connect("pagebreak", self, "set_page_break")
			elif file.get_file() == "face.tres":
				res.connect("show_face", self, "set_face_image")
			elif file.get_file() == "character.tres":
				res.connect("show_character", self, "set_character_image")
			elif file.get_file() == "image_effect.tres":
				res.connect("set_image_effect", self, "set_image_effect")
			elif file.get_file() == "remove_image.tres":
				res.connect("remove_image", self, "remove_image")
			elif file.get_file() == "remove_box_name.tres":
				res.connect("remove_box_name", self, "remove_box_name")
			elif file.get_file() == "set_lbl.tres":
				res.connect("set_letter_by_letter", self, "set_letter_by_letter")
			elif file.get_file() == "show_box_name.tres":
				res.connect("show_box_name", self, "show_box_name")
			elif file.get_file() == "emit_signal.tres":
				res.connect("emit_signal_request", self, "emit_signal_request")
			elif file.get_file() == "play_sound.tres":
				res.connect("play_sound", self, "play_sound")
			elif file.get_file() == "show_variable.tres":
				res.connect("show_variable", self, "show_variable")
			elif file.get_file() == "show_term.tres":
				res.connect("show_term", self, "show_term")
			elif file.get_file() == "newline.tres":
				res.connect("newline", self, "add_newline")

func dir_contents(path) -> Array:
	var dir = Directory.new()
	var files = []
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				files.append(path + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the effects path.")
	return files

func apply_font(font_path) -> DynamicFont:
	if use_cache:
		if !CACHE.has(font_path):
			CACHE[font_path] = load(font_path)
		return CACHE[font_path]
	else:
		var font = load(font_path)
		return font

func get_sound(sound_path) -> AudioStream:
	if use_cache:
		if !CACHE.has(sound_path):
			CACHE[sound_path] = load(sound_path)
		return CACHE[sound_path]
	else:
		var sound = load(sound_path)
		return sound

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
	print_data_in_tree(data)
	current_config = data
	set_letter_by_letter_config(data.letter_by_letter)
	set_default_font_config(data.default_font)
	set_default_config(data.dialog_box_config)
	set_left_box_name_config(data.left_box_name_config)
	set_right_box_name_config(data.right_box_name_config)
	set_options_box_config(data.options_box_config)
	set_background_image(data.background_image)
	set_name_box_background_image(data.name_box_background_image)

func set_letter_by_letter_config(data):
	var file = File.new()
	letter_by_letter_enabled = data.enabled
	if data.sound.length() > 0:
		if file.file_exists(data.sound):
			leter_by_letter_sound = load(data.sound)
		else:
			leter_by_letter_sound = null
	else:
		leter_by_letter_sound = null
	text_speed = data.text_speed

func set_default_font_config(data):
	var file = File.new()
	if file.file_exists(data.normal):
		add_font_override("normal_font", apply_font(data.normal))
	if file.file_exists(data.bold):
		add_font_override("bold_font", apply_font(data.bold))
	if file.file_exists(data.italic):
		add_font_override("italics_font", apply_font(data.italic))
	if file.file_exists(data.bold_italic):
		add_font_override("bold_italics_font", apply_font(data.bold_italic))
	add_color_override("default_color", data.color)

func set_default_config(data):
	var screen_size = get_viewport().size
	var node = get_node("../../../..")
	var node2
	if data.fit_width:
		node.anchor_right = 1
		node.rect_min_size.y = data.size.y
	else:
		node.anchor_right = 0
		node.rect_min_size = data.size
	match data.position.type:
		0: # Top of Screen
			node.anchor_top = 0
			node.anchor_bottom = 0
		1: # Mid of Screen
			node.anchor_top = 0.5
			node.anchor_bottom = 0.5
		2: # Bottom of Screen
			node.anchor_top = 1
			node.anchor_bottom = 1
		3: # Custom Position
			node.anchor_top = 0
			node.anchor_bottom = 0
	if data.position.type < 3:
		node.rect_position = Vector2(0, 0)
		node.margin_top = data.parent_margins.top
		node.margin_left = data.parent_margins.left
		node.margin_right = data.parent_margins.right
		node.margin_bottom = data.parent_margins.bottom
	else:
		node.margin_top = 0
		node.margin_left = 0
		node.margin_right = 0
		node.margin_bottom = 0
		node.rect_position = data.position.dest
	max_lines = data.lines_shown
	node2 = node.find_node("Face")
	node2.rect_min_size = data.face_size
	node2.rect_size = node2.rect_min_size
	node2 = node.find_node("MessageMarginContainer")
	node2.set("custom_constants/margin_top",
		data.message_margins.top)
	node2.set("custom_constants/margin_left", 
		data.message_margins.left)
	node2.set("custom_constants/margin_bottom", 
		data.message_margins.bottom)
	node2.set("custom_constants/margin_right", 
		data.message_margins.right)
	node2.get_child(0).set("custom_constants/separation",
		data.face_text_separation)
	pause_game = data.pause_game
	show_animation = data.appearance_animation
	hide_animation = data.disappearance_animation

func set_background_image(data):
	var file = File.new()
	var node = get_node("../../../..")
	var node2 = node.get_node("Dialog")
	images_animation.erase("dialog_background_image")
	if file.file_exists(data.image):
		node2.texture = load(data.image)
		var w = node2.texture.get_data().get_width() / data.frames.x
		var h = node2.texture.get_data().get_height() / data.frames.y
		node2.region_rect = Rect2(0, 0, w, h)
		images_animation["dialog_background_image"] = {
			"image"			: node2,
			"current_frame" : Vector2.ZERO,
			"max_frames"	: data.frames,
			"delay"			: data.delay,
			"time"			: 0,
			"size"			: Vector2(w, h)
		}
	node2.patch_margin_left = data.patch_margin_left
	node2.patch_margin_right = data.patch_margin_right
	node2.patch_margin_top = data.patch_margin_top
	node2.patch_margin_bottom = data.patch_margin_bottom
	node2.axis_stretch_horizontal = data.axis_stretch_horizontal
	node2.axis_stretch_vertical = data.axis_stretch_vertical
	node2.draw_center = data.draw_center
	node2.modulate = data.color

func set_left_box_name_config(data):
	var file = File.new()
	var node = get_node("../../../..")
	var node2 = node.find_node("NameBoxLeft")
	var node3 = node2.find_node("Label")
	if !data.fit_width:
		node3.clip_text = true
		node2.margin_left = 0
		node2.margin_top = 0
		node2.margin_right = data.size.x
		node2.margin_bottom = data.size.y
	else:
		node3.clip_text = false
		node2.margin_right = 0
		node2.margin_top = -data.size.y * 0.5
		node2.margin_bottom = -node2.margin_top
	if file.file_exists(data.font):
		node3.set("custom_fonts/font", apply_font(data.font))
	node3.align = data.align
	node3.set("custom_colors/font_color",
		data.color)
	node2.set("custom_constants/margin_top",
		data.parent_margins.top)
	node2.set("custom_constants/margin_left", 
		data.parent_margins.left)
	node2.set("custom_constants/margin_bottom", 
		data.parent_margins.bottom)
	node2.set("custom_constants/margin_right", 
		data.parent_margins.right)
	node3 = node2.get_child(1)
	node3.set("custom_constants/margin_top",
		data.text_margins.top)
	node3.set("custom_constants/margin_left", 
		data.text_margins.left)
	node3.set("custom_constants/margin_bottom", 
		data.text_margins.bottom)
	node3.set("custom_constants/margin_right", 
		data.text_margins.right)

func set_name_box_background_image(data):
	var file = File.new()
	var node = get_node("../../../..")
	var node2 = node.get_node("NameBoxLeft").get_child(0)
	var node3 = node.get_node("NameBoxRight").get_child(0)
	images_animation.erase("name_box_left_background_image")
	images_animation.erase("name_box_right_background_image")
	if file.file_exists(data.image):
		node2.texture = load(data.image)
		node3.texture = node2.texture
		var w = node2.texture.get_data().get_width() / data.frames.x
		var h = node2.texture.get_data().get_height() / data.frames.y
		node2.region_rect = Rect2(0, 0, w, h)
		node3.region_rect = Rect2(0, 0, w, h)
		images_animation["name_box_left_background_image"] = {
			"image"			: node2,
			"current_frame" : Vector2.ZERO,
			"max_frames"	: data.frames,
			"delay"			: data.delay,
			"time"			: 0,
			"size"			: Vector2(w, h)
		}
		images_animation["name_box_right_background_image"] = \
			images_animation["name_box_left_background_image"].duplicate(true)
		images_animation["name_box_right_background_image"].image = node3
	node2.patch_margin_left = data.patch_margin_left
	node2.patch_margin_right = data.patch_margin_right
	node2.patch_margin_top = data.patch_margin_top
	node2.patch_margin_bottom = data.patch_margin_bottom
	node2.axis_stretch_horizontal = data.axis_stretch_horizontal
	node2.axis_stretch_vertical = data.axis_stretch_vertical
	node2.draw_center = data.draw_center
	node2.modulate = data.color
	node3.patch_margin_left = data.patch_margin_left
	node3.patch_margin_right = data.patch_margin_right
	node3.patch_margin_top = data.patch_margin_top
	node3.patch_margin_bottom = data.patch_margin_bottom
	node3.axis_stretch_horizontal = data.axis_stretch_horizontal
	node3.axis_stretch_vertical = data.axis_stretch_vertical
	node3.draw_center = data.draw_center
	node3.modulate = data.color

func set_right_box_name_config(data):
	var file = File.new()
	var node = get_node("../../../..")
	var node2 = node.find_node("NameBoxRight")
	var node3 = node2.find_node("Label")
	if !data.fit_width:
		node3.clip_text = true
		node2.margin_left = -data.size.x
		node2.margin_top = 0
		node2.margin_right = 0
		node2.margin_bottom = data.size.y
	else:
		node3.clip_text = false
		node2.anchor_left = 1
		node2.anchor_right = 1
		node2.margin_left = -node3.rect_size.x
		node2.margin_right = 0
		node2.margin_top = -data.size.y * 0.5
		node2.margin_bottom = -node2.margin_top
	if file.file_exists(data.font):
		node3.set("custom_fonts/font", apply_font(data.font))
	node3.align = data.align
	node3.set("custom_colors/font_color",
		data.color)
	node2.set("custom_constants/margin_top",
		data.parent_margins.top)
	node2.set("custom_constants/margin_left", 
		data.parent_margins.left)
	node2.set("custom_constants/margin_bottom", 
		data.parent_margins.bottom)
	node2.set("custom_constants/margin_right", 
		data.parent_margins.right)
	node3 = node2.get_child(1)
	node3.set("custom_constants/margin_top",
		data.text_margins.top)
	node3.set("custom_constants/margin_left", 
		data.text_margins.left)
	node3.set("custom_constants/margin_bottom", 
		data.text_margins.bottom)
	node3.set("custom_constants/margin_right", 
		data.text_margins.right)

func set_options_box_config(data):
	return
	var file = File.new()
	var node = get_node("../../../..")
	var node2 = node.find_node("NameBoxRight")
	var node3 = node2.find_node("Label")
	if !data.fit_width:
		node3.clip_text = true
		node2.margin_left = -data.size.x
		node2.margin_top = 0
		node2.margin_right = 0
		node2.margin_bottom = data.size.y
	else:
		node3.clip_text = false
		node2.anchor_left = 1
		node2.anchor_right = 1
		node2.margin_left = -node3.rect_size.x
		node2.margin_right = 0
		node2.margin_top = -data.size.y * 0.5
		node2.margin_bottom = -node2.margin_top
	if file.file_exists(data.font):
		node3.set("custom_fonts/font", apply_font(data.font))
	node3.align = data.align
	node3.set("custom_colors/font_color",
		data.color)
	node2.set("custom_constants/margin_top",
		data.parent_margins.top)
	node2.set("custom_constants/margin_left", 
		data.parent_margins.left)
	node2.set("custom_constants/margin_bottom", 
		data.parent_margins.bottom)
	node2.set("custom_constants/margin_right", 
		data.parent_margins.right)
	node3 = node2.get_child(1)
	node3.set("custom_constants/margin_top",
		data.text_margins.top)
	node3.set("custom_constants/margin_left", 
		data.text_margins.left)
	node3.set("custom_constants/margin_bottom", 
		data.text_margins.bottom)
	node3.set("custom_constants/margin_right", 
		data.text_margins.right)


func set_pause(data):
	stack[int(data.char_index)] = {
		"type"	: "pause",
		"data"	: data
	}

func set_page_break(data):
	stack[int(data.char_index)] = {
		"type"	: "page_break",
		"data"	: data
	}

func set_face_image(data):
	stack[int(data.char_index)] = {
		"type"	: "show_face",
		"data"	: data
	}

func set_character_image(data):
	stack[int(data.char_index)] = {
		"type"	: "show_character_image",
		"data"	: data
	}

func set_image_effect(data):
	stack[int(data.char_index)] = {
		"type"	: "set_image_effect",
		"data"	: data
	}

func remove_image(data):
	stack[int(data.char_index)] = {
		"type"	: "remove_image",
		"data"	: data
	}

func remove_box_name(data):
	stack[int(data.char_index)] = {
		"type"	: "remove_box_name",
		"data"	: data
	}

func set_letter_by_letter(data):
	stack[int(data.char_index)] = {
		"type"	: "set_letter_by_letter",
		"data"	: data
	}

func show_box_name(data):
	stack[int(data.char_index)] = {
		"type"	: "show_box_name",
		"data"	: data
	}
	
func emit_signal_request(data):
	stack[int(data.char_index)] = {
		"type"	: "emit_signal",
		"data"	: data
	}
	
func play_sound(data):
	stack[int(data.char_index)] = {
		"type"	: "play_sound",
		"data"	: data
	}
	
func add_newline(data):
	stack[int(data.char_index)] = {
		"type"	: "newline",
		"data"	: data
	}
	
func show_variable(data):
	print(data)
	
func show_term(data):
	print(data)

func process_effect(id):
	var effect = null
	if stack.has(id):
		effect = stack[id]
		stack.erase(id)
	if effect != null:
		match effect.type:
			"pause":
				pass
			"page_break":
				pass
			"show_face":
				var tex = load(effect.data.img)
				var face = get_parent().find_node("Face")
				face.texture = tex
				face.rect_min_size = Vector2(64, 64)
				face.flip_h = bool(effect.data.flip)
			"show_character_image":
				pass
			"set_image_effect":
				pass
			"remove_image":
				pass
			"remove_box_name":
				pass
			"set_letter_by_letter":
				pass
			"show_box_name":
				pass
			"emit_signal":
				pass
			"play_sound":
				pass
			"newline":
				current_line += 1

func get_current_line():
	return current_line + get_visible_line_count()


func _process(delta: float) -> void:
	for animation in images_animation.values():
		if animation.image.visible:
			if animation.time >= animation.delay:
				animation.current_frame.x += 1
				if animation.current_frame.x >= animation.max_frames.x:
					animation.current_frame.x = 0
					animation.current_frame.y += 1
					if animation.current_frame.y >= animation.max_frames.y:
						animation.current_frame.y = 0
				animation.time = 0
				animation.image.region_rect.position = \
					animation.size * animation.current_frame
			else:
				animation.time += delta

