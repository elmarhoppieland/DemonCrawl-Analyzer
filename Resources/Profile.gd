extends HistoryData
class_name Profile

# ==============================================================================
enum Statistic {
	CHESTS_OPENED,
	ARTIFACTS_COLLECTED,
	ITEMS_AQUIRED,
	LIVES_RESTORED,
	COINS_SPENT,
	MASTERY_ABILITY_USES
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
	Statistic.MASTERY_ABILITY_USES: 0, # the total number of times any mastery III ability has been used
}

## When a [LogFileReader] stops reading. Each [String] is formatted as
## [code]CONDITION:quest_index:stage_index[/code]
##
## [br][br]The condition contains a [code]Q[/code] if the [LogFileReader] stops reading
## during a [Quest], and a [code]C[/code] if the [LogFileReader] stops reading due to a DemonCrawl crash.
##
## [br][br][code]stage_index[/code] ends with a [code]-[/code] if the player was at
## the [Stage] select screen.
##
## [br][br]If the player is not in a [Quest] when the [LogFileReader] stops reading,
## the [String] is set to [code]:-1:-1[/code].
##
## [br][br][b]Examples:[/b]
## [br]- [code]Q:2:7[/code]: The player was in quest 2, inside stage 7.
## [br]- [code]:-1:-1[/code]: The player was not in a quest.
## [br]- [code]QC:5:0-[/code]: The player was in quest 5, on the stage select before stage 1. The game crashed.
## [br]- [code]C:-1:-1[/code]: The player was not in a quest. The game crashed. [b]This is quite rare.[/b]
var read_cutoffs: PackedStringArray = []
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


static func _from_dict(dict: Dictionary) -> Profile:
	if ["name", "in_quest", "quests"].any(func(key: String): return not key in dict):
		return null
	
	var profile := Profile.new()
	
	profile.name = dict.name
	profile.in_quest = dict.in_quest
	
	for quest_dict in dict.quests:
		profile.quests.append(Quest._from_dict(quest_dict))
	
	return profile
