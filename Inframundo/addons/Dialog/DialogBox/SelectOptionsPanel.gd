tool
extends NinePatchRect

onready var answer_panel = preload("res://addons/Dialog/DialogBox/SimpleTextPanel.tscn")

var folders = null
var fit = true
var answer_panel_config = {}
var ok_fx
var cursor_fx
var vertical_separation = 4
var position
var offset = Vector2()
var running = false
var index = 0
var last_index = 0
var delay_keys = 0
var cursors = {
	"selected"		: null,
	"no_selected"	: null,
}
var show_indicators = {
	"up"	: false,
	"down"	: false
}

var action_keys

signal request_play_audio(path)
signal item_selected(index)

func set_config(data):
	fit = data.fit_width
	rect_clip_content = !data.fit_width
	rect_size = data.size
	ok_fx = data.ok_fx
	cursor_fx = data.cursor_fx
	position = data.position
	vertical_separation = data.vertical_separation
	offset = data.offset
	var messageBox = get_tree().get_nodes_in_group("message_box_main_node")
	if messageBox != null:
		messageBox = messageBox[0]
		answer_panel_config.text_font = messageBox.get_cache_font(data.font)
		answer_panel_config.text_color = data.color
		answer_panel_config.text_align = data.align
		answer_panel_config.margins = data.text_margins
#		print(answer_panel_config)
#	print(data.keys())

func set_images_config(data1, data2):
	var obj = find_node("PageIndicatorUp")
	set_image_in(obj, data2.page_indicator)
	obj = find_node("PageIndicatorDown")
	set_image_in(obj, data2.page_indicator, true)
	cursors.selected = data2.selected
	cursors.no_selected = data2.no_selected

func set_image_in(node, data, vertical_flip = false):
	var messageBox = get_tree().get_nodes_in_group("message_box_main_node")
	if messageBox == null:
		node.texture = null
		return
	messageBox = messageBox[0]
	if data.image != null and data.image != "":
			var path
			if folders != null:
				path = folders.graphics + data.image
			else:
				path = data.image
			node.texture = messageBox.get_cache_data(path)
			if node.texture != null:
				var size = node.texture.get_data().get_size() / data.frames
				if data.auto_size:
					node.scale = Vector2.ONE
				else:
					node.scale = data.size / size
				size *= node.scale
				if vertical_flip:
					node.scale.y *= -1
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


func add_answer(text):
	if answer_panel == null:
		load("res://addons/Dialog/DialogBox/SimpleTextPanel.tscn")
	var panel = answer_panel.instance()
	find_node("OptionsContainer").add_child(panel)
	panel.modulate.a = 1
	var text_node = panel.get_text_node()
	if answer_panel_config.size() > 0:
		text_node.set("custom_fonts/font", answer_panel_config.text_font)
		text_node.set("custom_colors/font_color", answer_panel_config.text_color)
		var align
		match answer_panel_config.text_align:
			0: Label.ALIGN_LEFT
			1: Label.ALIGN_CENTER
			2: Label.ALIGN_RIGHT
		text_node.set("align", align)
		text_node.set("custom_constants/margin_left",
			answer_panel_config.margins.left)
		text_node.set("custom_constants/margin_right",
			answer_panel_config.margins.right)
		text_node.set("custom_constants/margin_top",
			answer_panel_config.margins.top)
		text_node.set("custom_constants/margin_bottom",
			answer_panel_config.margins.bottom)
	if !fit:
		text_node.rect_size = Vector2()
	else:
		var margins = find_node("OptionsMarginContainer")
		text_node.rect_size = rect_size - Vector2(
			margins.get("custom_constants/margin_left") - 
			margins.get("custom_constants/margin_right"), 0)
	panel.set_text(str(text))

func clear():
	var node = find_node("OptionsContainer")
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
	modulate.a = 0
	visible = false
	running = false
	last_index = 0

