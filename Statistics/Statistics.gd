extends Control
class_name Statistics

# ==============================================================================
enum Filter {
	TIME_AFTER,
	TIME_BEFORE,
	QUEST_TYPE
}
# ==============================================================================
@onready var statistics_filter_selection: StatisticsFilterSelection = %StatisticsFilterSelection
@onready var tab_container: TabContainer = %TabContainer
# ==============================================================================

func _ready() -> void:
	tab_container.current_tab = 0


func get_filter(filter: Filter) -> Variant:
	return statistics_filter_selection.get_filter(filter)


static func get_control() -> Statistics:
	return Analyzer.get_node_or_null("/root/Statistics")


static func get_filters() -> Dictionary:
	return get_control().statistics_filter_selection.filters
