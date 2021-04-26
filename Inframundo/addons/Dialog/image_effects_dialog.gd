extends DefaultDialog

onready var type_options			= $VBoxContainer/HBoxContainer/OptionButton
onready var id_container			= $VBoxContainer/HBoxContainer/HBoxContainer
onready var duration_spinbox		= $VBoxContainer/HBoxContainer2/HBoxContainer/SpinBox
onready var duration_container		= $VBoxContainer/HBoxContainer2/HBoxContainer
onready var id_spinbox				= $VBoxContainer/HBoxContainer/HBoxContainer/SpinBox
onready var effects_options			= $VBoxContainer/HBoxContainer2/OptionButton
onready var delay_container			= $VBoxContainer/HBoxContainer2/HBoxContainer2

onready var delay_spinbox			= $VBoxContainer/HBoxContainer2/HBoxContainer2/SpinBox
onready var pause_checkbox			= $VBoxContainer/HBoxContainer/HBoxContainer2/CheckBox

onready var shake_container			= $VBoxContainer/Panel/HBoxContainer4/shake_config
onready var shake_rate_spinbox		= $VBoxContainer/Panel/HBoxContainer4/shake_config/HBoxContainer/SpinBox
onready var shake_level_spinbox		= $VBoxContainer/Panel/HBoxContainer4/shake_config/HBoxContainer2/SpinBox

onready var opacity_container		= $VBoxContainer/Panel/HBoxContainer4/opacity_config
onready var opacity_slider			= $VBoxContainer/Panel/HBoxContainer4/opacity_config/HBoxContainer/HSlider
onready var label_opacity_slider	= $VBoxContainer/Panel/HBoxContainer4/opacity_config/HBoxContainer/Label
onready var opacity_mode			= $VBoxContainer/Panel/HBoxContainer4/opacity_config/HBoxContainer2/OptionButton
onready var opacity_mode_spinbox	= $VBoxContainer/Panel/HBoxContainer4/opacity_config/HBoxContainer2/SpinBox

onready var color_container			= $VBoxContainer/Panel/HBoxContainer4/color_config
onready var color_picker_button		= $VBoxContainer/Panel/HBoxContainer4/color_config/HBoxContainer/ColorPickerButton
onready var color_mode				= $VBoxContainer/Panel/HBoxContainer4/color_config/HBoxContainer/HBoxContainer3/OptionButton
onready var color_mode_spinbox		= $VBoxContainer/Panel/HBoxContainer4/color_config/HBoxContainer/HBoxContainer3/SpinBox

onready var movement_container		= $VBoxContainer/Panel/HBoxContainer4/movement_config
onready var movement_x_spinbox		= $VBoxContainer/Panel/HBoxContainer4/movement_config/HBoxContainer/SpinBox
onready var movement_y_spinbox		= $VBoxContainer/Panel/HBoxContainer4/movement_config/HBoxContainer/SpinBox2
onready var movement_mode			= $VBoxContainer/Panel/HBoxContainer4/movement_config/HBoxContainer2/OptionButton
onready var movement_mode_spinbox	= $VBoxContainer/Panel/HBoxContainer4/movement_config/HBoxContainer2/SpinBox

onready var zoom_container			= $VBoxContainer/Panel/HBoxContainer4/zoom_config
onready var zoom_x_spinbox			= $VBoxContainer/Panel/HBoxContainer4/zoom_config/HBoxContainer/SpinBox
onready var zoom_y_spinbox			= $VBoxContainer/Panel/HBoxContainer4/zoom_config/HBoxContainer/SpinBox2
onready var zoom_mode				= $VBoxContainer/Panel/HBoxContainer4/zoom_config/HBoxContainer2/OptionButton
onready var zoom_mode_spinbox		= $VBoxContainer/Panel/HBoxContainer4/zoom_config/HBoxContainer2/SpinBox

