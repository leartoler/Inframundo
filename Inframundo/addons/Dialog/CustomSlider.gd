tool
extends Control

enum MODE {Horizontal, Vertical}

export(Texture)	var slider_normal_texture	= (
	preload("res://addons/Dialog/Graphics/button_empty_normal.png")) setget change_texture
export(Texture)	var slider_hover_texture	= (
	preload("res://addons/Dialog/Graphics/button_empty_over.png"))
export(Texture)	var slider_disabled_texture	= (
	preload("res://addons/Dialog/Graphics/button_empty_disabled.png"))
	
export(float) var min_value = -1
export(float) var max_value = 1
export(bool) var warp_scroll = true

export(MODE) var style setget update_style

export(int, 1, 999) var max_change_by_speed = 100
	
var slider_button; var background;
var drag = false
var direction = 1
var speed
var pause_speed = 0

var current_value = 0
signal value_changed(value)
signal current_speed(value)

func _ready():
	set_initial_variables()
	
func set_initial_variables():
	background = $background
	slider_button = $slider_button
	set_button_in_mid()
	
func set_button_in_mid():
	slider_button.rect_position = (background.rect_position +
		background.rect_size * 0.5 - slider_button.rect_size * 0.5)

func update_style(value):
	style = value
	pass
	
func change_texture(value):
	slider_normal_texture = value
	if !slider_button: set_initial_variables()
	slider_button.texture_normal = slider_normal_texture


func _on_slider_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			drag = get_global_mouse_position()
		else:
			drag = false
			set_button_in_mid()
		speed = 0
	elif drag and event is InputEventMouseMotion:
		drag = get_global_mouse_position() - drag
		if style == MODE.Horizontal:
			slider_button.rect_position.x += drag.x
			direction = sign(drag.x)
		else:
			slider_button.rect_position.y += drag.y
			direction = sign(drag.y)
		fix_position(drag)
		set_current_value()
		if direction == -1: # to left
			speed -= 1
		else:
			speed += 1
		speed = max(-max_change_by_speed, min(speed, max_change_by_speed))
		emit_signal("current_speed", speed)
		pause_speed = 3
		
		
func fix_position(last_event_relative):
	if style == MODE.Horizontal:
		slider_button.rect_position.x = max(0, min(slider_button.rect_position.x,
			background.rect_size.x - slider_button.rect_size.x))
	else:
		slider_button.rect_position.y = max(0, min(slider_button.rect_position.y,
			background.rect_size.y - slider_button.rect_size.y))
	if warp_scroll:
		var warp = false
		if style == MODE.Horizontal:
			if slider_button.rect_position.x == 0:
				slider_button.rect_position.x = (background.rect_size.x -
					slider_button.rect_size.x - 1)
				warp = true
			elif slider_button.rect_position.x == (background.rect_size.x -
					slider_button.rect_size.x):
				slider_button.rect_position.x = 1
				warp = true
		else:
			if slider_button.rect_position.y == 0:
				slider_button.rect_position.y = (background.rect_size.y -
					slider_button.rect_size.y - 1)
				warp = true
			elif slider_button.rect_position.y == (background.rect_size.y -
					slider_button.rect_size.y):
				slider_button.rect_position.y = 1
				warp = true
		if warp:
			var p
			if style == MODE.Horizontal:
				p = Vector2(slider_button.rect_position.x +
					slider_button.rect_size.x * 0.5,
					get_global_mouse_position().y)
			else:
				p = Vector2(get_global_mouse_position().x,
					slider_button.rect_position.y +
					slider_button.rect_size.y * 0.5)
			drag = false
			Input.warp_mouse_position(p)
			drag = p
		else:
			drag = get_global_mouse_position()

func set_current_value():
	var value
	if direction == -1: # to left
		if style == MODE.Horizontal:
			value = slider_button.rect_position.x
		else:
			value = slider_button.rect_position.y
	else:
		if style == MODE.Horizontal:
			value = slider_button.rect_position.x + slider_button.rect_size.x
		else:
			value = slider_button.rect_position.y + slider_button.rect_size.y
	var istop
	if style == MODE.Horizontal:
		istop = background.rect_size.x
	else:
		istop = background.rect_size.y
	current_value = get_real_value(value, 0, istop, min_value, max_value)
	emit_signal("value_changed", current_value)
	
func get_real_value(value, istart, istop, ostart, ostop) -> float:
	var div = istop - istart
	if div == 0: div = 1
	return (ostart + (ostop - ostart) * ((value - istart) / div))
	


func _process(delta: float) -> void:
	if drag and !Input.is_mouse_button_pressed(BUTTON_LEFT):
		drag = false
		
	if pause_speed > 0:
		pause_speed -= 1
		if pause_speed == 0:
			speed = 0



func _on_background_item_rect_changed() -> void:
	if !slider_button: set_initial_variables()
	set_button_in_mid()
