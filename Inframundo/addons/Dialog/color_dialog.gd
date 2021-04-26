extends DefaultDialog

onready var default_colors 	= $VBoxContainer/OptionButton
onready var color_picker 	= $VBoxContainer/ColorPicker 

var popup_last_position = null
var last_position = null

var color = "ffffff"
var target_node = null

func _ready() -> void:
	populate_default_colors()

func populate_default_colors():
	default_colors.add_item("SELECT DEFAULT COLORS")
	var file = File.new()
	var colors_file = "res://addons/Dialog/Fonts/list_color.json"
	if file.file_exists(colors_file):
		file.open(colors_file, File.READ)
		var colors = ""
		while not file.eof_reached():
			colors += file.get_line()
		colors = JSON.parse(colors).result
		var id = 1
		for key in colors.keys():
			var c = Color(colors[key])
			var img = Image.new()
			img.create(20, 20, false, Image.FORMAT_RGBA8)
			img.fill(c)
			var tex = ImageTexture.new()
			tex.create_from_image(img)
			default_colors.add_icon_item(tex, key, id)
			id += 1

func get_presets() -> PoolColorArray:
	return color_picker.get_presets()
	
func set_presets(presets : PoolColorArray) -> void:
	for preset in presets:
		color_picker.add_preset(preset)

func clear_color_presets():
	var presets = get_presets()
	for preset in presets:
		color_picker.erase_preset(preset)

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")


func _on_OK_Button_button_down() -> void:
	var color = color_picker.color.to_html()
	var text = {}
	text["begin_text"]	= "[color=#%s]" % color
	text["end_text"]	= "[/color]"
	emit_signal("OK", text, dialog_id)
		

func _on_Cancel_Button_focus_exited() -> void:
	pass


func _on_OptionButton_item_selected(index: int) -> void:
	if index == 0: return
	var tex = default_colors.get_item_icon(index)
	var img = tex.get_data()
	img.lock()
	var c = img.get_pixel(0, 0)
	img.unlock()
	color_picker.set_pick_color(c)
	self.color = c.to_html()


func _on_OptionButton_toggled(button_pressed: bool) -> void:
	if !button_pressed:
		popup_last_position = default_colors.get_popup().get_rect()
	elif popup_last_position != null:
		yield(get_tree(), "idle_frame")
		default_colors.get_popup().rect_position = popup_last_position.position


func _on_color_dialog_item_rect_changed() -> void:
	if popup_last_position != null:
		popup_last_position.position += rect_position - last_position
	last_position = rect_position


func _on_color_dialog_visibility_changed() -> void:
	if visible:
		last_position = rect_position
		get_node("VBoxContainer/HBoxContainer3/OK_Button").grab_focus()


func _on_ColorPicker_color_changed(color: Color) -> void:
	default_colors.select(0)
	self.color = color.to_html()
	
func set_color(color):
	self.color = color
	color_picker.set_pick_color(color)


func _on_ColorPicker_item_rect_changed() -> void:
	rect_size.y = color_picker.rect_size.y + 90
