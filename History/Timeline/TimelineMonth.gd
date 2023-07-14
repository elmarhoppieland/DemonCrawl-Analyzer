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

var filters := {}
# ==============================================================================
@onready var buttons_container: GridContainer = %ButtonsContainer
@onready var month_label: Label = %MonthLabel
# ==============================================================================

func update_calendar_buttons(selected_date: Date) -> void:
	_clear_calendar_buttons()
	
	year = selected_date.year
	month = selected_date.month
	
	quest_dates_dict = get_quest_dates_dictionary()
	
	var timeline := TimeLine.get_tab()
	month_label.text = MONTH_LABEL_TEXT % [Calendar.get_month_name(selected_date.month), selected_date.year]
	
	var days_in_month := Calendar.get_days_in_month(selected_date.month, selected_date.year)
	var start_day_of_week := Calendar.get_weekday(1, selected_date.month, selected_date.year)
	for i in range(days_in_month):
		var btn_node := get_day_button(i + start_day_of_week)
		btn_node.text = str(i + 1)
		btn_node.disabled = false
		
		var date := "%s-%s-%s" % [year, month, i + 1]
		if date in quest_dates_dict:
			btn_node.focus_mode = Control.FOCUS_ALL
			btn_node.modulate = QUEST_COLOR
			btn_node.set_meta("quests", quest_dates_dict[date])
			btn_node.pressed.connect(func():
				if btn_node.modulate == Color.WHITE:
					return
				timeline.tree.show()
				timeline.tree_split_container.show()
				timeline.tree.clear()
				var root := timeline.tree.create_item()
				var quests: Dictionary = btn_node.get_meta("quests", {})
				for profile_name in quests.keys() as Array[String]:
					var profile_item := root.create_child()
					profile_item.set_text(0, profile_name)
					for quest in quests[profile_name] as Array[Quest]:
						if not quest.matches_filters(filters):
							continue
						History.add_quest(quest, profile_item, false)
			)
		
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
		btn_node.focus_mode = Control.FOCUS_NONE
		btn_node.flat = false


func update_filters(new_filters: Dictionary) -> void:
	filters = new_filters
	
	for i in BUTTONS_COUNT:
		var button := get_day_button(i)
		var quests: Dictionary = button.get_meta("quests", {})
		if quests.values().any(func(quests: Array): return quests.any(func(quest: Quest): return quest.matches_filters(new_filters))):
			button.modulate = QUEST_COLOR
			button.focus_mode = Control.FOCUS_ALL
		else:
			button.modulate = Color.WHITE
			button.focus_mode = Control.FOCUS_NONE


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
				if profile.name in dict[date]:
					dict[date][profile.name].append(quest)
				else:
					dict[date][profile.name] = [quest]
			else:
				dict[date] = {profile.name: [quest]}
	
	return dict


static func instantiate() -> TimeLineMonth:
	return SCENE.instantiate()
