extends TabContainer
class_name Statistics

# ==============================================================================
enum LogError {
	UNKNOWN = -1, ## Unknown error.
	OK, ## No error.
	EOF_REACHED, ## End of file reached.
	EMPTY_FILE, ## File is empty.
	PLAYER_DIED, ## Player died.
	QUEST_COMPLETE, ## Quest complete.
	INVALID_TIMESTAMP, ## Does not contain logs after the specified timestamp.
	READ_ERROR ## There was an error when attempting to read the file.
}
enum Filter {
	TIME_AFTER,
	TIME_BEFORE,
	QUEST_TYPE
}
enum ExitCode {
	OK,
	READ_ERROR
}
# ==============================================================================
var profiles := {}

var current_profile: Profile

var errors := []
# ==============================================================================
@onready var statistics_filter_selection: StatisticsFilterSelection = %StatisticsFilterSelection
# ==============================================================================

func _enter_tree() -> void:
	current_tab = 0


func get_filter(filter: Filter) -> Variant:
	return statistics_filter_selection.get_filter(filter)
