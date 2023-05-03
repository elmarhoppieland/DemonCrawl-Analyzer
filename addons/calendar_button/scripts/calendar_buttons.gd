extends RefCounted
class_name CalendarButtons

# ==============================================================================
const BUTTONS_COUNT := 42
# ==============================================================================
var buttons_container: GridContainer
# ==============================================================================

func _init(calendar_script: CalendarButton, _buttons_container: GridContainer):
	buttons_container = _buttons_container
	setup_button_signals(calendar_script)


func setup_button_signals(calendar_script: CalendarButton):
	for i in range(BUTTONS_COUNT):
		var btn_node: BaseButton = buttons_container.get_child(i)
		btn_node.pressed.connect(calendar_script.day_selected.bind(btn_node))


func update_calendar_buttons(selected_date: Date):
	_clear_calendar_buttons()
	
	var days_in_month := Calendar.get_days_in_month(selected_date.month, selected_date.year)
	var start_day_of_week := Calendar.get_weekday(1, selected_date.month, selected_date.year)
	for i in range(days_in_month):
		var btn_node : Button = buttons_container.get_node("btn_" + str(i + start_day_of_week))
		btn_node.text = str(i + 1)
		btn_node.disabled = false
		
		# If the day entered is "today"
		if i + 1 == Calendar.day() and selected_date.year == Calendar.year() and selected_date.month == Calendar.month():
			btn_node.flat = true
		else:
			btn_node.flat = false


func _clear_calendar_buttons():
	for i in range(BUTTONS_COUNT):
		var btn_node: Button = buttons_container.get_node("btn_" + str(i))
		btn_node.text = ""
		btn_node.disabled = true
		btn_node.flat = false