onready var rotate_container		= $VBoxContainer/Panel/HBoxContainer4/rotate_config
onready var rotate_spinbox			= $VBoxContainer/Panel/HBoxContainer4/rotate_config/HBoxContainer/SpinBox
onready var rotate_mode				= $VBoxContainer/Panel/HBoxContainer4/rotate_config/HBoxContainer2/OptionButton
onready var rotate_mode_spinbox		= $VBoxContainer/Panel/HBoxContainer4/rotate_config/HBoxContainer2/SpinBox

func _ready() -> void:
	var spinboxes = [id_spinbox, shake_rate_spinbox, shake_level_spinbox,
		opacity_mode_spinbox, movement_x_spinbox, movement_y_spinbox,
		movement_mode_spinbox, zoom_x_spinbox, zoom_y_spinbox,
		zoom_mode_spinbox, rotate_spinbox, rotate_mode_spinbox, delay_spinbox]
	for spinbox in spinboxes:
		spinbox.get_line_edit().caret_blink = true
	fill_effects(0)

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	id_spinbox.apply()
	duration_spinbox.apply()
	delay_spinbox.apply()
	shake_rate_spinbox.apply()
	shake_level_spinbox.apply()
	opacity_mode_spinbox.apply()
	color_mode_spinbox.apply()
	movement_x_spinbox.apply()
	movement_y_spinbox.apply()
	movement_mode_spinbox.apply()
	zoom_x_spinbox.apply()
	zoom_y_spinbox.apply()
	zoom_mode_spinbox.apply()
	rotate_spinbox.apply()
	rotate_mode_spinbox.apply()
	var data = get_data()
	var text = {}
	text["begin_text"] 	= "[image_effect %s]" % data
	text["end_text"]	= ""
	emit_signal("OK", text, dialog_id)

func get_data() -> String:
	var s = ""
	s += "effect_id=%s" % effects_options.text.replace(" ", "_").to_lower()
	s += " image_type=%s" % type_options.get_selected_id()
	if type_options.get_selected_id() == 1:
		id_spinbox.apply()
		s += " id=%s" % id_spinbox.value
	if effects_options.text == "Shake":
		duration_spinbox.apply()
		s += " time=%s" % duration_spinbox.value
	else:
		delay_spinbox.apply()
		s += " delay=%s" % delay_spinbox.value
	match effects_options.text:
		"Shake":
			shake_rate_spinbox.apply()
			shake_level_spinbox.apply()
			s += " rate=%s" % shake_rate_spinbox.value
			s += " level=%s" % shake_level_spinbox.value
		"Change Opacity":
			opacity_mode_spinbox.apply()
			s += " opacity=%s" % opacity_slider.value
			s += " mode=%s" % opacity_mode.get_selected_id()
			if opacity_mode.get_selected_id() == 1:
				s += " time=%s" % opacity_mode_spinbox.value
			else:
				s += " time=0"
		"Modulate By Color":
			s += " color=%s" % color_picker_button.color.to_html()
			s += " mode=%s" % color_mode.get_selected_id()
			if color_mode.get_selected_id() == 1:
				s += " time=%s" % color_mode_spinbox.value
			else:
				s += " time=0"
		"Move to Position":
			movement_x_spinbox.apply()
			movement_y_spinbox.apply()
			movement_mode_spinbox.apply()
			s += " x=%s" % movement_x_spinbox.value
			s += " y=%s" % movement_y_spinbox.value
			s += " mode=%s" % movement_mode.get_selected_id()
			if movement_mode.get_selected_id() == 1:
				s += " time=%s" % movement_mode_spinbox.value
			else:
				s += " time=0"
		"Change Zoom":
			zoom_x_spinbox.apply()
			zoom_y_spinbox.apply()
			zoom_mode_spinbox.apply()
			s += " x=%s" % zoom_x_spinbox.value
			s += " y=%s" % zoom_y_spinbox.value
			s += " mode=%s" % zoom_mode.get_selected_id()
			if zoom_mode.get_selected_id() == 1:
				s += " time=%s" % zoom_mode_spinbox.value
			else:
				s += " time=0"
		"Rotate":
			rotate_spinbox.apply()
			rotate_mode_spinbox.apply()
			s += " angle=%s" % rotate_spinbox.value
			s += " mode=%s" % rotate_mode.get_selected_id()
			if rotate_mode.get_selected_id() == 1:
				s += " time=%s" % rotate_mode_spinbox.value
			else:
				s += " time=0"
	s += " set_pause=%s" % pause_checkbox.pressed
	return s


