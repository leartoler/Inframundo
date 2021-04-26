tool
extends Control

var child
var drag = null
var can_update_by_child = true

func _ready() -> void:
	update()

func set_child(_child):
	child = _child
	rect_global_position = child.rect_global_position
	rect_size = child.rect_size
	rect_min_size = rect_size
	child.connect("item_rect_changed", self, "update_by_child")

func update_by_child():
	if child != null and can_update_by_child:
		rect_global_position = child.rect_global_position
		rect_size = child.rect_size

func _on_ResizerControl_draw() -> void:
	for i in get_child_count() - 1:
		var node1 = get_child(i)
		var node2 = get_child(i+1)
		draw_line(
			node1.rect_position +node1.rect_size * 0.5,
			node2.rect_position + node2.rect_size * 0.5,
			Color.orange
		)
	var node1 = get_child(get_child_count() - 1)
	var node2 = get_child(0)
	draw_line(
		node1.rect_position +node1.rect_size * 0.5,
		node2.rect_position + node2.rect_size * 0.5,
		Color.orange
	)

func change_rect(pos, size):
	if rect_size + size < rect_min_size: return
	var m = rect_size + rect_position
	rect_size += size
	if rect_size + rect_position + pos <= m:
		rect_position += pos
	if child != null:
		can_update_by_child = false
		child.rect_position = rect_position
		child.rect_size = rect_size
		can_update_by_child = true
	
func fix_points():
	var mod = Vector2(8, 8)
	get_child(0).rect_position = Vector2(0, 0) - mod
	get_child(1).rect_position = Vector2(rect_size.x * 0.5, 0) - mod
	get_child(2).rect_position = Vector2(rect_size.x, 0) - mod
	get_child(7).rect_position = Vector2(0, rect_size.y * 0.5) - mod
	get_child(3).rect_position = Vector2(rect_size.x, rect_size.y * 0.5) - mod
	get_child(6).rect_position = Vector2(0, rect_size.y) - mod
	get_child(5).rect_position = Vector2(rect_size.x * 0.5, rect_size.y) - mod
	get_child(4).rect_position = Vector2(rect_size.x, rect_size.y) - mod
	
func _input(event: InputEvent) -> void:
	if drag != null and event is InputEventMouseMotion:
		match drag:
			"topleft":
				change_rect(
					event.relative,
					-event.relative
				)
			"top":
				change_rect(
					Vector2(0, event.relative.y),
					Vector2(0, -event.relative.y)
				)
			"topright":
				change_rect(
					Vector2(0, event.relative.y),
					Vector2(event.relative.x, -event.relative.y)
				)
			"left":
				change_rect(
					Vector2(event.relative.x, 0),
					Vector2(-event.relative.x, 0)
				)
			"right":
				change_rect(
					Vector2(0, 0),
					Vector2(event.relative.x, 0)
				)
			"bottomleft":
				change_rect(
					Vector2(event.relative.x, 0),
					Vector2(-event.relative.x, event.relative.y)
				)
			"bottom":
				change_rect(
					Vector2(0, 0),
					Vector2(0, event.relative.y)
				)
			"bottomright":
				change_rect(
					Vector2(0, 0),
					Vector2(event.relative.x, event.relative.y)
				)


func _on_TopLeft_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drag = "topleft" if event.is_pressed() else null


func _on_Top_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drag = "top" if event.is_pressed() else null


func _on_TopRight_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drag = "topright" if event.is_pressed() else null


func _on_Right_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drag = "right" if event.is_pressed() else null


func _on_BottomRight_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drag = "bottomright" if event.is_pressed() else null


func _on_Bottom_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drag = "bottom" if event.is_pressed() else null


func _on_BottomLeft_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drag = "bottomleft" if event.is_pressed() else null


func _on_Left_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drag = "left" if event.is_pressed() else null


func _on_ResizerControl_item_rect_changed() -> void:
	fix_points()
	update()
