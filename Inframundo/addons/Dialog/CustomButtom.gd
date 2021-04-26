tool
extends Button

export(Texture) var background_normal setget set_background_normal
export(Texture) var background_over setget set_background_over
export(Texture) var background_disabled setget set_background_disabled
export(Texture) var icon_normal setget set_icon_normal
export(Texture) var icon_over setget set_icon_over
export(Texture) var icon_disabled setget set_icon_disabled

export(Color) var text_color_normal = Color.white setget set_color_text_normal
export(Color) var text_color_over = Color.orange setget set_color_text_over
export(Color) var text_color_disabled = Color(0.7,0.7,0.7,0.5) setget set_color_text_disabled

export(String) var label_text setget change_text

var is_disabled = false

func set_background_normal(value):
	background_normal = value
	update_appearance()
	
func set_background_over(value):
	background_over = value
	update_appearance()
	
func set_background_disabled(value):
	background_disabled = value
	update_appearance()
	
func set_icon_normal(value):
	icon_normal = value
	update_appearance()
	
func set_icon_over(value):
	icon_over = value
	update_appearance()
	
func set_icon_disabled(value):
	icon_disabled = value
	update_appearance()
	
func set_color_text_normal(value):
	text_color_normal = value
	update_appearance()
	
func set_color_text_over(value):
	text_color_over = value
	update_appearance()
	
func set_color_text_disabled(value):
	text_color_disabled = value
	update_appearance()
	
func change_text(value):
	label_text = value
	update_appearance()
	
func update_appearance():
	if !has_node("Background"): return
	
	if label_text:
		get_node("Label").text = label_text
	if disabled:
		if background_disabled:
			get_node("Background").texture = background_disabled
		if icon_disabled:
			get_node("icon").texture = icon_disabled
		if text_color_disabled != null:
			get_node("Label").add_color_override("font_color", text_color_disabled)
	else:
		if background_normal:
			get_node("Background").texture = background_normal
		if icon_normal:
			get_node("icon").texture = icon_normal
		if text_color_normal != null:
			get_node("Label").add_color_override("font_color", text_color_normal)



func _on_CustomButtom_mouse_entered() -> void:
	if disabled: return
	if background_over:
			get_node("Background").texture = background_over
	if icon_over:
		get_node("icon").texture = icon_over
	if text_color_over != null:
		get_node("Label").add_color_override("font_color", text_color_over)


func _on_CustomButtom_mouse_exited() -> void:
	if disabled: return
	if background_normal:
		get_node("Background").texture = background_normal
	if icon_normal:
		get_node("icon").texture = icon_normal
	if text_color_normal != null:
		get_node("Label").add_color_override("font_color", text_color_normal)

func _process(delta: float) -> void:
	if is_disabled != disabled:
		update_appearance()
		is_disabled = disabled
