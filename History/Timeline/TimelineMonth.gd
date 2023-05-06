extends VBoxContainer
class_name TimeLineMonth

# ==============================================================================
const SCENE := preload("res://History/Timeline/TimelineMonth.tscn")

const BUTTONS_COUNT := 42
const MONTH_LABEL_TEXT := "%s %s"

const QUEST_COLOR := Color.GREEN
# ==============================================================================
var quest_dates_dict := {}
var year := 0
var month := 0
# ==============================================================================
@onready var buttons_container: GridContainer = %ButtonsContainer
@onready var month_label: Label = %MonthLabel
# ==============================================================================

func update_calendar_buttons(selected_date: Date) -> void:
	_clear_calendar_buttons()
	
	year = selected_date.year
	month = selected_date.month
	
	quest_dates_dict = get_quest_dates_dictionary()
	
	month_label.text = MONTH_LABEL_TEXT % [Calendar.get_month_name(selected_date.month), selected_date.year]
	
	var days_in_month := Calendar.get_days_in_month(selected_date.month, selected_date.year)
	var start_day_of_week := Calendar.get_weekday(1, selected_date.month, selected_date.year)
	for i in range(days_in_month):
		var btn_node := get_day_button(i + start_day_of_week)
		btn_node.text = str(i + 1)
		btn_node.disabled = false
		
		var date := "%s-%s-%s" % [year, month, i + 1]
		if date in quest_dates_dict:
			btn_node.modulate = QUEST_COLOR
			btn_node.set_meta("quests", quest_dates_dict[date])
		
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


func update_filters(new_filters: Dictionary) -> void:
	for i in BUTTONS_COUNT:
		var button := get_day_button(i)
		var quests: Array = button.get_meta("quests", [])
		if quests.any(func(quest: Quest): return quest.matches_filters(new_filters)):
			button.modulate = QUEST_COLOR
		else:
			button.modulate = Color.WHITE


func get_day_button(day_index: int) -> Button:
	if buttons_container.get_child_count() > day_index:
		return buttons_container.get_child(day_index)
	
	while buttons_container.get_child_count() < day_index:
		var button := Button.new()
		button.name = "Button" + str(buttons_container.get_child_count())
		buttons_container.add_child(button)
	
	var button := Button.new()
	button.name = "Button" + str(day_index)
	buttons_container.add_child(button)
	return button


func get_quest_dates_dictionary() -> Dictionary:
	var dict := {}
	
	for profile in ProfileLoader.get_used_profiles():
		for quest in profile.quests:
			var date := TimeHelper.get_date(quest.creation_timestamp)
			if not date.match("%s-%s-*" % [year, month]):
				continue
			if date in dict:
				dict[date].append(quest)
			else:
				dict[date] = [quest]
	
	return dict


static func instantiate() -> TimeLineMonth:
	return SCENE.instantiate()
