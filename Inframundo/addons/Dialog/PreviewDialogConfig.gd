tool
extends PopupDialog

onready var message_box = $Main.find_node("MessageBox")
onready var main_node = $Main
onready var full_character_images = $FullCharacterImages

var message_contents
var lang_data
var images = {}
var effects = []

func _ready():
	set_default_message()
	message_box.is_in_editor = true
	message_box.visible = false
	message_box.connect("perform_action", self, "perform_action")

func clear():
	images.clear()
	effects.clear()
	for child in full_character_images.get_children():
		child.queue_free()

func set_default_message() -> void:
	message_contents = "[face img=icon.png flip=False color=ffffffff animation=1][show_box_name type=0 sub_type=2 name=Left■Person][show_box_name type=1 sub_type=2 name=Right■Person][zoom start=1 end=0.5 time=4.5 loop=0]Preview Configuration[/zoom]"

func set_config(config, folders) -> void:
	message_box.folders = folders
	message_box.set_config(config)
	yield(get_tree(),"idle_frame")
	full_character_images.rect_size = main_node.rect_size
	full_character_images.rect_position = main_node.rect_position


func _on_MessageMarginContainer_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		hide()
		emit_signal("popup_hide")


func _on_PreviewDialogConfig_visibility_changed():
	if message_box != null:
		clear()
		message_box.clear()
		if visible and message_box != null:
			preview_message(message_contents)
			lang_data = get_tree().get_nodes_in_group("_MainDialogEditor_")[0].get("DATA")
		elif message_box != null:
			message_box.visible = false
			set_default_message()


func _on_MessageBox_text_processed():
	message_box.start()
	message_box.set_process(true)

func preview_message(message : String) -> void:
	message_box.clear()
	message_box.visible = true
	message_box.process_text(message)

func perform_action(data):
	match data.name:
		"face":
			var obj = main_node.find_node("Face")
			obj.flip_h = data.parameters.flip
			var path = data.parameters.img
			obj.texture = message_box.get_cache_data(path)
			obj.visible = true
			obj.modulate = data.parameters.color
			obj.modulate.a = 1
			obj.rect_scale = Vector2.ONE
			if Engine.editor_hint:
				property_list_changed_notify()
			create_animation(obj, data)
		"show_box_name":
			var player_name
			match data.parameters.sub_type:
				0: # Use Player
					if lang_data.characters.size() - 1 >= data.parameters.id:
						player_name = lang_data.characters[data.parameters.id].name
				1: # Use Variable
					if lang_data.variables.size() - 1 >= data.parameters.id:
						player_name = lang_data.variables[data.parameters.id].value
				2 : # Use Parameters Name
					player_name = data.parameters.name.replace("■", " ")
			if player_name != null:
				var obj
				if data.parameters.type == 0:
					obj = main_node.find_node("NameBoxLeft")
				else:
					obj = main_node.find_node("NameBoxRight")
				obj.set_text(player_name)
				yield(obj, "text_changed")
				if data.parameters.type == 0:
					obj.rect_position = Vector2(0, - obj.rect_size.y)
				else:
					obj.rect_position = Vector2(main_node.rect_size.x -
						obj.rect_size.x, - obj.rect_size.y)
				obj.fade(1)
				if Engine.editor_hint:
					property_list_changed_notify()
		"character":
			var texture = message_box.get_cache_data(data.parameters.img)
			var s = Sprite.new()
			s.texture = texture
			s.self_modulate = data.parameters.color
			s.flip_h = data.parameters.flip
			s.z_index = -1 if data.parameters.mode == 0 else 0
			s.offset = data.parameters.offset
			s.scale = data.parameters.scale
			var size = s.texture.get_data().get_size() * s.scale
			s.position.x = main_node.rect_size.x / 10 * \
				int(data.parameters.pos) + size.x * 0.5
			s.position.y = main_node.rect_size.y - size.y * 0.5
			if images.has(data.parameters.id):
				full_character_images.remove_child(images[data.parameters.id])
				images[data.parameters.id].queue_free()
			images[data.parameters.id] = s
			full_character_images.add_child(s)
			create_animation(s, data)
		"remove_image":
			match data.parameters.type:
				0: # Face
					var obj = main_node.find_node("Face")
					obj.texture = null
				1: # Character
					if images.has(data.parameters.id):
						images[data.parameters.id].queue_free()
						images.erase(data.parameters.id)
		"remove_box_name":
			var obj
			if data.parameters.type == 0:
				obj = main_node.find_node("NameBoxLeft")
			else:
				obj = main_node.find_node("NameBoxRight")
			obj.fade(0)
		"image_effect":
			var obj = null
			match data.parameters.image_type:
				0:
					obj = main_node.find_node("Face")
				1:
					if images.has(data.parameters.id):
						obj = images[data.parameters.id]
				2:
					obj = main_node.find_node("Dialog")
			if obj != null:
				var effect = {}
				if obj is Sprite:
					effect.start_position = obj.position
					effect.start_scale = obj.scale
					effect.start_angle = obj.rotation_degrees
				else:
					effect.start_position = obj.rect_position
					effect.start_scale = obj.rect_scale
					effect.start_angle = obj.rect_rotation
				effect.obj = obj
				effect.start_modulate = obj.modulate
				effect.current_time = 0
				effect.process = true
				for key in data.parameters.keys():
					if key != "ImmediateEffect" and key != "id" \
						and key != "image_type":
						effect[key] = data.parameters[key]
				effects.append(effect)
		"emit_signal":
			if has_signal(lang_data.signals[data.parameters.id]):
				print("Signal Emitted: %s" % lang_data.signals[data.parameters.id])
		"set_config":
			var id = data.parameters.id
			if lang_data.message_config.has(id):
				message_box.set_config(
					lang_data.message_config[id].config)
				yield(message_box, "configured")
				for i in 6:
					yield(get_tree(),"idle_frame")
				message_box.resume()

