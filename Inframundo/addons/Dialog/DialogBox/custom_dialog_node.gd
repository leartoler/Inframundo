tool
extends CanvasLayer
class_name DialogBox

export(String, FILE, "lang.data") var DATA setget parse_data
export(String, FILE, "*.lang") var default_lang setget parse_lang
export(int, -1, 99999) var preview_message_id = -1 setget preview_message
enum types {DATA_TYPE, Characters, Variables, Terms, Signals}
export(types) var print_data setget print_data
export(bool) var reload_language setget reload_language
export(bool) var print_debugs_messages = false

onready var answer_panel = preload("res://addons/Dialog/DialogBox/SimpleTextPanel.tscn")

var main_node
var message_box
var timer
var sound_player
var full_character_images

var current_lang = ""
var lang_data = {}

var show_message_timer = 0

var current_signals_added = []

var images = {}
var effects = []
var current_message

var audio_index = 1

signal parse_data_completed()

func show_editor_print(text):
	if print_debugs_messages and Engine.editor_hint:
		print(text)
		

func print_data(id):
	if lang_data.size() == 0: return
	match id:
		1: print(lang_data.characters)
		2: print(lang_data.variables)
		3: print(lang_data.terms)
		4: print(lang_data.signals)

func reload_language(value):
	var id = preview_message_id
	var c = current_lang
	parse_data(DATA)
	yield(self, "parse_data_completed")
	current_lang = c
	if current_lang.length() > 0:
		parse_lang(current_lang, false)
		show_editor_print("language reloaded (%s)" % current_lang)
	elif default_lang.length() > 0:
		parse_lang(default_lang, true)
		show_editor_print("language reloaded (%s)" % default_lang)
	set("preview_message_id", id)
	yield(get_tree(), "idle_frame")
	

func _enter_tree():
	for i in 2:
		yield(get_tree(), "idle_frame") # Wait 2 frames to void errors
	if main_node == null:
		if find_node("Main") == null:
			main_node = load(
				"res://addons/Dialog/DialogBox/DialogBox.tscn").instance()
			add_child(main_node)
			main_node.set_owner(self)
#			var tween = Tween.new()
#			tween.name = "TweenNode"
#			add_child(tween)
#			tween.set_owner(self)
		else:
			main_node = find_node("Main")
	pause_mode = Node.PAUSE_MODE_PROCESS

func _ready() -> void:
	randomize()
	if !Engine.editor_hint and \
		get_tree().get_nodes_in_group("_MainDialogEditor_").size() == 0:
		if DATA.length() == 0 or default_lang.length() == 0:
			push_error("LANG DATA is missing")
			assert(false)
			return
		else:
			for s in lang_data.signals:
				if !has_user_signal(s):
					add_user_signal(s)
		set_initial_variables()
	for i in 3:
		yield(get_tree(), "idle_frame") # Wait 3 frames to void errors
	set("preview_message_id", -1)
	if default_lang.length() > 0: current_lang = default_lang
	yield(get_tree(), "idle_frame")
	main_node.find_node("Tween").start()
	for i in 6:
		yield(get_tree(), "idle_frame")

func set_initial_variables():
	if get_child_count() > 0:
		main_node = get_child(0)
		if main_node != null:
			message_box = main_node.find_node("MessageBox")
			message_box.set_parent(self)
			if !message_box.is_connected("perform_action", self,
				"perform_action"):
				message_box.connect("perform_action", self,
					"perform_action")
			if !message_box.is_connected("all_text_shown", self,
				"show_next_text"):
				message_box.connect("all_text_shown", self,
					"show_next_text")
			timer = main_node.find_node("Timer")
			sound_player = main_node.find_node("AudioStreamPlayer")
			full_character_images = main_node.find_node(
				"full_character_images")
			var opts = main_node.find_node("SelectOptions")
			if !opts.is_connected("request_play_audio", self, "play_audio"):
				opts.connect("request_play_audio", self, "play_audio")
			if !opts.is_connected("item_selected", self, "select_choice"):
				opts.connect("item_selected", self, "select_choice")

