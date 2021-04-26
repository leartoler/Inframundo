extends Panel
class_name DefaultDialog

export(bool) var resizable = false
export(bool) var horizontal_resizable = true
export(bool) var vertical_resizable = true

var drag = false
var dialog_id
var sub_dialog_open = false
var tween : Tween

enum edge {left, top, right, bottom, topl, topr, botl, botr};
var resizing = false
var target_edge = -1
var border_size = 10
var cursor_type = -1
var last_mouse_position = null

var can_autosize = true

signal OK(text, dialog_id)
signal Cancel()

func _ready() -> void:
	tween = Tween.new()
	tween.name = "TWEEN"
	add_child(tween)
	connect("gui_input", self, "_on_gui_input")
	connect("visibility_changed", self, "_on_visibility_changed")
	if has_node("VBoxContainer/HBoxContainer3/Cancel_Button"):
		get_node("VBoxContainer/HBoxContainer3/Cancel_Button").connect(
			"focus_exited", self, "_on_cancel_button_focus_exited")
	
func _on_gui_input(event : InputEvent) -> void:
	if !drag and !resizing: set_edge()
	if resizing and resizable:
		if event is InputEventMouseMotion:
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
			if (target_edge == edge.topr or
				target_edge == edge.right or target_edge == edge.botr) and \
				horizontal_resizable:
				if ((event.relative.x > 0 and
					current_mouse_position.x >= rect_size.x - border_size) or
					event.relative.x < 0):
					i = current_mouse_position.x - last_mouse_position.x
					rect_size.x += i
			if (target_edge == edge.botl or
				target_edge == edge.bottom or target_edge == edge.botr) and \
				vertical_resizable:
				if ((event.relative.y > 0 and
					current_mouse_position.y >= rect_size.y - border_size) or
					event.relative.y < 0):
					i = current_mouse_position.y - last_mouse_position.y
					rect_size.y += i
			last_mouse_position = get_local_mouse_position()
		elif event is InputEventMouseButton and \
			event.button_index == BUTTON_LEFT and !event.is_pressed():
			resizing = false
	elif (event is InputEventMouseButton and
		event.button_index == BUTTON_LEFT):
		if target_edge == -1:
			drag = event.is_pressed()
		else:
			if resizable:
				resizing = true
				last_mouse_position = get_local_mouse_position()
	elif drag and event is InputEventMouseMotion:
		rect_position += event.relative

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

func show() -> void:
	var pos = get_global_mouse_position() - rect_size * 0.5
	var margin = 60
	var s = get_viewport().size
	if pos.x < margin:
		pos.x = margin
	elif pos.x + rect_size.x - margin > s.x:
		pos.x = s.x - rect_size.x - margin
	if pos.y < margin:
		pos.y = margin
	elif pos.y + rect_size.y - margin > s.y:
		pos.y = s.y - rect_size.y - margin
	rect_global_position = pos
	.show()
	
func _input(event: InputEvent) -> void:
	return
#	if !sub_dialog_open:
#		if (event is InputEventKey and event.scancode == KEY_ESCAPE):
#			get_tree().set_input_as_handled()
#			hide()
		
func hide() -> void:
	emit_signal("Cancel", self)
	.hide()
	
func _on_visibility_changed() -> void:
	if visible:
		modulate.a = 0
		tween.interpolate_property(self, "modulate", Color(1,1,1,0),
		Color(1,1,1,1), 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.reset_all()
		tween.start()
		if has_node("VBoxContainer/HBoxContainer3/OK_Button"):
			get_node("VBoxContainer/HBoxContainer3/OK_Button").grab_focus()

func _on_cancel_button_focus_exited():
	yield(get_tree(), "idle_frame")
	var c = get_node("VBoxContainer/HBoxContainer3/Cancel_Button")
	get_first_control_with_focus(c.get_parent().get_parent().get_parent())

func get_first_control_with_focus(obj):
	if !obj is PopupMenu and "focus_mode" in obj:
		var obj2 = obj
		if obj2 is SpinBox: obj2 = obj2.get_line_edit()
		if obj2.focus_mode != FOCUS_NONE:
			obj2.grab_focus()
			return true
	if obj.get_child_count() != 0:
		for child in obj.get_children():
			if child is SpinBox: child = child.get_line_edit()
			var value = get_first_control_with_focus(child)
			if value:
				return true
	return false
		

func auto_calculate_size(obj) -> void:
	if !can_autosize: return
	can_autosize = false
	var size = get_real_size(obj, Vector2.ZERO)
	rect_min_size = size + Vector2(6, 6)
	rect_size = rect_min_size
	can_autosize = true

func get_real_size(obj, _size) -> Vector2:
	if obj.has_method("get_size"):
		_size.x = max(_size.x, get_size().x)
		_size.y = max(_size.y, get_size().y)
	if obj.get_child_count() > 0:
		for child in obj.get_children():
			_size = get_real_size(child, _size)
	return _size
