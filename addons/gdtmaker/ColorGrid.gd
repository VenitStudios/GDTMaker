@tool extends GridContainer

@export var ColorAmt : int = 64
@export var shades : int = 16

var buttons : Array[ColorPickerButton]
var colors : PackedColorArray

func _ready() -> void:
	for c in get_children(): 
		c.queue_free()
		buttons.erase(c)
	for c in ColorAmt:
		var cpb = add_new_button()
		cpb.color = generate_color(c, ColorAmt)
	for s in shades:
		var cpb = add_new_button()
		cpb.color = Color(float(s + 1) / shades, float(s + 1) / shades, float(s + 1) / shades, 1.0)

func save_colors_to_project(palette_title : String):
	if not ProjectSettings.has_setting("TMaker/general/Palettes"):
		var ar : Dictionary[String, PackedColorArray] = {}
		ProjectSettings.set_setting("TMaker/general/Palettes", ar)
	var current : Dictionary[String, PackedColorArray] = ProjectSettings.get_setting("TMaker/Palettes")
	current[palette_title] = get_all_colors()
	ProjectSettings.set_setting("TMaker/general/Palettes", current)
	

func load_colors_from_project(palette_title : String):
	colors = ProjectSettings.get_setting("TMaker/Palettes")[palette_title]
	load_new_colors()

func get_all_colors() -> PackedColorArray:
	colors = []
	for c in get_children():
		if c is ColorPickerButton:
			if not colors.has(c.color):
				colors.append(c.color)
	return colors

func load_new_colors():
	for c in get_children(): 
		c.queue_free()
		buttons.erase(c)
	for color in colors:
		var cpb = add_new_button()
		cpb.color = color

func _physics_process(delta: float) -> void:
	for c in buttons:
		c.custom_minimum_size = Vector2.ONE * ((get_node("../../../").size.x / columns) - 2) 
		c.size = c.custom_minimum_size

func generate_color(index, amount) -> Color: 
	var hue = float(index) / amount
	var saturation = 1.0
	var value = 1.0
	
	return Color.from_hsv(hue, saturation, value)

func add_new_button():
	var cpb = ColorPickerButton.new()
	add_child(cpb)
	buttons.append(cpb)
	cpb.custom_minimum_size = Vector2(8, 8)
	cpb.color = Color.WHITE
	cpb.button_mask = MOUSE_BUTTON_MASK_RIGHT
	cpb.gui_input.connect(button_gui_input.bind(cpb))
	cpb.color_changed.connect(button_color_change.bind(cpb))
	return cpb

func _on_button_pressed() -> void:
	var b = add_new_button()
	move_child(b, 0)
	get_tree().current_scene.current_color = b.color

func button_gui_input(event: InputEvent, button : ColorPickerButton) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			get_node("../../../../").current_color = button.color

func button_color_change(color : Color, button : ColorPickerButton):
	if button.has_focus(): get_node("../../../../").current_color = color
