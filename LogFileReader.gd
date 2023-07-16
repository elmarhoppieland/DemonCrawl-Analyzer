extends RefCounted
class_name LogFileReader

## Class that can read DemonCrawl log files.

# ==============================================================================
enum Line {
	NONE = 0, ## Line does not match any other [enum Line] constant.
	PROFILE_LOAD = 1, ## A [Profile] was loaded in the line.
	QUEST_CREATE = 2 * PROFILE_LOAD, ## A [Quest] was created in the line.
	STAGE_BEGIN = 2 * QUEST_CREATE, ## A [Stage] was entered in the line.
	STAGE_FINISH = 2 * STAGE_BEGIN, ## A [Stage] has been finished in the line (the FINISH button pops up).
	STAGE_LEAVE = 2 * STAGE_FINISH, ## A [Stage] was exited in the line.
	ITEM_GAIN = 2 * STAGE_LEAVE, ## An item was gained in the line.
	ITEM_LOSE = 2 * ITEM_GAIN, ## An item was lost in the line.
	ITEM_GAIN_LOSE = ITEM_GAIN | ITEM_LOSE, ## Allow gaining and losing items.
	CHEST_OPENED = 2 * ITEM_LOSE, ## A chest was opened in the line.
	ARTIFACT_COLLECTED = 2 * CHEST_OPENED, ## An artifact was collected in the line.
	LIVES_RESTORED = 2 * ARTIFACT_COLLECTED, ## The player restored 1 or more lives in the line.
	COINS_SPENT = 2 * LIVES_RESTORED, ## The player spent coins in the line.
	PLAYER_DEATH = 2 * COINS_SPENT, ## The player was killed in the line.
	LEADERBOARD_SUBMIT = 2 * PLAYER_DEATH, ## The player's score was submitted to the leaderboards in the line.
	PLAYER_STATS = 2 * LEADERBOARD_SUBMIT, ## The line shows the player's stats.
	MASTERY_SELECTED = 2 * PLAYER_STATS, ## The player's mastery is selected in the line.
	QUEST_ABORT = 2 * MASTERY_SELECTED, ## The [Quest] was aborted in the line.
	DEMONCRAWL_STARTED = 2 * QUEST_ABORT, ## DemonCrawl was launched in the line.
	DEMONCRAWL_CLOSED = 2 * DEMONCRAWL_STARTED, ## DemonCrawl was closed in the line.
	ARENA_CONNECT = 2 * DEMONCRAWL_CLOSED, ## The player connected to arena in the line.
	ERROR_CODE_ALERT = 2 * ARENA_CONNECT, ## DemonCrawl threw an error in the line. The next lines will contain the error message.
	ALL = 2 * ERROR_CODE_ALERT - 1, ## Allow all (useful) lines.
}
const _LINE_FILTERS := {
	Line.PROFILE_LOAD: "Profile loaded: *",
	Line.QUEST_CREATE: "Quest started: *",
	Line.STAGE_BEGIN: "Begin stage *",
	Line.STAGE_FINISH: "Completed stage * in * seconds",
	Line.STAGE_LEAVE: "Leaving stage *",
	Line.ITEM_GAIN: "* was added to inventory slot #*",
	Line.ITEM_LOSE: "* was removed from inventory slot #*",
	Line.CHEST_OPENED: "Opening chest",
	Line.ARTIFACT_COLLECTED: "Collected artifact: *",
	Line.LIVES_RESTORED: "* li*e* restored! You now have */* lives.",
	Line.COINS_SPENT: "* coins spent. You now have * coins.",
	Line.PLAYER_DEATH: "* was killed!",
	Line.LEADERBOARD_SUBMIT: "Alert: Submitting score to Leaderboard...",
	Line.PLAYER_STATS: "Player stats: *",
	Line.MASTERY_SELECTED: "Mastery selected: *",
	Line.QUEST_ABORT: "Quest aborted",
	Line.DEMONCRAWL_STARTED: "DemonCrawl started",
	Line.DEMONCRAWL_CLOSED: "DemonCrawl closed",
	Line.ARENA_CONNECT: "Connected to DemonCrawl Arena",
	Line.ERROR_CODE_ALERT: "Alert: Error Code * - check log for details",
}
# ==============================================================================
## The path to the log file.
var file_path := ""

