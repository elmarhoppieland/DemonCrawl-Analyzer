extends PopupPanel
class_name StatisticsFilterSelection

# ==============================================================================
var filters := {
	Statistics.Filter.TIME_AFTER: "YYYY-MM-DDTHH:MM:SS",
	Statistics.Filter.TIME_BEFORE: "YYYY-MM-DDTHH:MM:SS",
	Statistics.Filter.QUEST_TYPE: {} # is filled with all Quest.Difficulty | Quest.Type combinations on load
}
var filters_changed := false
# ==============================================================================
@onready var time_after: TimeFilter = %After
@onready var time_before: TimeFilter = %Before
# ==============================================================================
signal filters_saved(filters: Dictionary)
# ==============================================================================

func _ready() -> void:
	time_after.set_date(Time.get_date_string_from_unix_time(Analyzer.get_settings().get_value("-Data", "start_unix", Time.get_unix_time_from_system())))
	
	for filter in Statistics.Filter.values():
		filters[filter] = get_filter(filter)


func get_filter(filter: Statistics.Filter) -> Variant:
	match filter:
		Statistics.Filter.TIME_AFTER:
			return time_after.datetime_string
		Statistics.Filter.TIME_BEFORE:
			return time_before.datetime_string
		Statistics.Filter.QUEST_TYPE:
			var types := {}
			for h_box_container in %QuestType.get_node("HBoxContainer").get_children():
				for check_box in h_box_container.get_children().filter(func(value): return value is QuestTypeCheckBox) as Array[QuestTypeCheckBox]:
					types[check_box] = check_box.get_value()
			
			return types
	
	return null


func save() -> void:
	filters_saved.emit(filters)


func save_request() -> void:
	if filters_changed:
		save()
	
	filters_changed = false


func _on_save_button_pressed() -> void:
	save_request()
	
	hide()


func _on_time_after_changed(new_time: String) -> void:
	filters[Statistics.Filter.TIME_AFTER] = new_time
	
	filters_changed = true


func _on_time_before_changed(new_time: String) -> void:
	filters[Statistics.Filter.TIME_BEFORE] = new_time
	
	filters_changed = true


func _on_quest_type_check_box_pressed(check_box: QuestTypeCheckBox) -> void:
	filters[Statistics.Filter.QUEST_TYPE][check_box] = check_box.get_value()
	
	filters_changed = true


func _on_about_to_popup() -> void:
	var button: BaseButton = get_parent()
	
	position = button.global_position
	position.x -= size.x
	position.y += int(button.position.y)
