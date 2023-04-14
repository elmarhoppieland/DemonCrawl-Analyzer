extends RefCounted
class_name WindowRestrictor

# ==============================================================================

static func restrict_popup_inside_screen(popup: Popup):
	var calendar_container := popup.get_parent()
	var popup_container: PanelContainer = popup.get_node("PanelContainer")
	
	var popup_size := popup_container.size
#	var popup_x_size := popup_container.get_size().x
#	var popup_y_size := popup_container.get_size().y
	var calendar_icon_pos: Vector2 = calendar_container.global_position
#	var calendar_icon_x_pos := calendar_container.get_global_position().x
#	var calendar_icon_y_pos := calendar_container.get_global_position().y
	var calendar_icon_size: Vector2 = calendar_container.size
#	var calendar_icon_x_size := calendar_container.get_size().x
#	var calendar_icon_y_size := calendar_container.get_size().y
	var window_size := popup.get_window().size
	
	var pos := Vector2.ZERO
	if window_size.x > popup_size.x + calendar_icon_size.x / 2:
		var popup_x_end := popup_size.x + calendar_icon_pos.x + calendar_icon_size.x / 2
		if window_size.x > popup_x_end:
			pos.x = calendar_icon_pos.x + calendar_icon_size.x / 2
		else:
			pos.x = window_size.x - popup_size.x
	
	if window_size.y > popup_size.y + calendar_icon_size.y / 2:
		var popup_y_end := popup_size.y + calendar_icon_pos.y + calendar_icon_size.y / 2
		if window_size.y > popup_y_end:
			pos.y = calendar_icon_pos.y + calendar_icon_size.y / 2
		else:
			pos.y = window_size.y - popup_size.y
	
	popup.position = pos
