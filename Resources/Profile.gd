extends HistoryData
class_name Profile

# ==============================================================================
## The name of the profile.
var name := ""

## The [Quest]s created in the profile.
var quests: Array[Quest] = []

## Whether the profile is currently in a [Quest].
var in_quest := false
## Whether the profile is currently in the Arena gamemode.
## [Quest]s should not be loaded while in this gamemode.
var in_arena := false
# ==============================================================================

## Creates a new [Quest] and returns it. Also finishes the old quest if it was not finished.
func new_quest() -> Quest:
	var quest := Quest.new()
	
	if not quests.is_empty() and not quests[-1].finished:
		quests[-1].finish(false)
	
	quests.append(quest)
	
	in_quest = true
	
	return quest


static func _from_dict(dict: Dictionary) -> Profile:
	if ["name", "in_quest", "quests"].any(func(key: String): return not key in dict):
		return null
	
	var profile := Profile.new()
	
	profile.name = dict.name
	profile.in_quest = dict.in_quest
	
	for quest_dict in dict.quests:
		profile.quests.append(Quest._from_dict(quest_dict))
	
	return profile


func _import_quests(array: Array) -> void:
	quests.clear()
	
	for quest_json in array:
		quests.append(HistoryData.from_json(quest_json, Quest))


func _export_quests() -> Array[Dictionary]:
	var quest_array: Array[Dictionary] = []
	
	for quest in quests:
		quest_array.append(quest.to_json())
	
	return quest_array


func _export_in_arena() -> String:
	return NO_EXPORT
