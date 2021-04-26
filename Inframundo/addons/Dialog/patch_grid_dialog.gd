extends Control

var drags = {
	"left"		: false,
	"right"		: false,
	"top"		: false,
	"bottom"	: false
}

var values = {
	"left"		: 0,
	"right"		: 0,
	"top"		: 0,
	"bottom"	: 0,
	"min"		: 0,
	"max"		: 0
}

var zoom = 1.0
var spinbox_action = true
var rect_width = 22

func _ready() -> void:
	var spinboxes = [1, 2, 3, 4]
	for i in spinboxes:
		var node = find_node("SpinBox%s" % i)
		var lineedit = node.get_line_edit()
		lineedit.caret_blink = true
		lineedit.connect("focus_exited", self, "update_lines")
		node.connect("value_changed", self, "update_values")
	resize_background()
	center()
	fix_lines()
	fix_lines_by_offsets()

func resize_background():
	var node = find_node("Background")
	node.rect_size = node.get_parent().rect_size * 2

func center():
	var node = find_node("Image")
	node.rect_position = rect_size * 0.5 - node.rect_size * 0.25
	fix_lines_by_offsets()

func set_margin_values():
	var node = find_node("Image")
	var pos = node.rect_global_position
	var img_size = node.texture.get_data().get_size()
	var p1 = find_node("LeftLine").rect_position.x
	var p2 = find_node("RightLine").rect_position.x
	var p3 = find_node("TopLine").rect_position.y
	var p4 = find_node("BottomLine").rect_position.y
	values.left = -(pos.x - p1) / zoom
	values.right = -(pos.x - p2) / zoom
	values.top = -(pos.y - p3) / zoom
	values.bottom = -(pos.y - p4) / zoom
	spinbox_action = false
	find_node("SpinBox1").value = values.left
	find_node("SpinBox2").value = values.right
	find_node("SpinBox3").value = values.top
	find_node("SpinBox4").value = values.bottom
	spinbox_action = true

func get_values():
	find_node("SpinBox1").apply()
	find_node("SpinBox2").apply()
	find_node("SpinBox3").apply()
	find_node("SpinBox4").apply()
	return values

func _on_PatchGridDialog_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			find_node("SpinBox5").value = zoom + 0.1
		elif event.button_index == BUTTON_WHEEL_DOWN:
			find_node("SpinBox5").value = max(1, zoom - 0.2)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and \
		Input.is_mouse_button_pressed(BUTTON_MIDDLE):
		var node = find_node("Image")
		var displacement =  event.relative #/ zoom
		node.rect_global_position += displacement
		node = find_node("Background")
		var node2 = find_node("ImageContainer")
		node.rect_position = (node.rect_position + displacement / zoom)
		if node.rect_position.x < -node2.rect_size.x:
			node.rect_position.x += node2.rect_size.x
		elif node.rect_position.x > 0:
			node.rect_position.x -= node2.rect_size.x
		if node.rect_position.y < -node2.rect_size.y:
			node.rect_position.y += node2.rect_size.y
		elif node.rect_position.y > 0:
			node.rect_position.y -= node2.rect_size.y
		fix_lines_by_offsets()

func _on_ImageContainer_item_rect_changed() -> void:
	var node = find_node("ImageContainer")
	var offset = node.get_global_rect().size * 0.5
	find_node("ImageContainer").rect_pivot_offset = offset
	var node2 = find_node("Background")
	node2.rect_size = node.rect_size * 2
	
func fix_lines():
	var node = find_node("Image")
	var img_size = node.get_global_rect().size
	values.left = 0
	values.right = 0
	values.top = 0
	values.bottom = 0
	values.max = img_size * 0.5
	spinbox_action = false
	find_node("SpinBox1").value = values.left
	find_node("SpinBox2").value = values.right
	find_node("SpinBox3").value = values.top
	find_node("SpinBox4").value = values.bottom
	spinbox_action = true
	fix_lines_by_offsets()

func fix_lines_by_offsets():
	var node = find_node("Image")
	if node.texture == null: return
	var pos = node.rect_global_position
	var size = node.texture.get_data().get_size() * zoom
	find_node("LeftLine").rect_global_position.x = \
		pos.x + values.left * zoom - rect_width
	find_node("RightLine").rect_global_position.x = \
		pos.x + size.x - values.right * zoom
	find_node("TopLine").rect_global_position.y = \
		pos.y + values.top * zoom - rect_width
	find_node("BottomLine").rect_global_position.y = \
		pos.y + size.y - values.bottom * zoom
	node.patch_margin_left = values.left
	node.patch_margin_right = values.right
	node.patch_margin_top = values.top
	node.patch_margin_bottom = values.bottom


func _on_PatchGridDialog_item_rect_changed() -> void:
	var node = find_node("Image")
	if node == null: return
	var size = node.texture.get_data().get_size()
	node.rect_position = get_parent().rect_size * 0.5 - size * 0.5
	node = find_node("Background")
	node.rect_size =  find_node("ImageContainer").rect_size * 2
	yield(get_tree(), "idle_frame")
	fix_lines_by_offsets()
	
