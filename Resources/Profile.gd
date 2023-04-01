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

func new_quest() -> Quest:
	var quest := Quest.new()
	
	if not quests.is_empty() and not quests[-1].finished:
		quests[-1].finished = true
		quests[-1].victory = false
		quests[-1].in_stage = false
	
	quests.append(quest)
	
	in_quest = true
	
	return quest