func start():
	var c = find_node("OptionsContainer")
	if c == null or c.get_child_count() == 0: return
	modulate.a = 0
	visible = true
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if fit:
		var w = 0
		var y = 0
		for i in c.get_children().size():
			var child = c.get_child(i)
			child.rect_position.y = y
			w = max(w, child.rect_size.x)
			y += child.rect_size.y + vertical_separation
		for child in c.get_children():
			child.rect_size.x = w
		var margins = find_node("OptionsMarginContainer")
		w += margins.get("custom_constants/margin_left") + \
			margins.get("custom_constants/margin_right")
		y += margins.get("custom_constants/margin_top") + \
			margins.get("custom_constants/margin_bottom")
		rect_size = Vector2(w, rect_size.y - 2)
	rect_position = Vector2()
	if position != null:
		var message_box = get_tree().get_nodes_in_group("main_message_node")
		if message_box.size() > 0:
			message_box = message_box[0]
			match position:
				0: # Corner Top Left
					rect_position = Vector2(0, -rect_size.y)
				1: # Top
					rect_position = Vector2(message_box.rect_size.x * 0.5 -
						rect_size.x * 0.5, -rect_size.y)
				2: # Corner Top Right
					rect_position = Vector2(message_box.rect_size.x -
						rect_size.x, -rect_size.y)
				3: # Left
					rect_position = Vector2(0,
						message_box.rect_size.y * 0.5 - rect_size.y * 0.5)
				4: # Right
					rect_position = Vector2(message_box.rect_size.x -
						rect_size.x,
						message_box.rect_size.y * 0.5 - rect_size.y * 0.5)
				5: # Corner Bottom Left
					rect_position = Vector2(0, message_box.rect_size.y -
						rect_size.y)
				6: # Bottom
					rect_position = Vector2(message_box.rect_size.x * 0.5 -
						rect_size.x * 0.5,
						message_box.rect_size.y - rect_size.y)
				7: # Corner Bottom Right
					rect_position = Vector2(message_box.rect_size.x -
						rect_size.x,
						message_box.rect_size.y - rect_size.y)
						
	rect_position += offset
	var cursor = find_node("Cursor")
	if cursor.texture != null:
		c = c.get_child(0)
		cursor.position.y = c.rect_size.y * 0.5 + \
			(cursor.texture.get_data().get_size() * cursor.scale * 0.25).y
	running = true
	index = 0
	delay_keys = 0
	var node = find_node("OptionsContainer")
	if node.get_child_count() > 0:
		if cursors.no_selected != null:
			for i in range(1, node.get_child_count()):
				var child = node.get_child(i)
				child.set_image_data(cursors.no_selected)
		if cursors.selected != null:
			var child = node.get_child(0)
			child.set_image_data(cursors.selected)
	node = find_node("PageIndicatorUp")
	if node.texture != null:
		node.position.x = rect_size.x * 0.5
	node = find_node("PageIndicatorDown")
	if node.texture != null:
		node.position.x = rect_size.x * 0.5
		node.position.y = rect_size.y
	update_cursor()

func change_index(value):
	index += value
	delay_keys = 0.15
	update_cursor()
	emit_signal("request_play_audio", cursor_fx, 6)


func _process(delta: float) -> void:
	if !visible: return
	if running:
		if modulate.a < 1:
			modulate.a = lerp(modulate.a, 1.0, 0.02)
		if delay_keys > 0:
			delay_keys -= delta
			return
		if !Engine.editor_hint:
			if action_keys != null:
				for action in action_keys.resume_actions:
					if Input.is_action_just_pressed(action):
						emit_signal("request_play_audio", ok_fx)
						for i in 3:
							yield(get_tree(), "idle_frame")
						emit_signal("item_selected", index)
						running = false
						return
				for action in action_keys.up_actions:
					if Input.is_action_pressed(action):
						change_index(-1)
						break
				if delay_keys <= 0:
					for action in action_keys.down_actions:
						if Input.is_action_pressed("ui_down"):
							change_index(1)
						break
			else:
				if Input.is_action_pressed("ui_up"):
					change_index(-1)
				elif Input.is_action_pressed("ui_down"):
					change_index(1)
	else:
		if modulate.a > 0: modulate.a = lerp(modulate.a, 0.0, 0.02)

func update_cursor():
	var margins = find_node("MarginContainer")
	var cursor = find_node("Cursor")
	var c = find_node("OptionsContainer")
	if index < 0: index = c.get_child_count() - 1
	elif index >  c.get_child_count() - 1: index = 0
	if cursor.texture == null: return
	var c2 = c.get_child(index)
	var h = cursor.texture.get_data().get_size().y * cursor.scale.y
	cursor.position.y = c2.rect_position.y + c2.rect_size.y * 0.5 + \
		(cursor.texture.get_data().get_size() * cursor.scale * 0.25).y + \
		margins.get("custom_constants/margin_top")
	var node = c.get_child(index)
	var my = margins.get("custom_constants/margin_top")
	if node.rect_size.y + node.rect_position.y + my > margins.rect_size.y:
		var y = 0
		var v = node.rect_size.y + node.rect_position.y + my
		while v > margins.rect_size.y - 12:
			v -= 1
			y += 1
		cursor.position.y -= y
		margins.set("custom_constants/margin_top", my - y)
	elif node.rect_position.y + my < 0:
		var y = 0
		var v = node.rect_position.y + my
		while v < 0:
			v += 1
			y -= 1
		cursor.position.y -= y
		margins.set("custom_constants/margin_top", my - y)
	node = find_node("OptionsContainer")
	if cursors.no_selected != null:
		var obj = node.get_child(last_index)
		obj.set_image_data(cursors.no_selected)
	if cursors.selected != null:
		var obj = node.get_child(index)
		obj.set_image_data(cursors.selected)
	last_index = index
	var node2 = find_node("PageIndicatorUp")
	node2.visible = margins.get("custom_constants/margin_top") < 0 and \
		 index != 0
	node2 = find_node("PageIndicatorDown")
	var node3 = node.get_child(node.get_child_count() - 1)
	node2.visible = node3.rect_position.y + node3.rect_size.y > \
		margins.rect_size.y and index != node.get_child_count() - 1

