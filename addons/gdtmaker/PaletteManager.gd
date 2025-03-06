@tool class_name PaletteManager extends Control

var palettes : Dictionary[String, PackedColorArray] = {}

var i = 0

func save_palette() -> void:
	%ColorGrid.save_colors_to_project(%SPName.text)

func load_palettes() -> void:
	palettes = ProjectSettings.get_setting("TMaker/general/Palettes")

func palette_options_item_selected(index: int) -> void:
	var palette = $PaletteOptions.get_item_text(index)
	%ColorGrid.load_colors_from_project(palette)
	%SPName.text = palette
	i = index

func _process(delta: float) -> void:
	load_palettes()
	if not get_items() == palettes.keys():
		$PaletteOptions.clear()
		for title in palettes.keys():
			$PaletteOptions.add_item(title)
		$PaletteOptions.selected = i


func get_items():
	var items = []
	for i in $PaletteOptions.item_count:
		items.append($PaletteOptions.get_item_text(i))
	return items
