tool
extends Sprite

var animation = null
var folders = null

func _process(delta: float) -> void:
	if animation != null and visible:
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
	var node = self
	if animation != null and node.texture != null:
		var size = node.texture.get_data().get_size()
		var w = size.x / animation.max_frames.x
		var h = size.y / animation.max_frames.y
		node.region_rect.position.x = w * animation.current_frame.x
		node.region_rect.position.y = h * animation.current_frame.y
		node.region_rect.size.x = w
		node.region_rect.size.y = h
