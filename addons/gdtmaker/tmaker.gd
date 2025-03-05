@tool
class_name TMaker extends Control

var texture_buttons : Dictionary[Button, String] 
var textures : PackedStringArray

var texture_container : GridContainer

var in_editor_plugin = false
var plugin 
func _enter_tree() -> void:
	self.visibility_changed.connect(visiblity_update)

func visiblity_update() -> void:
	for b in texture_buttons: b.queue_free()
	texture_buttons.clear()
	set_process(visible)
	if visible && $TextureScreen.visible: load_textures_for_screen()
	

func _process(delta: float) -> void:
	if in_editor_plugin && visible && Vector2i(self.size) != Vector2i(get_parent().size):
		self.size = Vector2(get_parent().size)
		print("updated size", self.size)
		$SpriteEditor/SidePanel.size.x = 192

func load_textures_for_screen():
	textures.clear()
	texture_container = get_node_or_null("TextureScreen/ExistingList/ScrollContainer/TextureGridContainer")
	var source_directories = ProjectSettings.get_setting("TMaker/texture_paths")
	var allowed_extensions = ProjectSettings.get_setting("TMaker/texture_extensions")
	for directory : String in source_directories:
		if not directory.ends_with("/"): continue
		var files = DirAccess.get_files_at(directory)
		for file : String in files:
			if allowed_extensions.has("." + file.get_extension()) && !textures.has(directory + file):
				textures.append(directory + file)
				if texture_container:
					create_new_texture_button(directory + file)

func create_new_texture_button(file_path : String):
	# add button
	var min_size = Vector2(128, 128)
	var button = Button.new()
	texture_container.add_child(button)
	texture_buttons[button] = file_path
	
	button.owner = texture_container
	
	# config button
	button.custom_minimum_size = min_size
	button.expand_icon = true
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	button.flat = true
	button.icon = load(file_path)
	
	button.text = file_path.get_file()
	
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	button.set_name(file_path.get_file())
	button.pressed.connect(front_screen_button_pressed.bind(button))

func front_screen_button_pressed(button : Button):
	var file = texture_buttons[button]
	$SpriteEditor.load_image(file)
	$SpriteEditor.current_path = file


func _on_reload_pressed() -> void:
	visiblity_update() # bad practice but oh well
