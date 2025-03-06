@tool extends Control

func _process(delta: float) -> void:
	if get_node("../../").plugin && get_node("../../").plugin.currently_visible:
		queue_redraw()

func _draw() -> void:
	var settings = EditorInterface.get_editor_settings()
	var color = settings.get_setting("interface/theme/accent_color") * 0.5
	var parent = get_parent()
	var center_pixel = to_global(parent.texture_rect).round()
	match parent.Brushes.find_key(parent.current_brush):
		"box_brush":
			var rect = Rect2(center_pixel, Vector2i(parent.brush_radius, parent.brush_radius) * parent.zoom_amount)
			draw_rect(rect, color, true)
		"circle_brush":
			draw_circle(center_pixel + ( Vector2.ONE * parent.brush_radius * parent.zoom_amount / 2), parent.brush_radius * parent.zoom_amount / 2, color)

func to_global(node : TextureRect) -> Vector2:
	if not node: return Vector2.ZERO
	var global_offset = node.position
	var mouse_position = node.get_local_mouse_position()
	var global_pos = global_offset - (Vector2.ONE * get_parent().brush_radius * get_parent().zoom_amount / 2)
	return global_pos + mouse_position
