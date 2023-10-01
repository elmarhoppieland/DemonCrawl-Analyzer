extends Control
class_name Speedrun

# ==============================================================================
@onready var splits := %Splits as Splits
# ==============================================================================

func _on_start_button_pressed() -> void:
	LiveSplitEditor.load_splits("res://Live/Speedrun/Splits/0-AllQuestsStages.dcsl")
	
	SceneHandler.switch_scene(preload("res://Live/Speedrun/LiveSplit/LiveSplit.tscn"))


func _on_live_split_editor_title_changed(new_title: String) -> void:
	splits.set_title(new_title)


func _on_live_split_editor_category_changed(new_category: Leaderboards.Category) -> void:
	if not splits:
		await ready
	
	splits.set_category(new_category, true, LiveSplitEditor.split_frequency, true)


func _on_live_split_editor_attempt_count_changed(new_count: int) -> void:
	if not splits:
		await ready
	
	splits.set_attempt_count(new_count)
