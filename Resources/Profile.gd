extends HistoryData
class_name Profile

# ==============================================================================
## The name of the profile.
var name := ""

## The [Quest]s created in the profile.
var quests: Array[Quest] = []

## Whether the profile is currently in a [Quest].
var in_quest := false
# ==============================================================================

## Creates a new [Quest] and returns it. Also finishes the old quest if it was not finished.
func new_quest() -> Quest:
	var quest := Quest.new()
	
	if not quests.is_empty() and not quests[-1].finished:
		quests[-1].finished = true
		quests[-1].victory = false
		quests[-1].in_stage = false
	
	quests.append(quest)
	
	in_quest = true
	
	return quest


static func _from_dict(dict: Dictionary) -> Profile:
	if ["name", "in_quest", "quests"].any(func(key): return not key in dict.keys()):
		return null
	
	var profile := Profile.new()
	
	profile.name = dict.name
	profile.in_quest = dict.in_quest
	
	for quest_dict in dict.quests:
		profile.quests.append(Quest._from_dict(quest_dict))
	
	return profile
