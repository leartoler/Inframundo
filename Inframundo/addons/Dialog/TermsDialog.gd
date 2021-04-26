extends DefaultDialog

var terms = []
var languages = []
var selectedIndex

onready var language_panel = preload("res://addons/Dialog/LanguagePanel.tscn")

func get_term(id) -> Dictionary:
	var term = {}
	term.id = id
	term.values = []
	for i in languages.size():
		term.values.append("")
	return term

func fill_language_panels():
	var container = find_node("LanguageContainer")
	for child in container.get_children():
		child.queue_free()
	for i in languages.size():
		var lang = languages[i]
		var panel = language_panel.instance()
		panel.connect("text_changed", self, "update_text")
		panel.set_lang(i, lang.name)
		container.add_child(panel)


func update_text(term):
	var index = find_node("ItemList").get_selected_items()[0]
	terms[index].values[term.lang_id] = term.text


func fill_item_list():
	var node = find_node("ItemList")
	if node == null: return
	var index = -1
	if node.is_anything_selected():
		index = node.get_selected_items()[0]
	node.clear()
	for term in terms:
		node.add_item(term.id)
	var container = find_node("LanguageContainer")
	if terms.size() != 0:
		if index == -1: index = 0
		index = min(index, terms.size() - 1)
		node.select(index)
		node.ensure_current_is_visible()
		node.emit_signal("item_selected", index)
		container.visible = true
	else:
		disable_all()
		container.visible = false

func _on_TermsDialog_visibility_changed() -> void:
	if visible:
		fill_language_panels()
		fill_item_list()
		find_node("ItemList").grab_focus()
		if selectedIndex != null:
			find_node("ItemList").select(selectedIndex)
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			find_node("ItemList").emit_signal("item_selected", selectedIndex)
			selectedIndex = null
		else:
			find_node("ItemList").emit_signal("item_selected", 0)


func disable_all():
	find_node("ITEMID").editable = false
	for child in find_node("LanguageContainer").get_children():
		child.set_disabled(true)

func _on_AddTermButton_button_down() -> void:
	var term = get_term("new_term_%s" % terms.size())
	terms.append(term)
	fill_item_list()
	var node = find_node("ItemList")
	var index = terms.size() - 1
	node.select(index)
	node.ensure_current_is_visible()
	node.emit_signal("item_selected", index)
	find_node("RemoveTermButton").disabled = false
	


func _on_ItemList_item_selected(index: int) -> void:
	if index > terms.size() -1: return
	var texts = terms[index]
	for i in texts.values.size():
		var node = find_node("LanguageContainer").get_child(i)
		node.set_disabled(false)
		node.set_text(texts.values[i])
	var node = find_node("ITEMID")
	node.editable = true
	node.text = terms[index].id
	node.caret_position = node.text.length()
	node.select_all()
	node.grab_focus()


func _on_ITEMID_text_changed(new_text: String) -> void:
	var index = find_node("ItemList").get_selected_items()[0]
	terms[index].id = new_text
	find_node("ItemList").set_item_text(index, new_text)


func _on_ItemList_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == BUTTON_LEFT and event.doubleclick:
		var index = find_node("ItemList").get_item_at_position(event.position, true)
		if index == -1:
			_on_AddTermButton_button_down()


func _on_RemoveTermButton_button_down() -> void:
	var node = find_node("ItemList")
	if !node.is_anything_selected(): return
	var index = node.get_selected_items()[0]
	terms.remove(index)
	node.remove_item(index)
	if terms.size() > 0:
		index = min(index, terms.size() - 1)
		node.select(index)
		node.ensure_current_is_visible()
		node.emit_signal("item_selected", index)
	else:
		find_node("RemoveTermButton").disabled = true
		find_node("LanguageContainer").visible = false
