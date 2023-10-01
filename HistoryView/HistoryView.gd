extends Control
class_name HistoryView

# ==============================================================================

func _ready() -> void:
	Packages.call_method("_build_recent_quests_list", [])
