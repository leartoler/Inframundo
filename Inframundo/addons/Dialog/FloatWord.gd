extends Control

var start_position = Vector2()

func _ready() -> void:
	var label = find_node("Label")
	label.rect_pivot_offset = label.rect_size * 0.5
	rect_position = start_position - label.rect_size
	find_node("Animator").play("start")

func set_text(text):
	var label = find_node("Label")
	label.text = text
