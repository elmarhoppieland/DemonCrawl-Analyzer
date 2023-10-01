extends HistoryData
class_name Stage

## A DemonCrawl stage.

# ==============================================================================
var name := "" ## The name of the stage, without any stage mods.
var full_name := "" ## The name of the stage, including the first 2 stage mods.
var mods := PackedStringArray() ## The mods of the stage. [br][br][b]Note:[/b] Only contains the first 2 stage mods.
var adjective := "" ## The adjective of the stage, if applicable.

var enter: StageEnter ## The state of the quest when the stage is entered.
var exit: StageExit ## The state of the quest when the stage is exited.
var death: StageExit ## The state of the quest when the player dies.

var points_gained := 0 ## The amount of points gained in the stage.
var chests_opened := 0 ## The number of chests opened in the stage.
var artifacts_collected := 0 ## the number of artifacts collected in the stage.
var lives_restored := 0 ## The amount of lives restored while in the stage.
var coins_gained := 0 ## The amount of coins gained while in the stage
var coins_spent := 0 ## The amount of coins spent while in the stage

var time_spent := "" ## The time spent in the stage.
# ==============================================================================

## Sets [member name] and [member full_name] to represent a stage with the given name.
func with_name(_full_name: String) -> Stage:
	full_name = _full_name
	name = _full_name.get_slice(" ", _full_name.get_slice_count(" ") - 1)
	return self


## Exits the stage and returns the new [StageExit].
func exit_stage() -> StageExit:
	exit = StageExit.new()
	return exit


## Returns the [Texture2D] that is used by the game as the stage's background.
func get_bg_texture() -> ImageTexture:
	return Stage.get_bg_texture_absolute(name)


## Static version of [method get_bg_texture].
static func get_bg_texture_absolute(stage_name: String) -> ImageTexture:
	var image := Image.load_from_file(DemonCrawl.get_data_dir().path_join("assets/skins/%s/bg.png" % stage_name.to_lower()))
	return ImageTexture.create_from_image(image)


## Returns whether [code]stage_name[/code] is an existing stage.
static func stage_exists(stage_name: String) -> bool:
	if stage_name.is_empty():
		return false
	
	return DirAccess.dir_exists_absolute(DemonCrawl.get_data_dir().path_join("assets/skins/" + stage_name.to_lower()))


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
