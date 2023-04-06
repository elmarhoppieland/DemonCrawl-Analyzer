extends HistoryData
class_name Profile

# ==============================================================================
enum Statistic {
	CHESTS_OPENED, ## The total number of chests opened.
	ARTIFACTS_COLLECTED, ## The total number of artifacts collected.
	ITEMS_AQUIRED, ## The total number of items aquired.
	LIVES_RESTORED, ## The total number of lives restored.
	COINS_SPENT, ## The total number of coins spent.
	COUNT ## Represents the size of the [enum Statistic] enum.
}
# ==============================================================================
## The name of the profile.
var name := ""

## The [Quest]s created in the profile.
var quests: Array[Quest] = []

## Whether the profile is currently in a [Quest].
var in_quest := false

## The player's statistics in this profile.
var statistics := {
	Statistic.CHESTS_OPENED: 0, # the total number of chests opened
	Statistic.ARTIFACTS_COLLECTED: 0, # the total number of artifacts collected
	Statistic.ITEMS_AQUIRED: 0, # the total number of items aquired
	Statistic.LIVES_RESTORED: 0, # the total number of lives restored
	Statistic.COINS_SPENT: 0, # the total number of coins spent
}
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


func get_statistic(statistic: Statistic) -> int:
	if not statistic in statistics:
		return -1
	
	return statistics[statistic]


func increment_statistic(statistic: Statistic, amount: int = 1) -> void:
	if not statistic in statistics:
		return
	
	statistics[statistic] += amount


static func _from_dict(dict: Dictionary) -> Profile:
	if ["name", "in_quest", "quests", "statistics"].any(func(key: String): return not key in dict):
		return null
	
	var profile := Profile.new()
	
	profile.name = dict.name
	profile.in_quest = dict.in_quest
	
	for quest_dict in dict.quests:
		profile.quests.append(Quest._from_dict(quest_dict))
	
	for statistic in profile.statistics:
		profile.statistics[statistic] = dict.statistics[str(statistic)]
	
	return profile