func play_audio(path, audio_stream_id = null):
	if message_box == null or main_node == null: return
	var audio_player
	if path.find("res://") == -1 and lang_data.size() != 0:
		path = lang_data.folders.sounds + path
	var file = message_box.get_cache_data(path)
	if audio_stream_id == null:
		if file != null:
			audio_player = main_node.find_node(
				"AudioStreamPlayer%s" % audio_index)
	else:	
		audio_player = main_node.find_node(
				"AudioStreamPlayer%s" % audio_stream_id)
	if audio_player != null:
		audio_player.stream = file
		audio_player.play()
		audio_index += 1
		if audio_index > 5: audio_index = 1
		

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
				emit_signal(lang_data.signals[data.parameters.id])
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
	tween.interpolate_property(node,
		property, start_value, end_value, time,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.reset(node, property)
	tween.start()


func parse_data(data_path):
	for s in current_signals_added:
		if has_user_signal(s):
			pass
			
	DATA = ""
	default_lang = ""
	set("preview_message_id", -1)
	property_list_changed_notify()
	if data_path == null or (data_path is String and data_path == ""):
		return false
	lang_data = {}
	var data
	var f = File.new()
	if f.file_exists(str(data_path)):
		f.open(data_path, f.READ)
		data = f.get_var()
		f.close()
		if data is Dictionary:
			var valid_keys = ["characters", "dialogs", "langs", "default_lang",
				"message_config", "signals", "terms", "variables", "editor_config"]
			for key in valid_keys:
				if !data.has(key):
					show_editor_print("invalid data")
					return false
			for key in data.keys():
				if !valid_keys.has(key):
					data.erase(key)
			var dialogs_invalid_key = ["collapsed", "connections",
				"frame_color", "id", "name", "position", "probability",
				"size", "text", "title", "type"]
			for key in dialogs_invalid_key:
				data.dialogs.erase(key)
			for value in data.message_config.values():
				for key in value.keys():
					if key != "config": 
						value.erase(key)
					else:
						value[key].erase("contents_expanded")
			data.folders = data.editor_config.folders
			data.erase("editor_config")
			lang_data  = data
			DATA = data_path
			show_editor_print("DATA installed.")
			if data_path is String:
				var lang_filename = data_path.get_base_dir() + "/" + \
					lang_data.langs[lang_data.default_lang].name + ".lang"
				if lang_data.signals.size() > 0:
					for s in lang_data.signals:
						if !has_user_signal(s):
							add_user_signal(s)
					show_editor_print("signals added")
					show_editor_print(lang_data.signals)
				parse_lang(lang_filename)
			if !is_inside_tree(): return
			if Engine.editor_hint:
				property_list_changed_notify()
			yield(get_tree(), "idle_frame")
			emit_signal("parse_data_completed")
			return true
		show_editor_print("invalid data")
		yield(get_tree(), "idle_frame")
		emit_signal("parse_data_completed")
		return false

func parse_lang(lang_path, is_default_lang=true):
	var last_preview_id = preview_message_id
	set("preview_message_id", -1)
	property_list_changed_notify()
	if is_default_lang:
		default_lang = ""
	current_lang = ""
	if DATA == "":
		show_editor_print("No data loaded")
		return false
	var f = File.new()
	if f.file_exists(lang_path):
		f.open(lang_path, f.READ)
		var data = f.get_var()
		f.close()
		if data is Dictionary:
			for key in data:
				if !lang_data.dialogs.has(key):
					show_editor_print("invalid lang")
					return false
			if is_default_lang:
				default_lang = lang_path
			current_lang = lang_path
			lang_data.dialogs_text = data
			show_editor_print(
				"Messages installed (%s): %s" % [lang_path.get_file(),
				PoolStringArray(data.keys()).join(", ")])
			set("preview_message_id", last_preview_id)
			property_list_changed_notify()
			return true
	show_editor_print("invalid lang")
	return false

func change_language(path):
	parse_lang(path, false)

func preview_message(id):
	if !is_inside_tree(): return
	if message_box == null:
		set_initial_variables()
#		property_list_changed_notify()
#		if get_tree() == null: return
#		while message_box == null:
#			if get_tree() == null: break
#			yield(get_tree(), "idle_frame")
	if message_box == null: return
	message_box.clear()
	yield(message_box, "text_cleared")
	get_node("Main").visible = false
	message_box.set_parent(self)
	if lang_data.size() == 0:
		preview_message_id = -1
	else:
		preview_message_id = id
	show_message_timer = 0.03



func set_variable(variable_name, new_value):
	if lang_data.size():
		for _var in lang_data.variables:
			if _var.name == variable_name:
				match _var.type:
					0: # string
						if typeof(new_value) == TYPE_STRING:
							_var.value = new_value
					1: # int
						if typeof(new_value) == TYPE_INT:
							_var.value = new_value
					2: # float
						if typeof(new_value) == TYPE_REAL:
							_var.value = new_value
					3: # bool
						if typeof(new_value) == TYPE_BOOL:
							_var.value = new_value

func get_variable(id):
	if lang_data.variables.size() > id:
		return lang_data.variables[id].value
	return ""

func get_term(id):
	for term in lang_data.terms:
		if term.id == id:
			var lang_name = current_lang.get_file().trim_suffix(".lang")
			for i in lang_data.langs.size():
				if lang_data.langs[i].name == lang_name:
					return term.values[i]
	return ""

func get_string(message_id):
	if lang_data.size() == 0 or !lang_data.has("dialogs_text") or \
		!lang_data.dialogs_text.has(message_id):
		return ""
	return lang_data.dialogs_text[message_id][0]

func get_variable_data() -> Array:
	if lang_data.size() > 0:
		return lang_data.variables
	else:
		return []

func set_variable_data(data) -> void:
	if lang_data.size() > 0:
		lang_data.variables = data

func _process(delta: float) -> void:
	if message_box == null:
		set_initial_variables()
		return
	if show_message_timer > 0:
		show_message_timer -= delta
		if show_message_timer <= 0:
			show_message(preview_message_id)
	if message_box != null and message_box.running:
		update_effects(delta)

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

func set_variable_by_message(variable_id):
	if Engine.editor_hint:
		print("The current id belongs to a variable dialog.\n" +
			"This dialog has not any effect while is running in the Editor")
		return
	if lang_data.size() == 0 or !lang_data.has("dialogs_text") or \
		!lang_data.dialogs.has(variable_id): return
	var data = lang_data.dialogs[variable_id]
	if data.type != "variable": return
	for v1 in data.set_variables:
		for v2 in lang_data.variables:
			if v2.name == v1.name:
				match v1.type:
					0, 3: v2.value = v1.value # String or Bool
					1, 2: # Int or Float
						match v1.operation_type:
							0: v2.value = v1.value # Set
							1: v2.value += v1.value # Add
							2: v2.value -= v1.value # Minus
							3: v2.value *= v1.value # Multiply
							4: if v1.value != 0: v2.value /= v1.value # Divide
				break

func update_variable_by_message(mode = 0):
	if current_message != null:
		if current_message.type != "message": return
		if (mode == 0 and current_message.variables_behavior == 0) or \
			(mode == 1 and current_message.variables_behavior == 1):
			for variable in current_message.set_variables:
				set_variable_by_message(variable)

func get_contition_result(conditions) -> bool:
	var command = ""
	for condition in conditions:
		var var_exists = false
		var partial_command = "" if command.length() == 0 else " "
		# Get AND or OR
		if condition.extra_condition != null:
			if condition.extra_condition == 0:
				partial_command += "and "
			else:
				partial_command += "or "
		# Get first value
		for _var in lang_data.variables:
			if _var.name == condition.variables.a.name:
				partial_command += "\"%s\" " % _var.value
				var_exists = true
				break
		if !var_exists: continue
		# Get operation symbol
		var operation
		match condition.variables.a.type:
			0: operation = ["==", "<", ">", "!="] # String
			1, 2: operation = ["==", "<", "<=", ">", ">=", "!="] # Int and Float
			3: operation = ["==", "!="] # Bool
		partial_command += "%s " % operation[condition.check_type]
		# get second value
		if condition.value_type == 0 and condition.variables.b != null:
			var_exists = false
			for _var in lang_data.variables:
				if _var.name == condition.variables.b.name:
					partial_command += "\"%s\"" % _var.value
					var_exists = true
					break
			if !var_exists: continue
		else:
			partial_command += "\"%s\"" % condition.value
		command += partial_command
	var expression = Expression.new()
	if expression.parse(command) == OK:
		var result = expression.execute()
		if not expression.has_execute_failed():
			return result
	return false


func show_next_text(ids = null):
	#set_initial_variables()
	if current_message == null: return
	if current_message.type == "message":
		# update variables when current message is completed
		update_variable_by_message(1)
		# Check if message has choices and show them
		if current_message.choices.size() > 0:
			var node = main_node.find_node("SelectOptions")
			var config
			if current_message.config == null:
				config = lang_data.message_config[0].config
			else:
				config = lang_data.message_config[current_message.config].config
			if answer_panel == null:
				answer_panel = load(
					"res://addons/Dialog/DialogBox/SimpleTextPanel.tscn")
			for choice in current_message.choices:
				node.add_answer(choice.text)
			node.action_keys = config.input_actions
			node.start()
			message_box.display_last_page()
			return
		else:
			var id = get_next_message(current_message.next_text)
			show_message(id)
	elif current_message.type == "condition":
		var id = get_next_message(current_message.next)
		show_message(id)
		return


func get_next_message(data):
	var messages = {
		"conditions": [],
		"texts"		: []
	}
	for item in data:
		if !lang_data.dialogs.has(item.id): continue
		if lang_data.dialogs[item.id].type == "condition":
			if get_contition_result(lang_data.dialogs[item.id].conditions):
				messages.conditions.append(item)
		else:
			messages.texts.append(item)
	var result
	if messages.conditions.size() > 0:
			var weight = 1
			for condition in messages.conditions:
				weight += condition.probability
			var dice = rand_range(0, weight)
			var accu = 0
			for item in messages.conditions:
				accu += item.probability
				if accu >= dice:
					result = item.id
					break
			if result == null:
				var id = randi() % messages.conditions.size()
				result = messages.conditions[id].id
	if result == null:
		if messages.texts.size() > 0:
			var weight = -1
			for item in messages.texts:
				weight += item.probability
			var dice = rand_range(0, weight)
			var accu = 0
			for item in messages.texts:
				accu += item.probability
				if accu >= dice:
					result = item.id
					break
			if result == null:
				var id = randi() % messages.texts.size()
				result = messages.texts[id]
	return result

func select_choice(index):
	if current_message == null or current_message.type != "message": return
	if current_message.choices.size() - 1 < index: return
	var id = get_next_message(current_message.choices[index].next)
	if id != null:
		show_message(id)
	elif current_message.next_text.size() > 0:
		id = get_next_message(current_message.next_text)
		if id != null:
			show_message(id)
		else:
			stop_message()
	else:
		stop_message()

func clear():
	yield(get_tree(), "idle_frame")
	message_box.clear()
	main_node.find_node("SelectOptions").clear()


func stop_message():
	effects.clear()
	for image in images.values():
		if is_instance_valid(image):
			image.queue_free()
	images.clear()
	message_box.stop()
	main_node.find_node("Face").texture = null
	main_node.find_node("NameBoxLeft").modulate.a = 0
	main_node.find_node("NameBoxRight").modulate.a = 0


func show_message(id):
	set_initial_variables()
	# 1st: Clear
	clear()
	yield(message_box, "text_cleared")
	show_editor_print("Show message id = %s" % id)
	if id == null or id <= -1: # If id < 0 or null return
		get_node("Main").visible = false
		stop_message()
		return
	get_node("Main").visible = true
	# 2nd: Check if id is type "condition" or "variable"
	if lang_data.size() > 0 and lang_data.has("dialogs") and \
		lang_data.dialogs.has(id):
		# if dialog ID is "condition" do this:
		if lang_data.dialogs[id].type == "condition":
			if get_contition_result(lang_data.dialogs[id].conditions):
				if lang_data.dialogs[id].next_text.size() > 0:
					id = get_next_message(lang_data.dialogs[id].next_text)
			else:
				id = null
		# if dialog ID is "variable" do this:
		elif lang_data.dialogs[id].type == "variable":
			set_variable_by_message(id)
			id = null
	if id == null:
		stop_message()
		return
	if lang_data.size() == 0 or !lang_data.has("dialogs_text") or \
		!lang_data.dialogs_text.has(id):
		if Engine.editor_hint:
			message_box.process_text(
				"[color=#ff0000]no message found with id %s" % id)
			yield(message_box, "text_processed")
			message_box.start()
		else:
			stop_message()
		return
	# if not do this another
	current_message = lang_data.dialogs[id]
	# Check if this message edit variables when shown
	update_variable_by_message(0)
	if lang_data.dialogs_text[id][0].length() == 0:
		show_next_text()
		return
	main_node.find_node("Dialog").set_folders(lang_data.folders)
	if current_message.config == null:
		message_box.set_config(lang_data.message_config[0].config)
	else:
		message_box.set_config(
			lang_data.message_config[current_message.config].config)
	yield(message_box, "configured")
	message_box.process_text(lang_data.dialogs_text[id][0])
	yield(message_box, "text_processed")
	message_box.start()
	show_editor_print("message %s started" % id)
