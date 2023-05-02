extends Control
class_name WinsGraph

# ==============================================================================
const TITLE_TEXT := "Graph of %s quests"
# ==============================================================================
var filters := {}
# ==============================================================================
@onready var graph := %PointGraph as PointGraph
@onready var graph_title_label: Label = %GraphTitleLabel
@onready var profile_select_button: OptionButton = %ProfileSelectButton
@onready var graph_type_check_box: CheckBox = %GraphTypeCheckBox
# ==============================================================================

func _ready() -> void:
	var profiles := get_selected_profiles()
	
	for profile in profiles:
		profile_select_button.add_item(profile.name)
	
	show_graph(profiles, {})


func convert_to_win_percentages(quests: Array[Quest], time_adjusted: bool) -> Array[Vector2]:
	var win_count := 0
	var quest_count := quests.size()
	var percentages: Array[Vector2] = []
	
	for i in quests.size():
		var quest := quests[i]
		if quest.victory:
			win_count += 1
		var quest_start_unix_time := TimeHelper.get_unix_time_from_timestamp(quest.creation_timestamp)
		percentages.append(Vector2(quest_start_unix_time if time_adjusted else i, 100 * win_count / float(quest_count)))
	
	if quest_count < 10:
		for quest in quests:
			print(quest.creation_timestamp)
	
	return percentages


func show_graph(profiles: Array[Profile], quest_filters: Dictionary) -> void:
	var quests: Array[Quest] = []
	
	for profile in profiles:
		for quest in profile.quests:
			if quest.matches_filters(quest_filters):
				quests.append(quest)
	
	graph.data = convert_to_win_percentages(quests, graph_type_check_box.button_pressed)
	graph_title_label.text = TITLE_TEXT % quests.size()


func get_selected_profiles() -> Array[Profile]:
	var profiles := ProfileLoader.get_used_profiles()
	var index := profile_select_button.get_selected_id()
	if index > 0:
		return [profiles[index - 1]]
	
	return profiles


func _on_filters_saved(new_filters: Dictionary) -> void:
	filters = new_filters
	
	show_graph(get_selected_profiles(), filters)


func _on_profile_select_button_item_selected(_index: int) -> void:
	show_graph(get_selected_profiles(), filters)


func _on_graph_type_check_box_pressed() -> void:
	show_graph(get_selected_profiles(), filters)