func _on_type_OptionButton_item_selected(index: int) -> void:
	fill_effects(index)
	if index == 1:
		id_container.visible = true
		duration_container.visible = false
		yield(get_tree(), "idle_frame")
		var lineedit = id_spinbox.get_line_edit()
		lineedit.caret_position = lineedit.text.length()
		lineedit.select_all()
		lineedit.grab_focus()
		rect_size.y = 219
	else:
		id_container.visible = false
		rect_size.y = 213
	if effects_options.text == "Shake":
		duration_container.visible = true
		delay_container.visible = false
	else:
		duration_container.visible = false
		delay_container.visible = true
		
func fill_effects(index):
	var indexSelected = effects_options.get_selected_id()
	effects_options.clear()
	var effects
	if index == 0:
		effects = ["Shake", "Change Opacity", "Modulate By Color",
			"Change Zoom", "Rotate"]
	elif index == 1:
		effects = ["Shake", "Change Opacity", "Modulate By Color",
					"Move to Position", "Change Zoom", "Rotate"]
	else:
		effects = ["Shake"]
	for effect in effects:
		effects_options.add_item(effect)
	indexSelected = min(indexSelected, effects.size() - 1)
	effects_options.select(indexSelected)
	effects_options.emit_signal("item_selected", indexSelected)




func _on_HSlider_value_changed(value: float) -> void:
	label_opacity_slider.text = "%s %%" % value

func select_lineedit(spinbox):
	yield(get_tree(), "idle_frame")
	var lineedit = spinbox.get_line_edit()
	lineedit.caret_position = lineedit.text.length()
	lineedit.select_all()
	lineedit.grab_focus()

func _on_opacity_OptionButton_item_selected(index: int) -> void:
	opacity_mode_spinbox.editable = index == 1
	if opacity_mode_spinbox.editable:
		select_lineedit(opacity_mode_spinbox)
		
func _on_color_OptionButton_item_selected(index: int) -> void:
	color_mode_spinbox.editable = index == 1
	if color_mode_spinbox.editable:
		select_lineedit(color_mode_spinbox)


func _on_movement_OptionButton_item_selected(index: int) -> void:
	movement_mode_spinbox.editable = index == 1
	if movement_mode_spinbox.editable:
		select_lineedit(movement_mode_spinbox)

func _on_zoom_OptionButton_item_selected(index: int) -> void:
	zoom_mode_spinbox.editable = index == 1
	if zoom_mode_spinbox.editable:
		select_lineedit(zoom_mode_spinbox)

func _on_rotate_OptionButton_item_selected(index: int) -> void:
	rotate_mode_spinbox.editable = index == 1
	if rotate_mode_spinbox.editable:
		select_lineedit(rotate_mode_spinbox)

func _on_OptionButton_item_selected(index: int) -> void:
	shake_container.visible = false
	opacity_container.visible = false
	color_container.visible = false
	movement_container.visible = false
	zoom_container.visible = false
	rotate_container.visible = false
	match effects_options.get_item_text(index):
		"Shake": shake_container.visible = true
		"Change Opacity": opacity_container.visible = true
		"Modulate By Color": color_container.visible = true
		"Move to Position": movement_container.visible = true
		"Change Zoom": zoom_container.visible = true
		"Rotate": rotate_container.visible = true
	if effects_options.text == "Shake":
		duration_container.visible = true
		delay_container.visible = false
	else:
		duration_container.visible = false
		delay_container.visible = true


