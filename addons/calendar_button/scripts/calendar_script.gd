@tool
extends TextureButton
class_name CalendarButton

# ==============================================================================
var selected_date := Date.new()

var popup: Popup
var calendar_buttons: CalendarButtons
# ==============================================================================
signal date_selected(date_obj: Date)
# ==============================================================================

func _enter_tree():
	toggle_mode = true
	
	setup_calendar_icon()
	
	popup = create_popup_scene()
	
	calendar_buttons = create_calendar_buttons()
	
	setup_month_and_year_signals(popup)
	
	refresh_data()


func setup_calendar_icon():
	texture_normal = create_button_texture("btn_32x32_03.png")
	
	texture_pressed = create_button_texture("btn_32x32_04.png")


func create_button_texture(image_name: String) -> Texture2D:
#	var image_normal := Image.new()
#	image_normal.load("res://addons/calendar_button/btn_img/" + image_name)
#	var image_texture_normal := ImageTexture.new()
#	image_texture_normal.create_from_image(image_normal)
	
	return load("res://addons/calendar_button/btn_img/" + image_name)


func create_popup_scene() -> Popup:
	return preload("res://addons/calendar_button/popup.tscn").instantiate() as Popup


func create_calendar_buttons() -> CalendarButtons:
	var calendar_container: GridContainer = popup.get_node("PanelContainer/vbox/hbox_days")
	return CalendarButtons.new(self, calendar_container)


func setup_month_and_year_signals(popup : Popup):
	var month_year_path = "PanelContainer/vbox/hbox_month_year/"
	popup.get_node(month_year_path + "button_prev_month").pressed.connect(go_prev_month)
	popup.get_node(month_year_path + "button_next_month").pressed.connect(go_next_month)
	popup.get_node(month_year_path + "button_prev_year").pressed.connect(go_prev_year)
	popup.get_node(month_year_path + "button_next_year").pressed.connect(go_next_year)


func set_popup_title(title: String):
	var label_month_year_node := popup.get_node("PanelContainer/vbox/hbox_month_year/label_month_year") as Label
	label_month_year_node.set_text(title)


func refresh_data():
	var title := str(Calendar.get_month_name(selected_date.month) + " " + str(selected_date.year))
	set_popup_title(title)
	calendar_buttons.update_calendar_buttons(selected_date)


func day_selected(btn_node: BaseButton):
	close_popup()
	var day := int(btn_node.text)
	selected_date.day = day
	date_selected.emit(selected_date)


func go_prev_month():
	selected_date.change_to_prev_month()
	refresh_data()


func go_next_month():
	selected_date.change_to_next_month()
	refresh_data()


func go_prev_year():
	selected_date.change_to_prev_year()
	refresh_data()


func go_next_year():
	selected_date.change_to_next_year()
	refresh_data()


func close_popup():
	popup.hide()
	set_pressed(false)


func _toggled(is_pressed: bool):
	if not has_node("popup"):
		add_child(popup)
	if not is_pressed:
		close_popup()
	else:
		if has_node("popup"):
			popup.show()
		else:
			add_child(popup)
	
	WindowRestrictor.restrict_popup_inside_screen(popup)
