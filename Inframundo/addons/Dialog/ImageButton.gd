tool
extends Control

export(Texture) var initial_image setget set_initial_texture
export(Color) var edge_normal_color = Color("cccccc") setget change_edge_normal_color
export(Color) var background_normal_color = Color("79999999") setget change_background_normal_color
export(Color) var edge_over_color = Color("cccccc") setget change_edge_over_color
export(Color) var background_over_color = Color("79999999") setget change_background_over_color

var image = null

var animation = {
	"frames"			: Vector2(1, 1),
	"delay"				: 3,
	"current_frame"		: Vector2(0, 0),
	"current_time"		: 0,
	"tile_size"			: null,
}

var patchs
var paths

onready var default_image = preload("res://addons/Dialog/Graphics/search_image.png")

signal get_file(obj)
signal image_changed(obj)
signal image_removed(obj)

func _ready() -> void:
	connect("mouse_entered", self, "on_mouse_entered")
	connect("mouse_exited", self, "on_mouse_exited")
	connect("gui_input", self, "on_gui_input")
	find_node("Panel").set("custom_styles/panel",
	find_node("Panel").get("custom_styles/panel").duplicate(true))

func set_initial_texture(value):
	if value != null and get_node_or_null("Panel/TextureRect") != null:
		initial_image = value
		get_node("Panel/TextureRect").texture = value
		image = value.resource_path.get_file()
	
	

func _process(delta: float) -> void:
	if (animation.frames.x > 1 or animation.frames.y > 1) and \
		animation.tile_size != null:
		if animation.current_time < animation.delay:
			animation.current_time += delta
		else:
			animation.current_time = 0
			animation.current_frame.x += 1
			if animation.current_frame.x >= animation.frames.x:
				animation.current_frame.x = 0
				animation.current_frame.y += 1
				if animation.current_frame.y >= animation.frames.y:
					animation.current_frame.y = 0
			animate()
			
func animate():
	if animation.tile_size != null:
		var rect = Rect2(
			animation.current_frame * animation.tile_size,
			animation.tile_size)
		get_node("Panel/TextureRect").region_rect = rect
			

func change_edge_normal_color(color):
	edge_normal_color = color
	change_panel_style()
	
func change_background_normal_color(color):
	background_normal_color = color
	change_panel_style()
	
func change_edge_over_color(color):
	edge_over_color = color
	
func change_background_over_color(color):
	background_over_color = color
	
func change_panel_style(id = "normal"):
	var node = find_node("Panel")
	if node:
		var style = node.get_stylebox("panel")
		if id == "normal":
			style.border_color = edge_normal_color
			style.bg_color = background_normal_color
		else:
			style.border_color = edge_over_color
			style.bg_color = background_over_color

func on_mouse_entered():
	change_panel_style("over")
	
func on_mouse_exited():
	change_panel_style()


func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and \
		event.is_pressed():
		emit_signal("get_file", self)
		
func load_image(img):
	if img == null: return
	if paths is Dictionary and paths.has("graphics"):
		img = paths.graphics + img.get_file()
	var t
	var f = File.new()
	if f.file_exists(img + ".import"):
		t = load(img)
	elif f.file_exists(img):
		var i = Image.new()
		#ignore-warning:load
		i.load(img)
		t = ImageTexture.new()
		t.create_from_image(i)
	else:
		return
	var node = get_node("Panel/TextureRect")
	if node != null:
		node.texture = t
	image = img.get_file()
	animation.tile_size = t.get_data().get_size() / animation.frames
	emit_signal("image_changed", self)
	
func set_frames(data : Dictionary):
	animation.delay = data.delay
	animation.frames = data.frames
	animation.current_frame = Vector2.ZERO
	animation.current_time = 0
	var node = get_node("Panel/TextureRect")
	if node != null and node.texture != null:
		animation.tile_size = node.texture.get_data().get_size() / animation.frames
	animate()
	
func set_patch(data : Dictionary) -> void:
	return # todo
	var node = get_node("Panel/TextureRect")
	if node:
#		node.patch_margin_bottom = data.patch_margin_bottom
#		node.patch_margin_left = data.patch_margin_left
#		node.patch_margin_right = data.patch_margin_right
#		node.patch_margin_top = data.patch_margin_top
#		node.axis_stretch_horizontal = data.axis_stretch_horizontal
#		node.axis_stretch_vertical = data.axis_stretch_vertical
#		node.draw_center = data.draw_center
		patchs = data
		node.rect_size = rect_size
		find_node("canvas").update()

func set_texture_modulate(color):
	get_node("Panel/TextureRect").modulate = color
	
func get_texture():
	return get_node("Panel/TextureRect").texture

func remove_image():
	var node = get_node("Panel/TextureRect")
	node.texture = default_image
	node.patch_margin_bottom = 0
	node.patch_margin_left = 0
	node.patch_margin_right = 0
	node.patch_margin_top = 0
	node.axis_stretch_horizontal = 0
	node.axis_stretch_vertical = 0
	node.draw_center = true
	node.region_rect = Rect2(Vector2(), Vector2())
	animation.frames = Vector2(1, 1)
	image = null
	emit_signal("image_removed")
	find_node("canvas").update()


func _on_canvas_draw() -> void:
	if patchs == null: return
	var canvas = find_node("canvas")
	var node = get_node("Panel/TextureRect")
	var size = rect_size
	var scale = node.get_texture().get_data().get_size() / size
	var i = patchs.patch_margin_left * scale.x
	canvas.draw_line(Vector2(i, 0), Vector2(i, size.y), Color.white, 1)
	i = size.x - patchs.patch_margin_right * scale.x
	canvas.draw_line(Vector2(i, 0), Vector2(i, size.y), Color.white, 1)
	i = patchs.patch_margin_top * scale.y
	canvas.draw_line(Vector2(0, i), Vector2(size.x, i), Color.white, 1)
	i = size.y - patchs.patch_margin_bottom * scale.y
	canvas.draw_line(Vector2(0, i), Vector2(size.x, i), Color.white, 1)