## The log file.
var file: FileAccess

var _lines: PackedStringArray = []
## The line index that is currently being read.
var position := -1

var _last_line := ""

var errors: Array[Dictionary] = []
# ==============================================================================

## Returns a new [LogFileReader] that reads the file at [code]log_path[/code].
static func read(log_path: String) -> LogFileReader:
	var reader := LogFileReader.new()
	
	reader.file = FileAccess.open(log_path, FileAccess.READ)
	if not reader.file:
		return null
	
	reader.file_path = log_path
	
	var file_text := reader.file.get_as_text()
	var split := file_text.split("\n")
	for line_index in split.size():
		var line := split[line_index]
		var line_trimmed := line.get_slice("] ", 1)
		var line_type := get_line_type(line)
		if line_type == Line.NONE:
			continue
		
		if line_type == Line.ERROR_CODE_ALERT:
			var error := {
				"code": line_trimmed.get_slice(" ", 3),
				"short_message": "",
				"long_message": "",
				"script": "",
				"stack_trace": PackedStringArray(),
				"info": PackedStringArray(),
				"date": ""
			}
			reader.errors.append(error)
			
			error.date = line.get_slice("]", 0).trim_prefix("[")
			
			var plus_index := 1
			var error_line_full := split[line_index + 1]
			var error_line := error_line_full.get_slice("] ", 1)
			
			# short message
			error.short_message = error_line.get_slice(": ", 1)
			
			plus_index += 1
			
			# long message
			while true:
				plus_index += 1
				if plus_index > 15:
					break # the message shouldn't be this long so there's probably some kind of bug
				
				error_line_full = split[line_index + plus_index]
				if error_line_full.begins_with("["):
					break
				if error.long_message.is_empty():
					error.long_message = error_line_full.strip_edges()
				else:
					error.long_message += "\n" + error_line_full.strip_edges()
			
			error_line = error_line_full.get_slice("] ", 1).strip_edges()
			
			# script
			var script := error_line.get_slice(" ", error_line.get_slice_count(" ") - 1)
			error.script = script
			
			# stack trace
			while true:
				plus_index += 1
				error_line_full = split[line_index + plus_index]
				error_line = error_line_full.get_slice("] ", 1).strip_edges()
				if not error_line.match("ERROR * stracktrace[*]: * (line *)"):
					break
				
				var trace_index := error_line.get_slice("stracktrace[", 1).get_slice("]", 0).to_int()
				var trace_message := error_line.get_slice("]: ", 1)
				var error_stack_trace: PackedStringArray = error.stack_trace
				if error_stack_trace.size() <= trace_index:
					error_stack_trace.resize(trace_index + 1)
				error_stack_trace[trace_index] = trace_message
			
			# extra info
			while true:
				if not error_line.begins_with("ERROR"):
					break
				
				error.info.append(error_line.trim_prefix("ERROR %s " % error.code))
				
				plus_index += 1
				error_line_full = split[line_index + plus_index]
				error_line = error_line_full.get_slice("] ", 1).strip_edges()
			
			
			continue
		
		reader._lines.append(line.strip_edges())
	
	return reader


## Returns the line type of [code]line[/code]. If [code]line[/code] does not match
## any [enum Line] constant, returns [constant NONE].
static func get_line_type(line: String) -> Line:
	if line.match("[*-*-* @ *:*:*] *"):
		line = line.get_slice("]", 1).strip_edges()
	
	if line.is_empty():
		return Line.NONE
	
	for line_type in _LINE_FILTERS:
		var filter = _LINE_FILTERS[line_type]
		if filter is String:
			if line.match(filter):
				return line_type
		elif filter is PackedStringArray or filter is Array:
			for string in filter:
				if line.match(string):
					return line_type
	
	return Line.NONE


## Advances to the next [Profile] declaration and returns it.
func get_next_profile() -> Profile:
	var line := get_current_line()
	
	while not line.begins_with("Profile loaded: "):
		line = get_line()
		if line.is_empty():
			return null
	
	return handle_profile_load()