func update_lines():
	spinbox_action = false
	find_node("SpinBox1").apply()
	find_node("SpinBox2").apply()
	find_node("SpinBox3").apply()
	find_node("SpinBox4").apply()
	spinbox_action = true
	update_values(0)


func update_values(value: float) -> void:
	if !spinbox_action: return
	var s = values.max
	var left = find_node("SpinBox1")
	var right = find_node("SpinBox2")
	var top = find_node("SpinBox3")
	var bottom = find_node("SpinBox4")
	values.left = left.value
	values.right = right.value
	values.top = top.value
	values.bottom = bottom.value
	if values.left < 0: values.left = 0
	elif values.left > s.x - values.right: values.left = s.x - values.right
	if s.x - values.right < values.left: values.right = s.x - values.left
	elif values.right > s.x: values.right = s.x
	if values.top < 0: values.top = 0
	elif values.top > s.y - values.bottom: values.top = s.y - values.bottom
	if s.y - values.bottom < values.top: values.bottom = s.y - values.top
	elif values.bottom > s.y: values.bottom = s.y
	spinbox_action = false
	left.value = values.left
	right.value = values.right
	top.value = values.top
	bottom.value = values.bottom
	spinbox_action = true
	fix_lines_by_offsets()


func _on_LeftLine_focus_entered() -> void:
	var node = find_node("Margins")
	var child = find_node("LeftLine")
	node.move_child(child, 3)


func _on_RightLine_focus_entered() -> void:
	var node = find_node("Margins")
	var child = find_node("RightLine")
	node.move_child(child, 3)


func _on_BottomLine_focus_entered() -> void:
	var node = find_node("Margins")
	var child = find_node("TopLine")
	node.move_child(child, 3)


func _on_TopLine_focus_entered() -> void:
	var node = find_node("Margins")
	var child = find_node("BottomLine")
	node.move_child(child, 3)

func _process(delta: float) -> void:
	if drags.left or drags.right or drags.top or drags.bottom:
		if !Input.is_mouse_button_pressed(BUTTON_LEFT):
			drags.left = false
			drags.right = false
			drags.top = false
			drags.bottom = false
			update()

func update_left_position(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drags.left = event.is_pressed()
	elif event is InputEventMouseMotion and drags.left:
		var node = find_node("Image")
		var pos = node.rect_global_position
		var value1 = (get_global_mouse_position().x - pos.x) / zoom
		var value2 = values.max.x - values.right
		values.left = max(0, min(value1, value2))
		fix_lines_by_offsets()
		spinbox_action = false
		find_node("SpinBox1").value = values.left
		spinbox_action = true

func update_right_position(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drags.right = event.is_pressed()
	elif event is InputEventMouseMotion and drags.right:
		var node = find_node("Image")
		var pos = node.rect_global_position
		var img_size = node.texture.get_data().get_size()
		var m = get_global_mouse_position()
		values.right = img_size.x - max(values.left * zoom,
			min(m.x - pos.x, img_size.x * zoom)) / zoom
		fix_lines_by_offsets()
		spinbox_action = false
		find_node("SpinBox2").value = values.right
		spinbox_action = true

func update_top_position(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drags.top = event.is_pressed()
	elif event is InputEventMouseMotion and drags.top:
		var node = find_node("Image")
		var pos = node.rect_global_position
		var value1 = (get_global_mouse_position().y - pos.y) / zoom
		var value2 = values.max.y - values.bottom
		values.top = max(0, min(value1, value2))
		fix_lines_by_offsets()
		spinbox_action = false
		find_node("SpinBox3").value = values.top
		spinbox_action = true

func update_bottom_position(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drags.bottom = event.is_pressed()
	elif event is InputEventMouseMotion and drags.bottom:
		var node = find_node("Image")
		var pos = node.rect_global_position
		var img_size = node.texture.get_data().get_size()
		var m = get_global_mouse_position()
		values.bottom = img_size.y - max(values.top * zoom,
			min(m.y - pos.y, img_size.y * zoom)) / zoom
		fix_lines_by_offsets()
		spinbox_action = false
		find_node("SpinBox4").value = values.bottom
		spinbox_action = true



func set_image(img, patchs):
	var node = find_node("Image")
	node.texture = img
	var size = img.get_data().get_size()
	node.rect_size = size * 2
	values.max = size
	spinbox_action = false
	find_node("SpinBox1").value = patchs.left.value
	find_node("SpinBox2").value = patchs.right.value
	find_node("SpinBox3").value = patchs.top.value
	find_node("SpinBox4").value = patchs.bottom.value
	spinbox_action = true
	center()
	update_values(0)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	fix_lines_by_offsets()


func _on_zoom_SpinBox_value_changed(value: float) -> void:
	zoom = value
	find_node("ImageContainer").rect_scale = Vector2(zoom, zoom)
	fix_lines_by_offsets()