func set_parameters(parameters):
	var other_values = {}
	var effect_id = null
	var image_type = null
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"effect_id":
					var effects = ["shake", "change_opacity",
						"modulate_by_color", "move_to_position",
						"change_zoom", "rotate"]
					effect_id = 0
					for j in effects.size():
						if effects[j] == param[1].to_lower():
							effect_id = j
							break
					effects_options.select(max(0, min(effect_id,
						effects_options.get_item_count() - 1)))
					effect_id = effects_options.text.replace(" ", "_").to_lower()
				"image_type":
					type_options.select(max(0, min(int(param[1]),
						type_options.get_item_count() - 1)))
					image_type = type_options.get_selected_id()
				"id": id_spinbox.value = int(param[1])
				"duration": duration_spinbox.value = float(param[1])
				"delay": delay_spinbox.value = float(param[1])
				"rate": shake_rate_spinbox.value = float(param[1])
				"level": shake_level_spinbox.value = float(param[1])
				"opacity": opacity_slider.value = int(param[1])
				"color": color_picker_button.color = Color(param[1])
				"angle": rotate_spinbox.value = float(param[1])
				"mode": other_values[param[0]] = int(param[1])
				"time": other_values[param[0]] = float(param[1])
				"x": other_values[param[0]] = int(param[1])
				"y": other_values[param[0]] = int(param[1])
				"set_pause":
					pause_checkbox.pressed = param[1].to_lower() == "true"
	match effect_id:
		"shake":
			if other_values.has("time"):
				duration_spinbox.value = other_values["time"]
		"change_opacity":
			if other_values.has("mode"):
				var id = max(0, min(other_values["mode"],
					opacity_mode.get_item_count() - 1))
				opacity_mode.select(id)
				_on_opacity_OptionButton_item_selected(id)
			if other_values.has("time"):
				opacity_mode_spinbox.value = other_values["time"]
		"modulate_by_color":
			if other_values.has("mode"):
				var id = max(0, min(other_values["mode"],
					color_mode.get_item_count() - 1))
				color_mode.select(id)
				_on_color_OptionButton_item_selected(id)
			if other_values.has("time"):
				color_mode_spinbox.value = other_values["time"]
		"move_to_position":
			if other_values.has("x"):
				movement_x_spinbox.value = other_values["x"]
			if other_values.has("y"):
				movement_y_spinbox.value = other_values["y"]
			if other_values.has("mode"):
				var id = max(0, min(other_values["mode"],
					movement_mode.get_item_count() - 1))
				movement_mode.select(id)
				_on_movement_OptionButton_item_selected(id)
			if other_values.has("time"):
				movement_mode_spinbox.value = other_values["time"]
		"change_zoom":
			if other_values.has("x"):
				zoom_x_spinbox.value = other_values["x"]
			if other_values.has("y"):
				zoom_y_spinbox.value = other_values["y"]
			if other_values.has("mode"):
				var id = max(0, min(other_values["mode"],
					zoom_mode.get_item_count() - 1))
				zoom_mode.select(id)
				_on_zoom_OptionButton_item_selected(id)
			if other_values.has("time"):
				zoom_mode_spinbox.value = other_values["time"]
		"rotate":
			if other_values.has("mode"):
				var id = max(0, min(other_values["mode"],
					rotate_mode.get_item_count() - 1))
				rotate_mode.select(id)
				_on_rotate_OptionButton_item_selected(id)
			if other_values.has("time"):
				rotate_mode_spinbox.value = other_values["time"]
	if image_type != null:
		_on_type_OptionButton_item_selected(image_type)
	if effect_id != null:
		_on_OptionButton_item_selected(effects_options.get_selected_id())
