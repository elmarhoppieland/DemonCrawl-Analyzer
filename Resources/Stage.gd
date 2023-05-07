extends HistoryData
class_name Stage

## A DemonCrawl stage.

# ==============================================================================
## The name of the stage, without any stage mods.
var name := ""
## The name of the stage, including the first 2 stage mods.
var full_name := ""
## The mods of the stage. [br][br][b]Note:[/b] Only contains the first 2 stage mods.
var mods := PackedStringArray()
## The adjective of the stage, if applicable.
var adjective := ""

## The state of the quest when the stage is entered.
var enter: StageEnter
## The state of the quest when the stage is exited.
var exit: StageExit
## The state of the quest when the player dies.
var death: StageExit

## The time spent in the stage.
var time_spent := ""
# ==============================================================================

## Exits the stage and returns the new [StageExit].
func exit_stage() -> StageExit:
	exit = StageExit.new()
	return exit


static func _from_dict(dict: Dictionary) -> Stage:
	var stage := Stage.new()
	
	# check if all Stage properties are in dict
	if stage.get_script().get_script_property_list().any(func(property): return property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and not property.name in dict):
		return null
	
	for property in ["name", "full_name", "mods", "adjective", "time_spent"]:
		stage.set(property, dict[property])
	
	stage.enter = StageEnter._from_dict(dict.enter)
	if dict.exit:
		stage.exit = StageExit._from_dict(dict.exit)
	if dict.death:
		stage.death = StageExit._from_dict(dict.death)
	
	return stage


func _import_enter(json: Dictionary) -> void:
	enter = HistoryData.from_json(json, StageEnter)


func _import_exit(json: Dictionary) -> void:
	exit = HistoryData.from_json(json, StageExit)


func _import_death(json: Dictionary) -> void:
	death = HistoryData.from_json(json, StageExit)