## Advances to the creation of the next [Quest] and returns a new [Quest] for that quest.
## If [code]profile[/code] is not [code]null[/code], adds the new quest to the [Profile].
func get_next_quest(profile: Profile = null) -> Quest:
	var line := get_current_line()
	
	while not line.begins_with("Quest started: "):
		line = get_line()
		if line.is_empty():
			return null
	
	return handle_quest_create(profile)


## Advances to the next [Stage] enter and returns a new [Stage] for that stage.
## [br]Also handles: [constant ITEM_GAIN], [constant ITEM_LOSE], [constant PLAYER_DEATH],
## [constant QUEST_CREATE] and [constant LEADERBOARD_SUBMIT].
func get_next_stage(inventory: Inventory, profile: Profile = null, quest: Quest = null) -> Stage:
	var line := get_current_line()
	
	if profile and not quest and not profile.quests.is_empty():
		quest = profile.quests[-1]
	
	while not line.begins_with("Begin stage "):
		line = get_line()
		
		if line.is_empty():
			return null
		
		var data := handle_current_line(Line.STAGE_BEGIN | Line.ITEM_GAIN | Line.ITEM_LOSE | Line.PLAYER_DEATH | Line.QUEST_CREATE | Line.LEADERBOARD_SUBMIT, profile)
		if data is Stage:
			return data
		if data is Quest:
			return null
		if data is StageExit:
			return null
		
		if profile and not profile.in_quest:
			return null
	
	push_warning("Stage enter was not detected by handle_current_line().")
	
	return handle_stage_enter(inventory, profile, quest)


## Advances to the next [StageExit] and returns it.
## [br]Also handles: [constant ITEM_GAIN], [constant ITEM_LOSE], [constant PLAYER_DEATH],
## [constant QUEST_CREATE] and [constant LEADERBOARD_SUBMIT].
func get_next_stage_exit(profile: Profile = null) -> StageExit:
	while not LogFileReader.get_line_type(get_current_line()) == Line.STAGE_LEAVE:
		if get_current_line().is_empty():
			return null
		
		var data := handle_current_line(Line.STAGE_LEAVE | Line.ITEM_GAIN | Line.ITEM_LOSE | Line.PLAYER_DEATH | Line.QUEST_CREATE | Line.LEADERBOARD_SUBMIT, profile)
		if profile and not profile.in_quest:
			return null
		if data is StageExit:
			return data
		if data is Quest:
			return null
		
		next_line()
	
	return handle_current_line(Line.STAGE_LEAVE, profile)


## Advances to the next line that matches at least one of the filters in
## [code]filters[/code] and returns the line. Returns an empty [String] ([code]""[/code])
## if the end of the file is reached.
## [br][br]Also handles any lines it comes across that matches a [enum Line]
## constant set in [code]handle_line_types[/code].
## [br][br][b]Note:[/b] Unlike other methods, this method always advances at least 1 line.
func look_for(filters: int, handle_line_types: int = Line.NONE, profile: Profile = null, quest: Quest = null, inventory: Inventory = null, stage: Stage = null) -> String:
	next_line()
	
	while not LogFileReader.get_line_type(get_current_line()) & filters:
		next_line()
		
		if handle_line_types:
			handle_current_line(handle_line_types, profile, quest, inventory, stage)
	
	return get_current_line()


