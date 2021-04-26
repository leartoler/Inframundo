extends TextureButton

func _ready() -> void:
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	if is_disabled():
		for child in get_children():
			child.modulate.a = 0.5

func set_disabled(value) -> void:
	.set_disabled(value)
	for child in get_children():
		if value:
			child.modulate.a = 0.5
		else:
			child.modulate.a = 1.0
		
func _on_mouse_entered() -> void:
	for child in get_children():
		if !is_disabled():
			child.modulate = Color.orange
		else:
			child.modulate = Color.white
			child.modulate.a = 0.5
		
func _on_mouse_exited() -> void:
	for child in get_children():
		child.modulate = Color.white
		if !is_disabled():
			child.modulate.a = 1
		else:
			child.modulate.a = 0.5
