@tool
extends EditorPlugin

const TMAKER_SCENE = preload("res://addons/gdtmaker/tmaker_scene.tscn")

var tmaker_scene_instance

var currently_visible = false

func _enter_tree():
	if !tmaker_scene_instance:
		tmaker_scene_instance = TMAKER_SCENE.instantiate()
		EditorInterface.get_editor_main_screen().add_child(tmaker_scene_instance)
		_make_visible(false)
		tmaker_scene_instance.in_editor_plugin = true
		tmaker_scene_instance.plugin = self
		print(tmaker_scene_instance.plugin)
	_check_for_settings()

func _exit_tree():
	if tmaker_scene_instance:
		tmaker_scene_instance.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if tmaker_scene_instance:
		tmaker_scene_instance.visible = visible
		currently_visible = visible
		print(currently_visible)

func _get_plugin_name(): return "Texture Maker"

func _get_plugin_icon(): return EditorInterface.get_editor_theme().get_icon("Edit", "EditorIcons")

func _check_for_settings():
	
	if not ProjectSettings.has_setting("TMaker/texture_paths"): 
		ProjectSettings.set_setting("TMaker/texture_paths", PackedStringArray(["res://"]))
	if not ProjectSettings.has_setting("TMaker/texture_extensions"): 
		ProjectSettings.set_setting("TMaker/texture_extensions", [".png", ".jpg", ".jpeg", ".webp", ".exr"])
	
	
