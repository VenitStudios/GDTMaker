@tool extends Control

var current_image : Image
var current_path : String

var zoom_amount : float = 1.0
var texture_rect : TextureRect
var image_offset := Vector2.ZERO
var current_color : Color = Color.WHITE

var undo_redo = UndoRedo.new()

var left_mouse_state : bool = false
var right_mouse_state : bool = false

var saved : bool = false

var brush_radius : int = 1 : 
	set(value):
		brush_radius = clamp(value, 0, 128)
		%BrushSize.value = value

var Brushes : Dictionary[String, Callable] = \
{ 
	"box_brush": box_brush,
	"circle_brush": circle_brush
}

var current_brush : Callable = Brushes.box

func load_image(path : String):
	current_brush = box_brush
	brush_radius = 3
	print(current_brush)
	quit()
	show()
	current_image = ResourceLoader.load(path).get_image()
	update_texture_rect()


func create_new_image(path : String, width : int, height : int):
	current_brush = box_brush
	brush_radius = 3
	quit()
	show()
	current_image = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	current_path = path
	update_texture_rect()

func quit():
	self.hide()
	image_offset = Vector2.ZERO
	zoom_amount = 1.0
	current_color = Color.WHITE
	current_image = null
	current_path = ""
	texture_rect.texture = null
	current_brush = box_brush
	brush_radius = 3


func update_texture_rect():
	if not current_image: return
	texture_rect = get_node_or_null("TMakerBG/TextureRect")
	texture_rect.texture = ImageTexture.create_from_image(current_image)

func _process(delta: float) -> void:
	if get_parent().plugin && !get_parent().plugin.currently_visible: 
		return
	
	%FileName.text = str(current_path).get_file()
	if !is_instance_valid(current_image) && get_parent().visible: return
	if texture_rect && current_image: 
		texture_rect.size = current_image.get_size() * zoom_amount
		texture_rect.position = size / 2 - (texture_rect.size / 2) + (image_offset)
		%ZoomAmt.text = str(int(zoom_amount * 100), "%")
		%PanAmt.text = str(image_offset.round())
		
	if texture_rect && current_image:
		zoom_amount = clamp(zoom_amount, 0.05, snappedf(current_image.get_width() * 1.5, 0.1))
		
	if texture_rect && texture_rect.get_global_rect().has_point(get_global_mouse_position()):
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) == left_mouse_state:
			left_mouse_state = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
			make_undo_action()
		
		var pos = (texture_rect.get_local_mouse_position() / zoom_amount).floor()
		if left_mouse_state == true:
			var c = current_image.get_pixelv(pos) 
			if pos > Vector2.ZERO && pos < Vector2(current_image.get_size()): call_current_brush(pos, current_color)
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) == right_mouse_state:
			right_mouse_state = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
			make_undo_action()
		if right_mouse_state == true:
			call_current_brush(pos,Color(0.0, 0.0, 0.0, 0.0))
		 
		update_texture_rect()

func make_undo_action():
	
	if !is_visible_in_tree(): return
	undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Draw on Texture")
	undo_redo.add_do_property(current_image, "data", current_image.data)
	undo_redo.add_undo_property(current_image, "data", current_image.data)
	undo_redo.commit_action(true)
	saved = false
	#print("made undo action")

func call_current_brush(center : Vector2, color : Color):
	current_brush.call(Vector2i(center), brush_radius, color)

func box_brush(center_pixel : Vector2i, radius : int, color : Color):
	radius /= 2
	for y in range(center_pixel.y - radius, center_pixel.y + radius + 1):
		for x in range(center_pixel.x - radius, center_pixel.x + radius + 1):
			if x >= 0 and x < current_image.get_width() and y >= 0 and y < current_image.get_height():
				current_image.set_pixel(x, y, color)

func circle_brush(center_pixel : Vector2i, radius : int, color : Color):
	print("circle")
	radius /= 2
	for y in range(center_pixel.y - radius, center_pixel.y + radius + 1):
		for x in range(center_pixel.x - radius, center_pixel.x + radius + 1):
			var distance_squared = (x - center_pixel.x) * (x - center_pixel.x) + (y - center_pixel.y) * (y - center_pixel.y)
			if distance_squared <= radius * radius:
				if x >= 0 and x < current_image.get_width() and y >= 0 and y < current_image.get_height():
					current_image.set_pixel(x, y, color)

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or not texture_rect or not current_image && !get_parent().plugin.visible: return
	if event is InputEventMouseButton && !%SidePanel.get_global_rect().has_point(get_global_mouse_position()):
		match event.button_index:
			4:
				if !Input.is_key_pressed(KEY_CTRL):
					zoom_amount += 0.05 * zoom_amount * 2
					image_offset -= (texture_rect.global_position + (texture_rect.size / 2)).direction_to(get_global_mouse_position()) \
					* zoom_amount * 2
				else:
					brush_radius += 1 if event.is_pressed() else 0
			5:
				if !Input.is_key_pressed(KEY_CTRL):
					zoom_amount -= 0.05 * zoom_amount * 2
					image_offset += (texture_rect.global_position + (texture_rect.size / 2)).direction_to(get_global_mouse_position()) \
					* zoom_amount * 2
				else:
					brush_radius -= 1 if event.is_pressed() else 0
				
	if event is InputEventMouseMotion:
		match event.button_mask:
			4:
				image_offset += event.relative
	
	if Input.is_action_just_pressed("ui_undo"): 
		var editor_ur = EditorInterface.get_editor_undo_redo()
		var toaster = EditorInterface.get_editor_toaster()
		toaster.push_toast("undo", EditorToaster.SEVERITY_INFO)
		saved = false
		update_texture_rect()
		
	if Input.is_action_just_pressed("ui_redo"): 
		var toaster = EditorInterface.get_editor_toaster()
		toaster.push_toast("redo", EditorToaster.SEVERITY_INFO)
		update_texture_rect()
		saved = false
	
	if event is InputEventKey:
		match event.keycode:
			KEY_S:
				if event.ctrl_pressed && !saved:
					save_texture()
			KEY_E:
				if event.ctrl_pressed:
					quit()

func save_texture():
	#current_path = current_path.replace("res://", EditorInterface.get_current_path())
	match current_path.get_extension():
		"png": current_image.save_png(ProjectSettings.globalize_path(current_path))
		"jpg", "jpeg": current_image.save_jpg(ProjectSettings.globalize_path(current_path))
		"webp": current_image.save_webp(ProjectSettings.globalize_path(current_path))
		"exr": current_image.save_exr(ProjectSettings.globalize_path(current_path))
	var toaster = EditorInterface.get_editor_toaster()
	toaster.push_toast("Texture Saved.", EditorToaster.SEVERITY_INFO)
	EditorInterface.get_resource_filesystem().scan_sources()
	saved = true

func zoom_reset() -> void:
	zoom_amount = 1
	$Dock/ZoomAmt/ZoomReset.release_focus()

func pan_reset() -> void:
	image_offset = Vector2.ZERO
	$Dock/PanAmt/PanReset.release_focus()

func file_menu_item_selected(index: int) -> void:
	var item = %FileMenu.get_item_text(index)
	match item:
		"Save": save_texture()
		"Save & Exit (Ctrl+E)": 
			save_texture()
			quit()
		"Exit Without Save":
			quit()
	%FileMenu.selected = 0


func _on_brush_size_value_changed(value: float) -> void: brush_radius = value
func brush_type_selected(index: int) -> void: 
	var brstr = %BrushType.get_item_text(index).to_lower() + "_brush"
	if Brushes.has(brstr):
		current_brush = Brushes[brstr]
		print(current_brush)