## Handles the current line and returns any [HistoryData] created. Updates [code]profile[/code],
## [code]quest[/code], [code]inventory[/code] and [code]stage[/code] if they are not [code]null[/code].
##
## [br][br]Some [enum Line] constants require arguments:
## [br]- [constant BEGIN_STAGE]: Requires [code]inventory[/code]. Can also use [code]quest[/code].
## [br]- [constant LEAVE_STAGE]: Requires [code]inventory[/code]. Can also use [code]quest[/code].
## [br]- [constant ITEM_GAIN]: Requires [code]inventory[/code].
## [br]- [constant ITEM_LOSE]: Requires [code]inventory[/code].
## [br]- [constant PLAYER_DEATH]: Requires [code]inventory[/code]. Can also use [code]stage[/code].
##
## [br][br]Different [enum Line] constants have different return types:
## [br]- [constant PROFILE_LOAD]: [Profile]
## [br]- [constant QUEST_CREATE]: [Quest]
## [br]- [constant BEGIN_STAGE]: [Stage]
## [br]- [constant LEAVE_STAGE]: [StageExit]
## [br]- [constant ITEM_GAIN]: [code]null[/code]
## [br]- [constant ITEM_LOSE]: [code]null[/code]
## [br]- [constant PLAYER_DEATH]: [StageExit]
## [br]- [constant LEADERBOARD_SUBMIT]: [code]null[/code]
## [br]- [constant MASTERY_SELECTED]: [code]null[/code]
##
## [br][br][b]Note:[/b] Automatically finds [code]quest[/code], [code]inventory[/code]
## and [code]stage[/code] if [code]profile[/code] is not [code]null[/code]. They
## can still be passed into the method call to override their defaults.
func handle_current_line(allowed_line_types: int, profile: Profile = null, quest: Quest = null, inventory: Inventory = null, stage: Stage = null) -> HistoryData:
	if LogFileReader.get_line_type(get_current_line()) == Line.ITEM_GAIN:
		# if the player starts a Beyond quest with an emblem that gives items,
		# the items are gained before starting the quest so we'll have to swap
		# the lines around so that the quest is created first
		var lines := get_current_timestamp_lines()
		for i in lines.size():
			var line := lines[i]
			if LogFileReader.get_line_type(line) == Line.QUEST_CREATE:
				var quest_create_string := _lines[position + i]
				
				if i > 0:
					# move the line where the quest was created so that it's at the current position
					_lines.remove_at(position + i)
					_lines.insert(position, quest_create_string)
	
	if allowed_line_types == Line.NONE:
		return null
	
	var line := get_line(position)
	if line.is_empty():
		return null
	
	
	var line_type := LogFileReader.get_line_type(line)
	if not allowed_line_types & line_type:
		# we aren't allowed to handle the current line
		return null
	
	if profile and not quest and not profile.quests.is_empty():
		quest = profile.quests[-1]
	if quest and not stage and quest.in_stage:
		stage = quest.stages[-1]
	if quest and not inventory:
		inventory = quest.inventory
	
	match line_type:
		Line.PROFILE_LOAD:
			return handle_profile_load(profile)
		Line.QUEST_CREATE:
			return handle_quest_create(profile)
		Line.STAGE_BEGIN:
			return handle_stage_enter(inventory, profile, quest)
		Line.STAGE_FINISH:
			handle_stage_finish(stage)
			return null
		Line.STAGE_LEAVE:
			return handle_stage_exit(inventory, quest, stage)
		Line.ITEM_GAIN:
			handle_gain_item(inventory, profile, quest)
			return null
		Line.ITEM_LOSE:
			handle_lose_item(inventory, profile)
			return null
		Line.CHEST_OPENED:
			if profile and profile.in_arena:
				return null
			if quest:
				quest.increment_statistic(Quest.Statistic.CHESTS_OPENED)
			return null
		Line.ARTIFACT_COLLECTED:
			if profile and profile.in_arena:
				return null
			if quest:
				quest.increment_statistic(Quest.Statistic.ARTIFACTS_COLLECTED)
			return null
		Line.LIVES_RESTORED:
			if profile and profile.in_arena:
				return null
			if quest:
				quest.increment_statistic(Quest.Statistic.LIVES_RESTORED, line.get_slice(" ", 0).to_int())
			return null
		Line.COINS_SPENT:
			if profile and profile.in_arena:
				return null
			if quest:
				quest.increment_statistic(Quest.Statistic.COINS_SPENT, line.get_slice(" ", 0).to_int())
			return null
		Line.PLAYER_DEATH:
			return handle_player_death(inventory, stage, profile)
		Line.LEADERBOARD_SUBMIT:
			if profile and profile.in_arena:
				return null
			if profile:
				profile.in_quest = false
			if quest:
				quest.finish(true)
			
			return null
		Line.MASTERY_SELECTED:
			if profile and profile.in_arena:
				return null
			if quest:
				quest.mastery = line.trim_prefix("Mastery selected: ").get_slice(" ", 0).capitalize()
				@warning_ignore("int_as_enum_without_cast")
				quest.mastery_tier = line[-1].to_int()
			
			return null
		Line.QUEST_ABORT:
			if profile and profile.in_arena:
				return null
			if quest:
				quest.finish()
			if profile:
				profile.in_quest = false
			
			return null
		Line.ARENA_CONNECT:
			profile.in_arena = true
			return null
	
	return null


