extends VBoxContainer
class_name TimeLineMonth

# ==============================================================================
const BUTTONS_COUNT := 42
# ==============================================================================
@onready var buttons_container: GridContainer = %ButtonsContainer
# ==============================================================================

func update_calendar_buttons(selected_date: Date) -> void:
	_clear_calendar_buttons()
	
	var days_in_month := Calendar.get_days_in_month(selected_date.month, selected_date.year)
	var start_day_of_week := Calendar.get_weekday(1, selected_date.month, selected_date.year)
	for i in range(days_in_month):
		var btn_node := get_day_button(i + start_day_of_week)
		btn_node.text = str(i + 1)
		btn_node.disabled = false
		
		# If the day entered is "today"
		if i + 1 == Calendar.day() and selected_date.year == Calendar.year() and selected_date.month == Calendar.month():
			btn_node.flat = true
		else:
			btn_node.flat = false


func _clear_calendar_buttons() -> void:
	for i in range(BUTTONS_COUNT):
		var btn_node := get_day_button(i)
		btn_node.text = ""
		btn_node.disabled = true
		btn_node.flat = false


func get_day_button(day_index: int) -> Button:
	if buttons_container.get_child_count() > day_index:
		return buttons_container.get_child(day_index)
	
	while buttons_container.get_child_count() < day_index:
		var button := Button.new()
		button.name = "Button" + str(buttons_container.get_child_count())
		button.owner = self
		buttons_container.add_child(button)
	
	var button := Button.new()
	button.name = "Button" + str(day_index)
	button.owner = self
	buttons_container.add_child(button)
	return button