func create_animation(obj, data):
	var animation_time = 0.25
	var vi; var vf;
	match data.parameters.animation:
		0: # Instant
			pass
		1: # Fade-in
			vi = obj.modulate
			vi.a = 0
			vf = obj.modulate
			vf.a = 1
			obj.modulate.a = 1
			add_animation(obj, "modulate", vi, vf, animation_time)
		2, 3: # Zoom-In / Zoom-Out
			var property = "scale" if obj is Sprite else "rect_scale"
			if data.parameters.animation == 2:
				vi = Vector2(0.0, 0.0)
			else:
				if obj is Sprite:
					vi = obj.scale * 1.5
				else:
					vi = obj.rect_scale * 1.5
			vf = obj.get(property)
			obj.set(property, vi)
			add_animation(obj, property, vi, vf, animation_time)
		4, 5: # Fade-in + Displacement Left To Right | Right To Left
			vi = obj.modulate
			vi.a = 0
			vf = obj.modulate
			vf.a = 1
			obj.modulate.a = 1
			add_animation(obj, "modulate", vi, vf, animation_time)
			if obj is Sprite:
				if data.parameters.animation == 4:
					vi = obj.position - Vector2(50, 0)
				else:
					vi = obj.position + Vector2(50, 0)
				vf = obj.position
				add_animation(obj, "position", vi, vf, animation_time)
			else:
				if data.parameters.animation == 4:
					vi = obj.rect_position - Vector2(50, 0)
				else:
					vi = obj.rect_position + Vector2(50, 0)
				vf = obj.rect_position
				add_animation(obj, "rect_position", vi, vf, animation_time)
		6: # Custom effect
			if data.parameters.has("params"):
				var params = data.parameters.params.split(",")
				# offset, scale, modulate, angle, duration
				if params.size() == 7:
					var _offset = Vector2(float(params[0]), float(params[1]))
					var _scale = Vector2(float(params[2]), float(params[3]))
					var _modulate = Color(params[4])
					var _angle = float(params[5])
					var _time = float(params[6])
					if _offset != Vector2.ZERO:
						if obj is Sprite:
							vi = obj.position - _offset
							vf = obj.position
							add_animation(obj, "position", vi, vf, _time)
						else:
							vi = obj.rect_position - _offset
							vf = obj.rect_position
							add_animation(obj, "rect_position", vi, vf, _time)
					vi = _scale
					if obj is Sprite:
						vf = obj.scale
						if _scale != vf:
							add_animation(obj, "scale", vi, vf, _time)
					else:
						vf = obj.rect_scale
						if _scale != vf:
							add_animation(obj, "rect_scale", vi, vf, _time)
					if _modulate != Color(1,1,1,1):
						vi = _modulate
						vf = obj.modulate
						vf.a = 1
						add_animation(obj, "modulate", vi, vf, _time)
					if _angle != 0.0 and _angle != 0:
						vi = _angle
						if obj is Sprite:
							vf = obj.rotation_degrees
							add_animation(obj, "rotation_degrees", vi, vf, _time)
						else:
							vf = obj.rect_rotation
							add_animation(obj, "rect_rotation", vi, vf, _time)