## Handles loading of a [Profile] and returns the new [Profile].
func handle_profile_load(old_profile: Profile = null) -> Profile:
	if old_profile:
		old_profile.in_arena = false
	
	var profile := Profile.new()
	
	profile.name = get_current_line().trim_prefix("Profile loaded: ")
	if profile.name.is_empty():
		return null
	
	return profile


## Handles creation of a [Quest] and returns the new [Quest].
## If [code]profile[/code] is not [code]null[/code], adds the new quest to the [Profile].
func handle_quest_create(profile: Profile = null) -> Quest:
	if profile and not profile.quests.is_empty():
		var old_quest := profile.quests[-1]
		
		if not old_quest.finished:
			old_quest.finish()
	
	var line := get_current_line()
	
	var quest := Quest.new()
	
	@warning_ignore("int_as_enum_without_cast")
	quest.name = line.get_slice(" on ", 0).trim_prefix("Quest started: ")
	var difficulty := line[-1].to_int() + 1
	var type: Quest.Type = Quest.Type[quest.name.replace("'", "").to_snake_case().to_upper()]
	quest.type = difficulty | type
	
	quest.creation_timestamp = get_timestamp()
	
	if profile:
		profile.quests.append(quest)
	
	profile.in_quest = true
	
	return quest


## Handles gaining of an item. Adds the item gained in [code]line[/code] to [code]inventory[/code].
func handle_gain_item(inventory: Inventory, profile: Profile = null, quest: Quest = null) -> void:
	if quest and not inventory:
		inventory = quest.inventory
	if not inventory:
		return
	if profile and profile.in_arena:
		return
	
	var split := get_current_line().split(" ", false)
	
	var item_name := ""
	for word in split:
		if word == "was":
			break
			
		if item_name != "":
			item_name += " "
		
		item_name += word
	
	var index := inventory.get_free_slot()
	
	inventory.items[index] = item_name
	
	if quest:
		quest.increment_statistic(Quest.Statistic.ITEMS_AQUIRED)


## Handles losing of an item. Removes the item lost in [code]line[/code] from [code]inventory[/code].
func handle_lose_item(inventory: Inventory, profile: Profile = null) -> void:
	if not inventory:
		return
	if profile and profile.in_arena:
		return
	
	var index := get_current_line().split(" ")[-1].trim_prefix("#").to_int() - 1
	
	inventory.items.remove_at(index)
	inventory.items.append("")


## Handles entering of a stage. Returns the [Stage] entered in [code]line[/code].
## If [code]quest[/code] is not [code]null[/code], adds the [Stage] to the [Quest].
func handle_stage_enter(inventory: Inventory, profile: Profile = null, quest: Quest = null) -> Stage:
	if not inventory:
		return null
	if profile and profile.in_arena:
		return null
	
	var stage := Stage.new()
	
	stage.full_name = get_current_line().trim_prefix("Begin stage ")
	
	var stage_name := stage.full_name.split(" ")
	
	match stage_name.size():
		1:
			stage.name = stage_name[0]
		2:
			if stage_name[0] in GlobalGameData.STAGE_MODS:
				stage.mods = [stage_name[0]]
			else:
				stage.adjective = stage_name[0]
			
			stage.name = stage_name[1]
		3:
			stage.mods = [stage_name[0]]
			if stage_name[1] in GlobalGameData.STAGE_MODS:
				stage.mods.append(stage_name[1])
			else:
				stage.adjective = stage_name[1]
			
			stage.name = stage_name[2]
		4:
			stage.mods = [stage_name[0], stage_name[1]]
			
			stage.adjective = stage_name[2]
			stage.name = stage_name[3]
	
	stage.enter = StageEnter.new()
	if inventory:
		stage.enter.inventory = inventory.duplicate()
	
	# the stats should be in the next line, but passing inventory just in case they're not
	var stats_string := look_for(Line.PLAYER_STATS)
	stage.enter.stats = PlayerStats.from_string(stats_string.trim_prefix("Player stats: "))
	
	if quest:
		quest.stages.append(stage)
	
	quest.in_stage = true
	
	return stage


