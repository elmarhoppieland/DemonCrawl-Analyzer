extends HistoryData
class_name Quest

## A DemonCrawl Quest.

# ==============================================================================
enum mastery_tiers {
	UNSET,
	TIER_I,
	TIER_II,
	TIER_III
}
enum quest_difficulty {
	CASUAL = -1,
	NORMAL,
	HARD,
	BEYOND
}
# ==============================================================================
## The name of the quest.
var name := ""
## The difficulty of the quest. [br][br][b]Note:[/b] If the [member name]
## is [code]Beyond[/code], this will always be [constant BEYOND].
var difficulty := quest_difficulty.NORMAL

## The name of the mastery used.
var mastery := ""
## The tier of the mastery.
var mastery_tier := mastery_tiers.UNSET
## The duration of the quest.
var duration := ""

## The time when the quest was first created.
var creation_timestamp := ""

## The stages in the quest.
var stages: Array[Stage] = []

## The player's [Inventory].
var inventory := Inventory.new()

## If the quest is finished, whether the quest was a victory.
var victory := false
## Whether the player is currently in a [Stage].
var in_stage := false
## Whether the quest is finished.
var finished := false
# ==============================================================================

## Finishes the quest. It is considered a victory if [code]is_victory[/code] is
## [code]true[/code]. Otherwise, it is considered a loss.
func finish(is_victory: bool = false) -> void:
	finished = true
	in_stage = false
	victory = is_victory


static func _from_dict(dict: Dictionary) -> Quest:
	var quest := Quest.new()
	
	# check if all Quest properties are in dict
	if quest.get_script().get_script_property_list().any(func(property): return property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and not property.name in dict):
		return null
	
	for property in ["name", "difficulty", "mastery", "mastery_tier", "duration", "creation_timestamp", "victory", "in_stage", "finished"]:
		quest.set(property, dict[property])
	
	for stage_dict in dict.stages:
		quest.stages.append(Stage._from_dict(stage_dict))
	
	quest.inventory = Inventory._from_array(dict.inventory.items)
	
	return quest
