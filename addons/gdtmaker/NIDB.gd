@tool extends Button

func _pressed() -> void:
	$FileDialog.show()
	var filters = []
	for extension in ProjectSettings.get_setting("TMaker/texture_extensions"): 
		filters.append("*%s" % extension)
	$FileDialog.filters = filters
	if !$FileDialog.file_selected.is_connected(file_selected):
		$FileDialog.file_selected.connect(file_selected)

func file_selected(path : String):
	match FileAccess.file_exists(path):
		true:
			$"../../../SpriteEditor".load_image(path)
			
		false:
			$"../../../SpriteEditor".create_new_image(path, int($"../NewWidth".value), int($"../NewHeight".value))
			$"../../../SpriteEditor".current_path = path
