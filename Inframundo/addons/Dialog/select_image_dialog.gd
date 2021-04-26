extends DefaultDialog

onready var c_ID			= $VBoxContainer/HBoxContainer/ID
onready var c_SIZE			= $VBoxContainer/Image/HBoxContainer/Size
onready var c_FLIP			= $VBoxContainer/Flip
onready var c_POSITION		= $VBoxContainer/Position
onready var c_IMAGE			= $VBoxContainer/Image/HBoxContainer/Panel
onready var C_MODULATE		= $VBoxContainer/ModulateColor
onready var C_APPEAR		= $VBoxContainer/AppearAnimation
onready var C_APPEAR_CUSTOM	= $VBoxContainer/AnimationCustom
onready var C_OFFSET		= $VBoxContainer/Offset
onready var c_type			= $VBoxContainer/HBoxContainer/OptionButton
onready var c_id			= $VBoxContainer/HBoxContainer/ID/SpinBox
onready var c_width			= $VBoxContainer/Image/HBoxContainer/Size/HBoxContainer/SpinBox
onready var c_height		= $VBoxContainer/Image/HBoxContainer/Size/HBoxContainer/SpinBox2
onready var c_flip			= $VBoxContainer/Flip/CheckBox
onready var c_offset		= $VBoxContainer/Offset/SpinBox
onready var c_mode			= $VBoxContainer/Position/Mode/OptionButton
onready var c_position		= $VBoxContainer/Position/Pos/OptionButton
onready var c_x				= $VBoxContainer/Position/CustomPos/SpinBox2
onready var c_y				= $VBoxContainer/Position/CustomPos/SpinBox3
onready var c_modulate		= $VBoxContainer/ModulateColor/ColorPickerButton
onready var c_appear		= $VBoxContainer/AppearAnimation/OptionButton

onready var c_custom_1		= $VBoxContainer/AnimationCustom/HBoxContainer3/SpinBox2 
onready var c_custom_2		= $VBoxContainer/AnimationCustom/HBoxContainer3/SpinBox
onready var c_custom_3		= $VBoxContainer/AnimationCustom/HBoxContainer/SpinBox2
onready var c_custom_4		= $VBoxContainer/AnimationCustom/HBoxContainer/SpinBox
onready var c_custom_5		= $VBoxContainer/AnimationCustom/HBoxContainer2/ColorPickerButton
onready var c_custom_6		= $VBoxContainer/AnimationCustom/HBoxContainer4/SpinBox
onready var c_custom_7		= $VBoxContainer/AnimationCustom/HBoxContainer5/SpinBox

onready var image_icon = preload("res://addons/Dialog/Graphics/search_image.png")

var image = null
var paths = null
var clean_mode = true

signal select_image_dialog_request()

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")
	

func _on_OK_Button_button_down() -> void:
	if image != null:
		c_id.apply()
		c_width.apply()
		c_height.apply()
		c_x.apply()
		c_y.apply()
		c_custom_1.apply()
		c_custom_2.apply()
		c_custom_3.apply()
		c_custom_4.apply()
		c_custom_6.apply()
		c_custom_7.apply()
		var text = {}
		var image_path = image.replace(" ", "■")
		if paths != null:
			image_path = image_path.replace(paths.graphics, "")
		match c_type.get_selected_id():
			0: # faces
				var p0 = "img=%s" % image_path
				var p1 = "flip=%s" % c_flip.pressed
				var p2 = "color=%s" % c_modulate.color.to_html()
				var p3 = "animation=%s" % c_appear.get_selected_id()
				var p4 = ""
				if c_appear.get_selected_id() == 6:
					p4 = " params=%s,%s,%s,%s,%s,%s,%s" % [
						c_custom_1.value, c_custom_2.value, c_custom_3.value,
						c_custom_4.value, c_custom_5.color.to_html(),
						c_custom_6.value, c_custom_7.value,
					]
				text["begin_text"]	= "[face %s %s %s %s%s]" % [
					p0, p1, p2, p3, p4
				]
				text["end_text"]	= ""
			1: # Full Character
				var p0 = "id=%s" % c_id.value
				var p1 = "img=%s" % image_path
				var p2 = "scale=%sx%s" % [c_width.value, c_height.value]
				var p3 = "flip=%s" % c_flip.pressed
				var p4 = "mode=%s" % c_mode.get_selected_id()
				var p5 = "color=%s" % c_modulate.color.to_html()
				var p6 = "pos=%s,%s,%s" % [c_position.get_selected_id(),
					c_x.value, c_y.value]
				var p7 = "animation=%s" % c_appear.get_selected_id()
				var p8 = ""
				if c_appear.get_selected_id() == 6:
					p8 = " params=%s,%s,%s,%s,%s,%s,%s" % [
						c_custom_1.value, c_custom_2.value, c_custom_3.value,
						c_custom_4.value, c_custom_5.color.to_html(),
						c_custom_6.value, c_custom_7.value,
					]
				var t = "[character %s %s %s %s %s %s %s %s%s]" % [
					p0, p1, p2, p3, p4, p5, p6, p7, p8
				]
				text["begin_text"]	= t
				text["end_text"]	= ""
			2: # Embed image in text
				text["begin_text"]	= "[img scale=%sx%s name=%s flip=%s offset=%s] " % [
					c_width.value, c_height.value,
					image_path,
					c_flip.pressed, c_offset.value
				]
				text["end_text"]	= ""
		emit_signal("OK", text, dialog_id)
	else:
		emit_signal("OK", null, dialog_id)
		

