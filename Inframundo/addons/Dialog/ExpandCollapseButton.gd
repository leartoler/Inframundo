extends Control

export(Texture)	var expanded_icon
export(Texture) var collapse_icon

enum STATES {expanded, collapsed}

var state = STATES.expanded

signal collapse(value)

func _on_TextureButton_button_down() -> void:
	var node = find_node("TEXTURE")
	if state == STATES.expanded:
		state = STATES.collapsed
		node.margin_left = -7
		node.margin_right = 9
		node.texture = collapse_icon
		emit_signal("collapse", true)
	else:
		state = STATES.expanded
		node.texture = expanded_icon
		node.margin_left = -7
		node.margin_right = 8
		emit_signal("collapse", false)
