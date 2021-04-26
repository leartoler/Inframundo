tool
extends PanelContainer
class_name CustomGraphNode


export(bool) var resizable = true
export(bool) var horizontal_resizable = true
export(bool) var vertical_resizable = true
export(Color) var frame_color = Color("3abd04") setget set_frame_color
export(String) var title = "" setget set_title_text
export(int,
	"Left", "Center", "Right") var text_align = "Left" setget set_title_align
export(bool) var show_close_btn = true setget set_close_btn_visibility
export(Array) var slots setget set_dot

var _backup_slots
var connections = []

var content_container;		var dot_container_left;
var dot_container_right;	var top_layer_container;
var title_label; 			var close_button; 			var principal_container;

var dot = preload("CustomNodeDot.tscn")
var remove_dots_timer = 0
var remove_dots_array = []

enum edge {left, top, right, bottom, topl, topr, botl, botr};
var dragging = false
var resizing = false
var target_edge = -1
var cursor_type = -1
var border_size = 10
var last_mouse_position

var focused = false
var id = 0
var collapsed = false
var last_max_y = 0
var yields_active = 0
var resume_data

signal start_move_point(obj_name, dot, graph_node_id)
signal end_move_point(obj_name, dot, graph_node_id)
signal delete_connection_request(obj_name, dot, graph_node_id)
signal resizing(obj_name, coord, size, position)
signal moving(obj_name, position)
signal end_move_and_resizing(obj)
signal on_screen_exited(obj)
signal on_screen_entered(obj)
signal close_request(obj)
signal deselect_all()
signal deselect(obj)
signal collapsed(value)


func _ready() -> void:
	slots = slots.duplicate(true)
	check_slots_integrity()
	update_dots()
	find_node("Timer").connect("timeout", self, "_on_timer_timeout")
	
func check_slots_integrity():
	for i in slots.size():
		var dot_data = slots[i]
		if !dot_data: continue
		var keys = [["dot_left_name", ""], ["left_show", false], ["left_type", 0],
				["left_color", Color.white], ["left_offset", Vector2.ZERO],
				["left_max_connections", 1],
				["dot_right_name", ""], ["right_show", false], ["right_type", 0],
				["right_color", Color.white], ["right_offset", Vector2.ZERO],
				["right_max_connections", 1]]
		for item in keys:
			if !dot_data.has(item[0]): dot_data[item[0]] = item[1]

func set_frame_color(value):
	frame_color = value
	get_stylebox("panel").border_color = frame_color


func set_title_text(value):
	if !title_label: return
	title = value
	if title_label:
		title_label.text = title
	
func set_title_align(value):
	text_align = value
	if title_label:
		title_label.align = text_align
	
func set_close_btn_visibility(value):
	show_close_btn = value
	if close_button:
		close_button.visible = value

func can_be_closed():
	return close_button.visible

func set_initial_variables():
	principal_container =	$VBoxContainer
	content_container 	=	$VBoxContainer/ContentContainer
	dot_container_left	=	$VBoxContainer/DotContainerLeft
	dot_container_right	=	$VBoxContainer/DotContainerRight
	top_layer_container	=	$VBoxContainer/TopContainer
	title_label			=	$VBoxContainer/TopContainer/Title
	close_button		=	$VBoxContainer/TopContainer/CloseButton

func set_dot(value):
	slots = value
	update_dots()

func update_dots():
	if !content_container: return
	if collapsed: return
	for child in dot_container_left.get_children():
		child.queue_free()
	for child in dot_container_right.get_children():
		child.queue_free()
	for i in slots.size():
		var dot_data = slots[i]
		if !dot_data: continue
		var c = content_container.get_child(i)
		if dot_data.left_show:
			var d = create_dot(i, "left", dot_data.left_type,
				dot_data.left_color, dot_data.left_offset,
				dot_data.left_max_connections)
			dot_data.dot_left_name = d.name
		else:
			dot_data.dot_left_name = ""
		if dot_data.right_show:
			var d = create_dot(i, "right", dot_data.right_type,
				dot_data.right_color, dot_data.right_offset,
				dot_data.right_max_connections)
			dot_data.dot_right_name = d.name
		else:
			dot_data.dot_right_name = ""
			
			
func create_dot(id: int, pos: String, type: int, color: Color,
	offset: Vector2, max_connections : int):
	var c = content_container.get_child(id)
	var d = dot.instance()
	if !c: return
	if !Engine.editor_hint:
		d.set_values(0 if pos == "left" else 1, type, color, max_connections)
	else:
		d.modulate = color
	if pos == "left":
		var fixed_offset = 28
		dot_container_left.add_child(d)
		d.rect_position.x = (principal_container.rect_position.x - fixed_offset -
			d.rect_size.x * 0.5 + offset.x)
		d.rect_position.y = (c.rect_position.y + c.rect_size.y * 0.5 -
			d.rect_size.y * 0.5 + offset.y + 10)
	else:
		var fixed_offset = 29
		dot_container_right.add_child(d)
		d.rect_position.x = (principal_container.rect_position.x + rect_size.x -
			fixed_offset - d.rect_size.x * 0.5 + offset.x)
		d.rect_position.y = (c.rect_position.y + c.rect_size.y * 0.5 -
			d.rect_size.y * 0.5 + offset.y + 10)
	d.connect("left_button_pressed", self, "start_move_point")
	d.connect("left_button_released", self, "end_move_point")
	d.connect("right_button_pressed", self, "delete_connection_request")
	d.connect("right_button_released", self, "end_move_point")
	
	return d
	
