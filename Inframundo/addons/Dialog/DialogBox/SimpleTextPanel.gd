tool
extends MarginContainer

var id
var action = true
var folders = null

var animation = {
	"current_frame"	: Vector2(0, 0),
	"max_frames"	: Vector2(1, 1),
	"delay"			: 0,
	"time"			: 0
}

signal text_changed()

func set_data_text(data):
	var node1 = find_node("TextLabel")
	if node1 == null: return
	if !data.fit_width:
		node1.rect_size = Vector2()
		rect_clip_content = false
	else:
		node1.rect_size = data.size - Vector2(data.text_margins.left - 
			data.text_margins.right, 0)
		rect_size = data.size
		find_node("Background").rect_size = data.size
		rect_clip_content = true
	var parent = get_tree().get_nodes_in_group("message_box_main_node")
	if parent.size() > 0:
		var font
		if folders != null:
			font = parent[0].get_cache_font(folders.fonts + data.font)
		else:
			font = parent[0].get_cache_font(data.font)
		node1.set("custom_fonts/font", font)
	node1.set("custom_colors/font_color", data.color)
	node1.set("custom_constants/margin_left", data.text_margins.left)
	node1.set("custom_constants/margin_right", data.text_margins.right)
	node1.set("custom_constants/margin_top", data.text_margins.top)
	node1.set("custom_constants/margin_bottom", data.text_margins.bottom)
	node1.align = data.align
	set("custom_constants/margin_left", data.parent_margins.left)
	set("custom_constants/margin_right", data.parent_margins.right)
	set("custom_constants/margin_top", data.parent_margins.top)
	set("custom_constants/margin_bottom", data.parent_margins.bottom)

func set_image_data(data):
	var obj = find_node("Background")
	var message_box = get_tree().get_nodes_in_group("message_box_main_node")[0]
	var initial_path = message_box.folders.graphics if \
		message_box.folders != null else ""
	if data.image == null:
		obj.texture = null
	else:
		obj.texture = message_box.get_cache_data(initial_path + data.image)
	obj.patch_margin_left = data.patch_margin_left
	obj.patch_margin_right = data.patch_margin_right
	obj.patch_margin_top = data.patch_margin_top
	obj.patch_margin_bottom = data.patch_margin_bottom
	obj.axis_stretch_horizontal = data.axis_stretch_horizontal
	obj.axis_stretch_vertical = data.axis_stretch_vertical
	obj.draw_center = data.draw_center
	obj.modulate = data.color
	animation.max_frames = data.frames
	animation.delay = data.delay
	if obj.texture != null:
		var s = obj.texture.get_data().get_size() / animation.max_frames
		obj.region_rect.size = s
		obj.region_rect.position = Vector2()

func set_text(text):
	var node1 = find_node("TextLabel")
	if node1 == null: return
	node1.text = ""
	yield(get_tree(), "idle_frame")
	update_size()
	node1.text = text
	yield(get_tree(), "idle_frame")
	update_size()
	emit_signal("text_changed")

func get_text_node():
	return find_node("TextLabel")

func update_size() -> void:
	var node1 = find_node("TextLabel")
	var node2 = find_node("MarginContainer")
	if node1 != null:
		if !node1.clip_text:
			var font = node1.get("custom_fonts/font")
			var size = font.get_string_size(node1.text)
			size.x += node2.get("custom_constants/margin_left") + \
				node2.get("custom_constants/margin_right")
			size.y += node2.get("custom_constants/margin_top") + \
				node2.get("custom_constants/margin_bottom")
			propagate_call("set_size", [size], true)
			node1.rect_size = font.get_string_size(node1.text)
			node2.rect_size = rect_size

func fade(alpha):
	var from = modulate
	var to = Color(1,1,1,alpha)
	var node = find_node("Tween")
	visible = true
	node.remove_all()
	node.interpolate_property(self, "modulate", from, to, 0.2,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	node.start()

func _process(delta: float) -> void:
	if animation.max_frames != Vector2.ONE:
		if animation.time < animation.delay:
			animation.time += delta
		else:
			animation.time = 0
			var obj = find_node("Background")
			if obj.texture == null: return
			animation.current_frame.x += 1
			if animation.current_frame.x >= animation.max_frames.x:
				animation.current_frame.x = 0
				animation.current_frame.y += 1
				if animation.current_frame.y >= animation.max_frames.y:
					animation.current_frame.y = 0
			obj.region_rect.position = obj.region_rect.size * animation.current_frame

