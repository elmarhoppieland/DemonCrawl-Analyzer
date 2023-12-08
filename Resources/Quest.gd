extends HistoryData
class_name Quest

## A DemonCrawl Quest.

# ==============================================================================
enum Statistic {
	CHESTS_OPENED, ## The total number of chests opened.
	ARTIFACTS_COLLECTED, ## The total number of artifacts collected.
	ITEMS_AQUIRED, ## The total number of items aquired.
	LIVES_RESTORED, ## The total number of lives restored.
	COINS_SPENT, ## The total number of coins spent.
	COUNT ## Represents the size of the [enum Statistic] enum.
}
enum Difficulty {
	CASUAL, # ___00
	NORMAL, # ___01
	HARD, # ___10
	BEYOND # ___11
}
enum Type {
	GLORY_DAYS = 0, # 000__
	RESPITES_END = 4, # 001__
	ANOTHER_WAY = 8, # 010__
	AROUND_THE_BEND = 12, # 011__
	SHADOWMAN = 16, # 100__
	ENDLESS_MULTIVERSE = 20, # 101__
	HERO_TRIALS = 24, # 110__
	BEYOND = 28 # 111__
}
enum MasteryTier {
	UNSET,
	TIER_I,
	TIER_II,
	TIER_III
}
enum Status {
	UNFINISHED = 0b00,
	FINISHED = 0b10,
	LOSS = 0b10,
	VICTORY = 0b11,
}
# ==============================================================================
## The name of the quest.
var name := ""
var type := Difficulty.CASUAL | Type.GLORY_DAYS

## The name of the mastery used.
var mastery := ""
## The tier of the mastery.
var mastery_tier := MasteryTier.UNSET
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

## The player's statistics in this quest.
var statistics := {
	Statistic.CHESTS_OPENED: 0, # the total number of chests opened
	Statistic.ARTIFACTS_COLLECTED: 0, # the total number of artifacts collected
	Statistic.ITEMS_AQUIRED: 0, # the total number of items aquired
	Statistic.LIVES_RESTORED: 0, # the total number of lives restored
	Statistic.COINS_SPENT: 0, # the total number of coins spent
}

## The errors that occured in this quest.
var errors: Array[Dictionary] = []
# ==============================================================================

static func _from_dict(dict: Dictionary) -> Quest:
	var quest := Quest.new()
	
	# check if all Quest properties are in dict
	if quest.get_script().get_script_property_list().any(func(property): return property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and not property.name in dict):
		return null
	
	for property in ["name", "type", "mastery", "mastery_tier", "duration", "creation_timestamp", "victory", "in_stage", "finished"]:
		quest.set(property, dict[property])
	
	for stage_dict in dict.stages:
		quest.stages.append(Stage._from_dict(stage_dict))
	
	for statistic in quest.statistics:
		quest.statistics[statistic] = dict.statistics[str(statistic)]
	
	quest.inventory = Inventory.from_array(dict.inventory.items)
	
	return quest


## Finishes the quest. It is considered a victory if [code]is_victory[/code] is
## [code]true[/code]. Otherwise, it is considered a loss.
func finish(is_victory: bool = false) -> void:
	finished = true
	in_stage = false
	victory = is_victory


## Enters a new [Stage] with the given [code]stage_name[/code] and returns the [Stage].
func enter_stage(stage_name: String) -> Stage:
	var stage := Stage.new()
	
	stage.full_name = stage_name
	
	stages.append(stage)
	
	in_stage = true
	
	stage.enter = StageEnter.new()
	stage.enter.inventory = inventory.duplicate()
	
	return stage


## Exits the current [Stage] and returns the new [StageExit]. Returns [code]null[/code]
## if the last entered stage does not have [code]full_name[/code] set to [code]stage_name[/code]
## or if the player is not in a stage.
func exit_stage(stage_name: String = "") -> StageExit:
	if not in_stage:
		push_error("Attempted to exit a stage while not in a stage.")
		return null
	
	if stages.is_empty():
		push_error("Attempted to exit a stage while no stage has been entered.")
		return null
	
	var stage := stages[-1]
	if not stage_name.is_empty() and stage.full_name != stage_name:
		return null
	
	var exit := stage.exit_stage()
	exit.inventory = inventory.duplicate()
	
	in_stage = false
	
	return stage.exit


## Finishes the quest as a loss and returns the [StageExit] created. The [member Stage.death]
## property will be updated automatically.
func die() -> StageExit:
	if stages.is_empty():
		return null
	
	var stage := stages[-1]
	stage.death = StageExit.new()
	stage.death.inventory = inventory.duplicate()
	
	finish()
	
	return stage.death


func matches_filters(filters: Dictionary) -> bool:
	var unix := TimeHelper.get_unix_time_from_timestamp(creation_timestamp)
	if Statistics.Filter.TIME_AFTER in filters:
		var after_unix := Time.get_unix_time_from_datetime_string(filters[Statistics.Filter.TIME_AFTER])
		if unix < after_unix:
			return false
	if Statistics.Filter.TIME_BEFORE in filters:
		var before_unix := Time.get_unix_time_from_datetime_string(filters[Statistics.Filter.TIME_BEFORE])
		if unix > before_unix:
			return false
	if Statistics.Filter.QUEST_TYPE in filters:
		if not type in filters[Statistics.Filter.QUEST_TYPE].values():
			return false
	
	return true


## Returns a [enum Statistic] from this profile.
func get_statistic(statistic: Statistic) -> int:
	if not statistic in statistics:
		return -1
	
	return statistics[statistic]


## Increments a [enum Statistic] from this profile by [code]amount[/code].
func increment_statistic(statistic: Statistic, amount: int = 1) -> void:
	if not statistic in statistics:
		return
	
	statistics[statistic] += amount


func _import_stages(array: Array) -> void:
	stages.clear()
	
	for stage_json in array:
		stages.append(HistoryData.from_json(stage_json, Stage))


func _import_inventory(json: Dictionary) -> void:
	inventory = HistoryData.from_json(json, Inventory)


func _import_statistics(statistics_json: Dictionary) -> void:
	for statistic in statistics_json:
		statistics[statistic.to_int()] = statistics_json[statistic]


func _import_errors(errors_json: Array) -> void:
	errors.append_array(errors_json)


func _export_stages() -> Array[Dictionary]:
	var stage_array: Array[Dictionary] = []
	
	for stage in stages:
		stage_array.append(stage.to_json())
	
	return stage_array


static func get_type_int(type_string: String) -> Type:
	return Type[type_string.replace("Respite's", "Respites").to_upper().replace(" ", "_")]