func process_dot_pressed(layer, type):
	pass

func add_child(node: Node, legible_unique_name: bool = false):
	content_container.add_child(node, legible_unique_name)
	node.connect("tree_exiting", self, "queue_remove_slot", [node])
	if !slots: slots = []
	var dot_struct = {
		"dot_left_name"						: "",
		"left_show"							: false,
		"left_type"							: 0,
		"left_color"						: Color.white,
		"left_offset"						: Vector2.ZERO,
		"left_max_connections"				: 1,
		"dot_right_name"					: "",
		"right_show"						: false,
		"right_type"						: 0,
		"right_color"						: Color.white,
		"right_offset"						: Vector2.ZERO,
		"right_max_connections"				: 1
	}
	slots.append(dot_struct)
	property_list_changed_notify()
	


func start_move_point(current_dot):
	if !focused: grab_focus()
	emit_signal("start_move_point", name, current_dot, id)
	
func end_move_point(current_dot):
	if !focused: grab_focus()
	emit_signal("end_move_point", name, current_dot, id)
	
func delete_connection_request(current_dot):
	if !focused: grab_focus()
	emit_signal("delete_connection_request", name, current_dot, id)


func queue_remove_slot(node: Node):
	remove_dots_timer = 3
	remove_dots_array.append(node.get_index())
	
func remove_slots():
	remove_dots_array.sort()
	remove_dots_array.invert()
	for index in remove_dots_array:
		if index > slots.size() - 1: continue
		var slot = slots[index]
		slots.remove(index)
	remove_dots_array.clear()
	update_dots()
	
func _process(delta: float) -> void:
	if Engine.editor_hint:
		if !content_container: set_initial_variables()
		if remove_dots_timer > 0:
			remove_dots_timer -= 1
			if remove_dots_timer == 0:
				remove_slots()
		if slots.size() == 0 and _backup_slots != null:
			slots = _backup_slots
			update_dots()
			_backup_slots = null
	if !visible: visible = true



func _input(event: InputEvent) -> void:
	return
	if event is InputEventMouseButton and event.is_pressed():
		if get_global_rect().has_point(get_global_mouse_position()):
			if !focused:
				grab_focus()
				get_tree().set_input_as_handled()
			get_parent().move_child(self, get_parent().get_child_count())
			

func check_mouse_in() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())


func _on_CustomGraphNode_item_rect_changed() -> void:
	update_dots()


func _on_CustomGraphNode_tree_entered() -> void:
	set_initial_variables()


func _on_CustomGraphNode_tree_exiting() -> void:
	_backup_slots = slots.duplicate()

func expand_collapse():
	if collapsed:
		rect_min_size.y = last_max_y
		rect_size.y = collapsed.vertical_size
		for i in dot_container_left.get_child_count():
			var dot = dot_container_left.get_child(i)
			dot.rect_position.y = collapsed.left_dots[i]
			dot.visible = true
		for i in dot_container_right.get_child_count():
			var dot = dot_container_right.get_child(i)
			dot.rect_position.y = collapsed.right_dots[i]
			dot.visible = true
		content_container.visible = true
		collapsed = false
		emit_signal("collapsed", false)
	else:
		var ld = []; var rd = []; var y = -40
		for i in dot_container_left.get_child_count():
			var dot = dot_container_left.get_child(i)
			ld.append(dot.rect_position.y)
			dot.rect_position.y = y + 3
			dot.visible = true
		for i in dot_container_right.get_child_count():
			var dot = dot_container_right.get_child(i)
			rd.append(dot.rect_position.y)
			dot.rect_position.y = y
			dot.visible = true
		collapsed = {
			"vertical_size"		: rect_size.y,
			"left_dots"			: ld,
			"right_dots"		: rd
		}
		content_container.visible = false
		last_max_y = rect_min_size.y
		rect_min_size.y = 40
		rect_size.y = 40
		emit_signal("collapsed", true)
	update_dots()


