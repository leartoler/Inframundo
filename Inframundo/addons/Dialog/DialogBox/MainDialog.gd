tool
extends NinePatchRect


onready var parent
var action = true
var animation = null
var folders = null

func _ready() -> void:
	action = false
	yield(get_tree(), "idle_frame")
	parent = get_parent()
	yield(get_tree(), "idle_frame")
	action = true

func set_folders(_folders):
	folders = _folders
	var main = get_parent()
	main.find_node("MessageBox").folders = folders
	main.find_node("NameBoxLeft").folders = folders
	main.find_node("NameBoxRight").folders = folders
	main.find_node("ResumeButton").folders = folders
	main.find_node("SelectOptions").folders = folders

func _on_NameBoxRight_text_changed() -> void:
	if !action or parent==null: return
	action = false
	var obj = parent.find_node("NameBoxRight")
	obj.margin_left = 0
	obj.margin_top = 0
	obj.margin_right = 0
	obj.margin_bottom = 0
	obj.rect_position = Vector2(parent.rect_size.x - obj.rect_size.x,
		-obj.rect_size.y)
	yield(get_tree(), "idle_frame")
	action = true


func _on_NameBoxLeft_text_changed() -> void:
	if !action or parent==null: return
	action = false
	var obj = parent.find_node("NameBoxLeft")
	obj.margin_left = 0
	obj.margin_top = 0
	obj.margin_right = 0
	obj.margin_bottom = 0
	obj.rect_position = Vector2(0, -obj.rect_size.y)
	yield(get_tree(), "idle_frame")
	action = true

func _process(delta: float) -> void:
	if animation != null and get_parent().visible:
		if animation.max_frames != Vector2.ONE:
			animation.time += delta
			if animation.time >= animation.delay:
				animation.time = 0
				animation.current_frame.x += 1
				if animation.current_frame.x >= animation.max_frames.x:
					animation.current_frame.x = 0
					animation.current_frame.y += 1
					if animation.current_frame.y >= animation.max_frames.y:
						animation.current_frame.y = 0
				update_texture()
						
func update_texture():
	if animation != null and texture != null:
		var size = texture.get_data().get_size()
		var w = size.x / animation.max_frames.x
		var h = size.y / animation.max_frames.y
		region_rect.position.x = w * animation.current_frame.x
		region_rect.position.y = w * animation.current_frame.y
		region_rect.size.x = w
		region_rect.size.y = h
