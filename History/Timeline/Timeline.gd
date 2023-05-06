extends Control
class_name TimeLine

# ==============================================================================
@onready var h_flow_container: HFlowContainer = %HFlowContainer
# ==============================================================================

func _ready() -> void:
	var start_unix: int = Analyzer.get_setting("-Data", "start_unix")
	var start_datetime_dict := Time.get_datetime_dict_from_unix_time(start_unix)
	
	var current_date := Calendar.get_date()
	
	var date := current_date
	while true:
		var timeline_month := TimeLineMonth.instantiate()
		h_flow_container.add_child(timeline_month)
		timeline_month.update_calendar_buttons(date)
		
		date = date.duplicate()
		date.change_to_prev_month()
		if date.month < start_datetime_dict.month and date.year == start_datetime_dict.year:
			return
		if date.year < start_datetime_dict.year:
			return


static func get_tab() -> TimeLine:
	return Analyzer.get_tab(Analyzer.Tab.TIMELINE)


func _on_filters_saved(filters: Dictionary) -> void:
	for month in h_flow_container.get_children() as Array[TimeLineMonth]:
		month.update_filters(filters)