func _on_CustomGraphNode_gui_input(event: InputEvent) -> void:
	if (!dragging and !resizing and !collapsed): set_edge()
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			if event.doubleclick:
				expand_collapse()
			else:
				if target_edge == -1:
					dragging = true
				else:
					resizing = true
					last_mouse_position = get_local_mouse_position()
		else:
			dragging = false
			resizing = false
			target_edge = -1
			emit_signal("end_move_and_resizing", self)
	if event is InputEventMouseMotion:
		if dragging:
			rect_position += event.relative
			emit_signal("moving", name, event.relative)
		elif resizing and resizable:
			var _rect_size = rect_size
			var current_mouse_position = get_local_mouse_position()
			var i; var j;
			if (target_edge == edge.left or
				target_edge == edge.topl or target_edge == edge.botl) and \
				horizontal_resizable:
				if ((event.relative.x < 0 and
					current_mouse_position.x <= border_size) or
					event.relative.x > 0):
					i = last_mouse_position.x - current_mouse_position.x
					rect_size.x += i
					j = _rect_size.x - rect_size.x
					rect_position.x += j
					emit_signal("resizing", name, "x", i, j)
			if (target_edge == edge.topl or
				target_edge == edge.top or target_edge == edge.topr) and \
				vertical_resizable:
				if ((event.relative.y < 0 and
					current_mouse_position.y <= border_size) or
					event.relative.y > 0):
					i = last_mouse_position.y - current_mouse_position.y
					rect_size.y += i
					j = _rect_size.y - rect_size.y
					rect_position.y += j
					emit_signal("resizing", name, "y", i, j)
			if (target_edge == edge.topr or
				target_edge == edge.right or target_edge == edge.botr) and \
				horizontal_resizable:
				if ((event.relative.x > 0 and
					current_mouse_position.x >= rect_size.x - border_size) or
					event.relative.x < 0):
					i = current_mouse_position.x - last_mouse_position.x
					rect_size.x += i
					emit_signal("resizing", name, "x", i, 0)
			if (target_edge == edge.botl or
				target_edge == edge.bottom or target_edge == edge.botr) and \
				vertical_resizable:
				if ((event.relative.y > 0 and
					current_mouse_position.y >= rect_size.y - border_size) or
					event.relative.y < 0):
					i = current_mouse_position.y - last_mouse_position.y
					rect_size.y += i
					emit_signal("resizing", name, "y", i, 0)
			last_mouse_position = get_local_mouse_position()
			
		
		
func set_edge():
	target_edge = -1
	if !resizable: return
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
			
	set_default_cursor_shape(cursor_type)


func is_on_screen() -> bool:
	return true


func _on_CustomGraphNode_focus_entered() -> void:
	if !Input.is_key_pressed(KEY_SHIFT) and !focused:
		emit_signal("deselect_all")
	focused = true
	get_parent().move_child(self, get_parent().get_child_count())


func _on_CustomGraphNode_focus_exited() -> void:
	pass # Replace with function body.


func _on_ColorPickerButton_color_changed(color: Color) -> void:
	set("frame_color", color)


func _on_CustomGraphNode_draw() -> void:
	if focused:
		draw_rect(Rect2(Vector2.ZERO, rect_size), Color.red, false, 3)
	
func get_point(tree, dot_index) -> CustomNodeDot:
	if tree == "left":
		if dot_index <= dot_container_left.get_child_count() - 1:
			return dot_container_left.get_child(dot_index)
	else:
		if dot_index <= dot_container_right.get_child_count() - 1:
			return dot_container_right.get_child(dot_index)
	return null
	
func get_left_points() -> Array:
	return dot_container_left.get_children()
	
func get_right_points() -> Array:
	return dot_container_right.get_children()


func _on_CloseButton_button_down() -> void:
	emit_signal("close_request", self)

func select(force_select = false) -> void:
	if !Input.is_key_pressed(KEY_SHIFT) and !focused and !force_select:
		emit_signal("deselect_all")
	focused = true
	update()
	
func deselect():
	focused = false
	emit_signal("deselect", self)
	update()
	
func add_connection(connection):
	connections.append(connection)
	
func remove_connection(connection):
	for c in connections:
		if 	c.from == connection.from and \
			c.from_port == connection.from_port and \
			c.to == connection.to and \
			c.to_port == connection.to_port:
			connections.erase(c)
			break
			
func get_connections():
	return connections
	
func delete_connections():
	connections.clear()
	
func set_connections(_connections):
	connections = _connections

func get_random_name() -> String:
	randomize()
	var data = "abcdefghijklmnopqrstuvwxyz0123456789"
	var _name = ""
	for i in 64:
		_name += data[randi()%data.length()-1]
	return _name

func queue_free():
	visible = false
	var cnt = 0
	if yields_active > 0:
		if is_inside_tree():
			yield(get_tree(), "idle_frame")
			cnt += 1
			if cnt == 30:
				yields_active = 0
	.queue_free()

func wait(amount=0):
	amount = int(amount)
	for i in amount:
		if is_instance_valid(self):
			if is_inside_tree():
				#ignore-warning:resume
				yield(get_tree(),"idle_frame")
			else:
				return
		else:
			break

func _on_timer_timeout():
	pass
