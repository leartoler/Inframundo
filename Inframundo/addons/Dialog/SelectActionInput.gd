extends DefaultDialog

var data = {
	"resume_actions"	: [],
	"up_actions"		: [],
	"down_actions"		: []
}
var real_data

func _ready() -> void:
	var actions = InputMap.get_actions()
	actions.sort()
	var node1 = find_node("ActionsOptions1")
	var node2 = find_node("ActionsOptions2")
	for name in actions:
		node1.add_item(name)
		node2.add_item(name)
	node1.select(0)
	node2.select(0)

func set_data(_data):
	real_data = _data
	data = _data.duplicate(true)
	var list = find_node("ItemList1")
	list.clear()
	if data.resume_actions.size() > 0:
		for action in data.resume_actions:
			list.add_item(action)
		list.select(0)
		list.ensure_current_is_visible()
	find_node("RemoveButton1").set_disabled(data.resume_actions.size() <= 1)
	list = find_node("ItemList2")
	list.clear()
	if data.up_actions.size() > 0:
		for action in data.up_actions:
			list.add_item(action)
		list.select(0)
		list.ensure_current_is_visible()
	find_node("RemoveButton2").set_disabled(data.up_actions.size() <= 1)
	list = find_node("ItemList3")
	list.clear()
	if data.down_actions.size() > 0:
		for action in data.down_actions:
			list.add_item(action)
		list.select(0)
		list.ensure_current_is_visible()
	find_node("RemoveButton3").set_disabled(data.down_actions.size() <= 1)

func _on_ok_button_down() -> void:
	real_data.resume_actions = data.resume_actions
	real_data.up_actions = data.up_actions
	real_data.down_actions = data.down_actions
	emit_signal("OK", null, dialog_id)
	

func _on_RESUME_button_down() -> void:
	var text = find_node("ActionsOptions1").text
	if !data.resume_actions.has(text):
		data.resume_actions.append(text)
		var list = find_node("ItemList1")
		list.add_item(text)
		list.select(list.get_item_count() - 1)
		list.ensure_current_is_visible()
		find_node("RemoveButton1").set_disabled(data.resume_actions.size() <= 1)


func _on_UP_button_down() -> void:
	var text = find_node("ActionsOptions2").text
	if !data.up_actions.has(text):
		data.up_actions.append(text)
		var list = find_node("ItemList2")
		list.add_item(text)
		list.select(list.get_item_count() - 1)
		list.ensure_current_is_visible()
		find_node("RemoveButton2").set_disabled(data.up_actions.size() <= 1)


func _on_DOWN_button_down() -> void:
	var text = find_node("ActionsOptions2").text
	if !data.down_actions.has(text):
		data.down_actions.append(text)
		var list = find_node("ItemList3")
		list.add_item(text)
		list.select(list.get_item_count() - 1)
		list.ensure_current_is_visible()
		find_node("RemoveButton3").set_disabled(data.down_actions.size() <= 1)


func _on_RemoveButton1_button_down() -> void:
	var list = find_node("ItemList1")
	if list.is_anything_selected():
		var index = list.get_selected_items()[0]
		list.remove_item(index)
		data.resume_actions.remove(index)
		if data.resume_actions.size() > 0:
			index = min(index, data.resume_actions.size() - 1)
			list.select(index)
			list.ensure_current_is_visible()
		find_node("RemoveButton1").set_disabled(data.resume_actions.size() <= 1)


func _on_RemoveButton2_button_down() -> void:
	var list = find_node("ItemList2")
	if list.is_anything_selected():
		var index = list.get_selected_items()[0]
		list.remove_item(index)
		data.up_actions.remove(index)
		if data.up_actions.size() > 0:
			index = min(index, data.up_actions.size() - 1)
			list.select(index)
			list.ensure_current_is_visible()
		find_node("RemoveButton2").set_disabled(data.up_actions.size() <= 1)


func _on_RemoveButton3_button_down() -> void:
	var list = find_node("ItemList3")
	if list.is_anything_selected():
		var index = list.get_selected_items()[0]
		list.remove_item(index)
		data.down_actions.remove(index)
		if data.down_actions.size() > 0:
			index = min(index, data.down_actions.size() - 1)
			list.select(index)
			list.ensure_current_is_visible()
		find_node("RemoveButton3").set_disabled(data.down_actions.size() <= 1)