func _on_Cancel_Button_focus_exited() -> void:
	yield(get_tree(), "idle_frame")



func _on_OptionButton_item_selected(index: int) -> void:
	var lineedit 
	match index:
		0: # face
			c_ID.visible = false
			c_SIZE.visible = false
			c_FLIP.visible = true
			c_POSITION.visible = false
			C_MODULATE.visible = true
			C_APPEAR.visible = true
			C_OFFSET.visible = false
			if c_appear.get_selected_id() == 6:
				C_APPEAR_CUSTOM.visible = true
				rect_size = Vector2(347, 490)
			else:
				C_APPEAR_CUSTOM.visible = false
				rect_size = Vector2(342, 268)
		1: # Full body character
			c_ID.visible = true
			c_SIZE.visible = true
			c_FLIP.visible = true
			c_POSITION.visible = true
			C_MODULATE.visible = true
			C_APPEAR.visible = true
			C_OFFSET.visible = false
			if c_appear.get_selected_id() == 6:
				C_APPEAR_CUSTOM.visible = true
				rect_size = Vector2(347, 585)
			else:
				C_APPEAR_CUSTOM.visible = false
				rect_size = Vector2(342, 363)
			lineedit = c_id.get_line_edit()
		2: # Embed image in text
			c_ID.visible = false
			c_SIZE.visible = true
			c_FLIP.visible = true
			c_POSITION.visible = false
			C_MODULATE.visible = false
			C_APPEAR.visible = false
			C_APPEAR_CUSTOM.visible = false
			C_OFFSET.visible = true
			rect_size = Vector2(342, 252)
			lineedit = c_width.get_line_edit()

	if lineedit != null:
		yield(get_tree(), "idle_frame")
		lineedit.caret_position = lineedit.text.length()
		lineedit.select_all()
		lineedit.grab_focus()


func _on_Panel_mouse_entered() -> void:
	var s = c_IMAGE.get_stylebox("panel")
	s.border_color = Color.orange


func _on_Panel_mouse_exited() -> void:
	var s = c_IMAGE.get_stylebox("panel")
	s.border_color = Color.black


func _on_select_image_dialog_visibility_changed() -> void:
	if visible and image_icon and clean_mode:
		c_IMAGE.get_child(0).texture = image_icon
		image = null
	clean_mode = true
		
func load_image(img):
	var begin_path = paths.graphics if paths != null else ""
	if begin_path != "" and img.find(begin_path) != -1:
		begin_path = ""
	var t
	if ResourceLoader.exists(begin_path + img):
		t = ResourceLoader.load(begin_path + img)
	elif ResourceLoader.exists(img):
		t = ResourceLoader.load(img)
	else:
		var i = Image.new()
		i.load(begin_path + img)
		t = ImageTexture.new()
		t.create_from_image(i)
	c_IMAGE.get_child(0).texture = t
	image = img


func _on_Panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == 1 and event.is_pressed():
		emit_signal("select_image_dialog_request", "image")
		sub_dialog_open = true


func _on_AppearAnimation_OptionButton_item_selected(index: int) -> void:
	C_APPEAR_CUSTOM.visible = index == 6
	_on_OptionButton_item_selected(c_type.get_selected_id())


func set_parameters(type_id, parameters):
	type_id = max(0, min(int(type_id), c_type.get_item_count()-1))
	c_type.select(type_id)
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"img", "name": load_image(param[1].replace("■", " "))
				"id": c_id.value = int(param[1])
				"flip": c_flip.pressed = param[1].to_lower() == "true"
				"color": c_modulate.color = Color(param[1])
				"animation": c_appear.select(max(0, min(int(param[1]),
						c_appear.get_item_count() - 1)))
				"pos":
					param = param[1].split(",")
					if param.size() == 3:
						c_position.select(max(0, min(int(param[0]),
							c_position.get_item_count() - 1)))
						c_x.value = int(param[1])
						c_y.value = int(param[2])
				"mode":
					c_mode.select(max(0, min(int(param[1]),
						c_mode.get_item_count() - 1)))
				"scale":
					param = param[1].split("x")
					if param.size() == 2:
						c_width.value = float(param[0])
						c_height.value = float(param[1])
				"params":
					var params = param[1].split(",")
					if params.size() == 7:
						c_custom_1.value = int(params[0])
						c_custom_2.value = int(params[1])
						c_custom_3.value = float(params[2])
						c_custom_4.value = float(params[3])
						c_custom_5.color = Color(params[4])
						c_custom_6.value = float(params[5])
						c_custom_7.value = float(params[6])
				"offset":
					c_offset.value = int(param[1])
	_on_OptionButton_item_selected(type_id)



