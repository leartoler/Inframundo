extends TextureButton
class_name CustomNodeDot


var type			:= 0 # layer 0 with type 5 match with layer 1 type 5
var layer			:= 0 # 0 => Left, 1 => Right
var color			:= Color.white # Color for dot
var max_connections := 0

signal left_button_pressed(current_dot)
signal right_button_pressed(current_dot)
signal left_button_released(current_dot)
signal right_button_released(current_dot)

func _ready() -> void:
	modulate = color
	
func set_values(_layer: int, _type: int, _color: Color, _max_connections: int)->void:
	layer = _layer
	type = _type
	color = _color
	max_connections = _max_connections
	modulate = color


func _on_CustomNodeDot_mouse_entered() -> void:
	self_modulate = color.contrasted()


func _on_CustomNodeDot_mouse_exited() -> void:
	self_modulate = Color.white


func _on_CustomNodeDot_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				emit_signal("left_button_pressed", self)
			elif event.button_index == BUTTON_RIGHT:
				emit_signal("right_button_pressed", self)
		else:
			if event.button_index == BUTTON_LEFT:
				emit_signal("left_button_released", self)
			elif event.button_index == BUTTON_RIGHT:
				emit_signal("right_button_released", self)