func add_animation(node, property, start_value, end_value, time):
	node.set(property, start_value)
	var tween = main_node.find_node("TweenNode")
	node.set(property, start_value)
	tween.interpolate_property(node,
		property, start_value, end_value, time,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.reset(node, property)
	tween.start()

func update_effects(delta):
	for effect in effects:
		if !effect.process: continue
		match effect.effect_id:
			"shake": update_shake_effect(effect, delta)
			"change_opacity": update_opacity_effect(effect, delta)
			"modulate_by_color": update_color_effect(effect, delta)
			"move_to_position": update_movement_effect(effect, delta)
			"change_zoom": update_zoom_effect(effect, delta)
			"rotate": update_rotation_effect(effect, delta)

func update_shake_effect(effect, delta):
	if effect.obj == null or effect.obj.is_queued_for_deletion():
		effects.erase(effect)
		return
	effect.current_time += delta
	var offset_x = rand_range(-effect.level, effect.level)
	var offset_y = rand_range(-effect.level, effect.level)
	offset_x *= effect.rate * 50
	var property = "position" if effect.obj is Sprite else "rect_position"
	var pos = effect.start_position + Vector2(offset_x, offset_y) * 2
	effect.obj.set(property, pos)
	if effect.current_time >= effect.time:
		effect.process = false
		effect.obj.set(property, effect.start_position)

func update_opacity_effect(effect, delta):
	if effect.obj == null or effect.obj.is_queued_for_deletion():
		effects.erase(effect)
		return
	if !effect.has("end_value"):
		effect.end_value = effect.obj.modulate
		effect.end_value.a = effect.opacity / 100.0
	effect.current_time += delta
	var v = lerp(effect.start_modulate, effect.end_value,
		effect.current_time / effect.time)
	effect.obj.modulate = v
	if effect.current_time >= effect.time:
		effect.process = false
		effect.obj.modulate = effect.end_value

func update_color_effect(effect, delta):
	if effect.obj == null or effect.obj.is_queued_for_deletion():
		effects.erase(effect)
		return
	if !effect.has("end_value"):
		effect.end_value = effect.color
	effect.current_time += delta
	var v = lerp(effect.start_modulate, effect.end_value,
		effect.current_time / effect.time)
	effect.obj.modulate = v
	if effect.current_time >= effect.time:
		effect.process = false
		effect.obj.modulate = effect.end_value

func update_movement_effect(effect, delta):
	if effect.obj == null or effect.obj.is_queued_for_deletion():
		effects.erase(effect)
		return
	var property = "position" if effect.obj is Sprite else "rect_position"
	if !effect.has("end_value"):
		effect.end_value = effect.obj.get(property) + \
			Vector2(effect.x, effect.y)
	effect.current_time += delta
	var v = lerp(effect.start_position, effect.end_value,
		effect.current_time / effect.time)
	effect.obj.set(property, v)
	if effect.current_time >= effect.time:
		effect.process = false
		effect.obj.set(property, effect.end_value)

func update_zoom_effect(effect, delta):
	if effect.obj == null or effect.obj.is_queued_for_deletion():
		effects.erase(effect)
		return
	var property = "scale" if effect.obj is Sprite else "rect_scale"
	if !effect.has("end_value"):
		effect.end_value = Vector2(effect.x, effect.y)
	effect.current_time += delta
	var v = lerp(effect.start_scale, effect.end_value,
		effect.current_time / effect.time)
	effect.obj.set(property, v)
	if effect.current_time >= effect.time:
		effect.process = false
		effect.obj.set(property, effect.end_value)

func update_rotation_effect(effect, delta):
	if effect.obj == null or effect.obj.is_queued_for_deletion():
		effects.erase(effect)
		return
	var property = "rotation_degrees" if effect.obj is Sprite else "rect_rotation"
	if !effect.has("end_value"):
		effect.end_value = effect.angle
	effect.current_time += delta
	var v = lerp(effect.start_angle, effect.end_value,
		effect.current_time / effect.time)
	effect.obj.set(property, v)
	if effect.current_time >= effect.time:
		effect.process = false
		effect.obj.set(property, effect.end_value)

func _process(delta):
	if message_box != null and message_box.running:
		update_effects(delta)
