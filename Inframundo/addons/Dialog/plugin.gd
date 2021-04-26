tool
extends EditorPlugin

var dock

# Add menu button to canvas editor:
func _enter_tree()-> void:
	add_tool_menu_item("Dialog Editor", self, "clickedButton")
	add_custom_type("DialogBox", "CanvasLayer", preload("res://addons/Dialog/DialogBox/custom_dialog_node.gd"), preload("res://addons/Dialog/DialogBox/Graphics/icon.png"))


func clickedButton(ud):
	var _icon = ProjectSettings.get_setting("application/config/icon")
	var _name = ProjectSettings.get_setting("application/config/name")
	var test_size = Vector2(ProjectSettings.get_setting("display/window/size/test_width"), ProjectSettings.get_setting("display/window/size/test_height"))
	ProjectSettings.set_setting("application/config/icon", "res://addons/Dialog/icon.png")
	ProjectSettings.set_setting("application/config/name", "Edit Dialogs by Newold")
	ProjectSettings.set_setting("display/window/size/test_width", 1024)
	ProjectSettings.set_setting("display/window/size/test_height", 768)
	ProjectSettings.save()
	var executable = OS.get_executable_path()
	var array = ["res://Addons/Dialog/DialogEditor.tscn"]
	var args = PoolStringArray(array)
	OS.execute(executable, args)
	ProjectSettings.set_setting("application/config/icon", _icon)
	ProjectSettings.set_setting("application/config/name", _name)
	ProjectSettings.set_setting("display/window/size/test_width", test_size.x)
	ProjectSettings.set_setting("display/window/size/test_height", test_size.y)
	ProjectSettings.save()


# Remove menu button from canvas editor:
func _exit_tree():
	remove_tool_menu_item("Dialog Editor")
	remove_custom_type("DialogBox")

# Plugin name:
func get_plugin_name()-> String: 
	return "Create or Edit Dialogs"
