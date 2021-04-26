tool
extends Container

export(Vector2) var margin = Vector2()
export(int, 0, 1000) var v_separation = 5
export(int, 0, 1000) var h_separation = 5

func _ready() -> void:
	sort()
	
func sort():
	rect_min_size = Vector2()
	var max_x = rect_size.x - margin.x * 2
	var x = margin.x
	var y = margin.y
	var line_height = 0
	for child in get_children():
		line_height = max(line_height, child.rect_size.y)
		if x + child.rect_size.x >= max_x:
			x = margin.x
			y += line_height + v_separation
			line_height = child.rect_size.y
		child.rect_position.x = x
		child.rect_position.y = y
		child.rect_size = Vector2()
		x += child.rect_size.x + h_separation
	rect_min_size.y = y + line_height + 2


func _on_Container_item_rect_changed() -> void:
	sort()


func _on_Container_visibility_changed() -> void:
	sort()
