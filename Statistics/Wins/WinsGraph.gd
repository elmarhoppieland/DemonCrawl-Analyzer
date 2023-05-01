extends Control
class_name WinsGraph

# ==============================================================================
const TITLE_TEXT := "Graph of %s quests"
# ==============================================================================
var filters := {}
# ==============================================================================
@onready var graph := %Graph as Graph
@onready var graph_title_label: Label = %GraphTitleLabel
@onready var profile_select_button: OptionButton = %ProfileSelectButton
# ==============================================================================

func _ready() -> void:
	var profiles := get_selected_profiles()
	
	for profile in profiles:
		profile_select_button.add_item(profile.name)
	
	show_graph(profiles, {})


func convert_to_win_percentages(quest_outcomes: Array[bool]) -> Array[float]:
	var win_count := 0
	var quest_count := 0
	var percentages: Array[float] = []
	
	for outcome in quest_outcomes:
		if outcome:
			win_count += 1
		quest_count += 1
		percentages.append(100 * win_count / float(quest_count))
	
	return percentages


func show_graph(profiles: Array[Profile], quest_filters: Dictionary) -> void:
	var wins: Array[bool] = []
	
	for profile in profiles:
		for quest in profile.quests:
			if quest.matches_filters(quest_filters):
				wins.append(quest.victory)
	
	graph.data = convert_to_win_percentages(wins)
	graph_title_label.text = TITLE_TEXT % wins.size()


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
