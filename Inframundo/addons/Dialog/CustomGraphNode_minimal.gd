extends Control
class_name GraphNodeMinimal

var data
var focused = false
var title
var id
var color = Color.transparent
var connections

signal request_create_graphnode(obj)
signal end_move_and_resizing(obj)

func _on_visibillity_control_screen_entered() -> void:
	emit_signal("request_create_graphnode", self)

func resize(size):
	rect_size = size

func is_on_screen():
	return false
	
func get_point(a, b):
	return self
	
func select(force_select = false) -> void:
	pass

func set_data(_data):
	data = _data

func get_data():
	return data

func get_connections():
	return connections

func remove_connection(connection):
	for c in connections:
		if 	c.from == connection.from and \
			c.from_port == connection.from_port and \
			c.to == connection.to and \
			c.to_port == connection.to_port:
			connections.erase(c)
			break