## Handles finishing of a [Stage]. A stage is finished once the FINISH button pops up.
func handle_stage_finish(stage: Stage) -> void:
	if not stage:
		# this shouldn't ever happen but sometimes it does for some reason
		return
	
	var line := get_current_line()
	
	var seconds := line.split(" ")[-2].to_int()
	var minutes := floori(seconds / 60.0)
	var hours := floori(minutes / 60.0)
	
	seconds -= minutes * 60
	minutes -= hours * 60
	
	if hours > 0:
		stage.time_spent = "%d:%02d:%02d" % [hours, minutes, seconds]
	else:
		stage.time_spent = "%d:%02d" % [minutes, seconds]


## Handles exiting of a [Stage]. Returns a new [StageExit] for that stage.
func handle_stage_exit(inventory: Inventory, quest: Quest = null, stage: Stage = null) -> StageExit:
	if not inventory:
		return null
	
	var stage_exit := StageExit.new()
	
	stage_exit.inventory = inventory.duplicate()
	
	if stage:
		stage.exit = stage_exit
	
	if quest:
		quest.in_stage = false
	
	return stage_exit


## Handles player death. Returns a new [StageExit] for the death. If [code]stage[/code]
## is not [code]null[/code], adds the death to that [Stage].
func handle_player_death(inventory: Inventory, stage: Stage = null, profile: Profile = null) -> StageExit:
	if not inventory:
		return null
	if profile and profile.in_arena:
		return null
	
	var stage_exit := StageExit.new()
	
	stage_exit.inventory = inventory.duplicate()
	
	if stage:
		stage.death = stage_exit
	if profile:
		profile.in_quest = false
		
		var quest := profile.quests[-1]
		quest.finished = true
		quest.victory = false
		quest.in_stage = false
	
	return stage_exit


## Moves the cursor to the specified line index.
func seek(to_position: int) -> void:
	position = to_position
	if position < _lines.size():
		_last_line = _lines[position]
	else:
		_last_line = ""


## Advances to the next line. Consider using [method get_line] instead if you need the line.
func next_line() -> void:
	position += 1
	if position < _lines.size():
		_last_line = _lines[position]
	else:
		_last_line = ""


## Advances to the next line of the log file and returns it, excluding the date and time.
## If you do not need the line, consider using [method next_line] instead.
## [br][br]If [code]line_index[/code] is specified, advances to the specified line instead.
func get_line(line_index: int = position + 1) -> String:
	position = line_index
	if position < _lines.size():
		_last_line = _lines[position]
	else:
		_last_line = ""
	
	return get_current_line()


## Returns all lines with a timestamp that matches the current one. Does not move
## the file cursor. Only looks ahead of the current line.
func get_current_timestamp_lines() -> PackedStringArray:
	var start_timestamp := get_timestamp()
	var start_position := position
	
	var lines := PackedStringArray()
	
	while get_timestamp() == start_timestamp:
		lines.append(get_current_line())
		next_line()
	
	seek(start_position)
	
	return lines


## Returns the current line of the log file, excluding date and time.
func get_current_line() -> String:
	if _last_line.is_empty():
		return ""
	
	return _last_line.get_slice("]", 1).strip_edges()


## Returns the timestamp of the line returned by [method get_line].
func get_timestamp() -> String:
	return _last_line.get_slice("]", 0).trim_prefix("[")


## Returns the last timestamp of the file.
func get_last_timestamp() -> String:
	if _lines.is_empty(): # if a file does not contain any useful lines, _lines will be empty
		return ""
	
	return _lines[-1].get_slice("]", 0).trim_prefix("[")


## Returns the date of the line returned by [method get_line].
func get_date() -> String:
	return get_timestamp().get_slice(" ", 0).trim_prefix("[")


## Returns the time of the line returned by [method get_line].
func get_time() -> String:
	return get_timestamp().split(" ")[-1].trim_suffix("]")


## Closes the log file.
func close() -> void:
	file.close()
