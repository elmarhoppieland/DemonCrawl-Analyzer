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
