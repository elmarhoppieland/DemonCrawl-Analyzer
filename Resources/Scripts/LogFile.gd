extends RefCounted
class_name LogFile

# ==============================================================================
enum Line {
	UNKNOWN = -1,
	NONE,
	EOF,
	DEMONCRAWL_STARTED,
	DEMONCRAWL_CLOSED,
	DEMONCRAWL_CLOSED_MISSING,
	CLOUD_PROGRESS_CHECK,
	CLOUD_PROGRESS_RESULT_LOCAL,
	CLOUD_PROGRESS_RESULT_CLOUD,
	VERIFACTION_MY_STEAM_ID,
	VERIFACTION_SAVED_STEAM_ID,
	VERIFACTION_DEVICE_ID_VALID,
	SETTINGS_SOUND_DISABLED,
	DAILY_MISSION_NEW,
	DAILY_MISSION_COMPLETE,
	PROFILE_LOADED,
	QUEST_START,
	QUEST_ABORT,
	QUEST_STAGE_BEGIN,
	QUEST_STAGE_COMPLETE,
	QUEST_STAGE_LEAVE,
	QUEST_PLAYER_STATS,
	QUEST_GAIN_POINTS,
	QUEST_ALERT_PROFILE_LEVEL_UP,
	QUEST_ALERT_STAGE_TOKEN_SPAWNED,
	QUEST_ALERT_STAGE_NOMAD_SPAWN_ITEMS_FOR_SALE,
	QUEST_ALERT_STAGE_HUNGRY_PLANT_SPAWN_GOT_SOME_FOOD_BUDDY,
	QUEST_ALERT_STAGE_PRIEST_SPAWN_GOD_NEEDS_YOUR_MONEY,
	QUEST_ALERT_STAGE_PYRO_SPAWN_EVERYTHING_IS_FIRE,
	QUEST_ALERT_STAGE_MERCENARY_SPAWN_NEED_SOME_HELP_THERE_CHIEF,
	QUEST_ALERT_STAGE_WISHPOOL_SHIMMERS,
	HOLIDAY_HALLOWEEN_ALERT_STARTUP_SPOOKERS,
	UI_GROUP_ADD_FAILED,
	ERROR_MESSAGE_SHORT,
	ERROR_MESSAGE_LONG_FIRST_LINE,
	ERROR_MESSAGE_LONG,
}
const LINE_FILTERS := {
	Line.DEMONCRAWL_STARTED: "DemonCrawl started",
	Line.DEMONCRAWL_CLOSED: "DemonCrawl closed",
	Line.CLOUD_PROGRESS_CHECK: "Local save prestige *, local save xp *, cloud prestige *, cloud xp *",
	Line.CLOUD_PROGRESS_RESULT_LOCAL: "Local save has equal or more progress than the Steam Cloud save.",
	Line.CLOUD_PROGRESS_RESULT_CLOUD: "", # not yet implemented
	Line.VERIFACTION_MY_STEAM_ID: "My Steam ID... *",
	Line.VERIFACTION_SAVED_STEAM_ID: "Saved Steam ID... *",
	Line.VERIFACTION_DEVICE_ID_VALID: "Device ID is valid - we can proceed.",
	Line.SETTINGS_SOUND_DISABLED: "Sound disabled.",
	Line.DAILY_MISSION_NEW: "New Daily Mission!",
	Line.DAILY_MISSION_COMPLETE: "Daily Mission complete! +* Tokens",
	Line.PROFILE_LOADED: "Profile loaded: *",
	Line.QUEST_START: "Quest started: * on difficulty *",
	Line.QUEST_ABORT: "Quest aborted",
	Line.QUEST_STAGE_BEGIN: "Begin stage *",
	Line.QUEST_STAGE_COMPLETE: "Completed stage * in * seconds",
	Line.QUEST_STAGE_LEAVE: "Leaving stage *",
	Line.QUEST_PLAYER_STATS: "Player stats: */* lives, * defense, * coins",
	Line.QUEST_GAIN_POINTS: "Gained * points, total score: *",
	Line.QUEST_ALERT_PROFILE_LEVEL_UP: "You leveled up!",
	Line.QUEST_ALERT_STAGE_TOKEN_SPAWNED: "A token spawned!",
	Line.QUEST_ALERT_STAGE_NOMAD_SPAWN_ITEMS_FOR_SALE: "\"Items for sale!\"",
	Line.QUEST_ALERT_STAGE_HUNGRY_PLANT_SPAWN_GOT_SOME_FOOD_BUDDY: "\"Got some food buddy?\"",
	Line.QUEST_ALERT_STAGE_PRIEST_SPAWN_GOD_NEEDS_YOUR_MONEY: "\"God needs your money!\"",
	Line.QUEST_ALERT_STAGE_PYRO_SPAWN_EVERYTHING_IS_FIRE: "\"EVERYTHING IS FIRE\"",
	Line.QUEST_ALERT_STAGE_MERCENARY_SPAWN_NEED_SOME_HELP_THERE_CHIEF: "\"Need some help there chief?\"",
	Line.QUEST_ALERT_STAGE_WISHPOOL_SHIMMERS: "The wishpool shimmers with light...",
	Line.HOLIDAY_HALLOWEEN_ALERT_STARTUP_SPOOKERS: "\"Spookers?!\"",
	Line.UI_GROUP_ADD_FAILED: "ui_group_add failed!",
	Line.ERROR_MESSAGE_SHORT: "ERROR * message: *",
	Line.ERROR_MESSAGE_LONG_FIRST_LINE: "ERROR * longMessage: ERROR in",
	Line.ERROR_MESSAGE_LONG: "ERROR * longMessage: ERROR in
action number *
of *
for object *:


*",
	Line.NONE: "*",
}
const LINE_PARAM_TYPES := {
	Line.CLOUD_PROGRESS_CHECK: [TYPE_INT, TYPE_INT, TYPE_INT, TYPE_INT],
	Line.VERIFACTION_MY_STEAM_ID: [TYPE_INT],
	Line.VERIFACTION_SAVED_STEAM_ID: [TYPE_INT],
	Line.DAILY_MISSION_COMPLETE: [TYPE_INT],
	Line.PROFILE_LOADED: [TYPE_STRING],
	Line.QUEST_START: [TYPE_STRING, TYPE_INT],
	Line.QUEST_STAGE_BEGIN: [TYPE_STRING],
	Line.QUEST_STAGE_COMPLETE: [TYPE_STRING, TYPE_INT],
	Line.QUEST_STAGE_LEAVE: [TYPE_STRING],
	Line.QUEST_PLAYER_STATS: [TYPE_INT, TYPE_INT, TYPE_INT, TYPE_INT],
	Line.QUEST_GAIN_POINTS: [TYPE_INT, TYPE_INT],
	Line.ERROR_MESSAGE_SHORT: [TYPE_STRING, TYPE_STRING],
	Line.ERROR_MESSAGE_LONG_FIRST_LINE: [TYPE_STRING],
	Line.ERROR_MESSAGE_LONG: [TYPE_STRING, TYPE_INT, TYPE_STRING, TYPE_STRING, TYPE_STRING],
	Line.NONE: [TYPE_STRING],
}
# ==============================================================================
var file: FileAccess
# ==============================================================================

static func open(path: String, flags: FileAccess.ModeFlags = FileAccess.READ) -> LogFile:
	var log_file := LogFile.new()
	log_file.file = FileAccess.open(path, flags)
	return log_file


func next_batch() -> Array[LineData]:
	var batch_data: Array[LineData] = []
	
	var timestamp := ""
	
	while true:
		var old_position := file.get_position()
		
		var line := file.get_line()
		var type := LogFile.get_line_type(line)
		if type == Line.ERROR_MESSAGE_LONG_FIRST_LINE:
			while true:
				var pos := file.get_position()
				var next_line := file.get_line()
				if next_line.begins_with("["):
					file.seek(pos)
					type = Line.ERROR_MESSAGE_LONG
					break
				line += "\n" + next_line
		
		if line.is_empty():
			break
		if not timestamp.is_empty() and LogFile.get_timestamp(line) != timestamp:
			file.seek(old_position)
			break
		
		if not line.begins_with("["):
			breakpoint
		
		timestamp = LogFile.get_timestamp(line)
		
		var data := LineData.new()
		
		data.line = line
		data.type = type
		data.params = LogFile.get_line_params(line)
		data.unix_time = Time.get_unix_time_from_datetime_string(timestamp.replace(" @ ", "T"))
		
		batch_data.append(data)
	
	# changing the order of lines will go here
	
	return batch_data


func get_lines_data() -> Array[LineData]:
	file.seek(0)
	
	var lines_data: Array[LineData] = []
	
	while true:
		var batch := next_batch()
		if batch.is_empty():
			break
		
		lines_data.append_array(batch)
	
	return lines_data


func save_compiled(to_path: String, override: bool = true) -> void:
	var lines_data := get_lines_data()
	
	var save_file: FileAccess
	if override:
		save_file = FileAccess.open(to_path, FileAccess.WRITE)
		if not save_file:
			push_error("Could not save to path '%s': %s" % [to_path, error_string(FileAccess.get_open_error())])
	else:
		save_file = FileAccess.open(to_path, FileAccess.READ_WRITE)
		if not save_file:
			push_error("Could not save to path '%s': %s" % [to_path, error_string(FileAccess.get_open_error())])
			return
		save_file.seek_end()
	
	for line_data in lines_data:
		save_file.store_16(line_data.type)
		
		var unix_time := line_data.unix_time
		
		save_file.store_32(unix_time)
		
		for param in line_data.params:
			match typeof(param):
				TYPE_STRING:
					save_file.store_16(param.length())
					save_file.store_string(param)
				TYPE_INT:
					if param < 0 or param > 0xffffffff:
						save_file.store_8(0xff)
						save_file.store_64(param)
					else:
						save_file.store_8(0x00)
						save_file.store_32(param)
	
	save_file.store_16(Line.EOF)


static func get_line_type(line: String) -> Line:
	line = trim_line(line)
	
	for line_type in LINE_FILTERS:
		if line.match(LINE_FILTERS[line_type]):
			return line_type
	
	return Line.NONE


static func get_line_params(line: String, line_type: Line = Line.UNKNOWN) -> Array:
	if line_type == Line.UNKNOWN:
		line_type = get_line_type(line)
	
	if not line_type in LINE_FILTERS or not line_type in LINE_PARAM_TYPES:
		return []
	
	line = trim_line(line)
	
	var params := []
	
	var filter_string: String = LINE_FILTERS[line_type]
	
	while "*" in filter_string:
		var prefix := filter_string.get_slice("*", 0)
		line = line.trim_prefix(prefix)
		filter_string = filter_string.trim_prefix(prefix)
		
		filter_string = filter_string.trim_prefix("*")
		
		var matched_string_length := 0
		while not line.substr(matched_string_length).match(filter_string):
			if line.substr(matched_string_length).is_empty():
				break
			matched_string_length += 1
		
		var param_str := line.substr(0, matched_string_length)
		var param_type: Variant.Type = LINE_PARAM_TYPES[line_type][params.size()]
		
		match param_type:
			TYPE_NIL:
				params.append(null)
			TYPE_INT:
				params.append(param_str.to_int())
			TYPE_STRING:
				params.append(param_str)
		
		line = line.substr(matched_string_length)
	
	return params


static func trim_line(line: String) -> String:
	if "Alert: " in line:
		return line.get_slice("Alert: ", 1)
	elif line.match("[*] *"):
		return line.get_slice("] ", 1)
	
	return line


static func get_timestamp(line: String) -> String:
	return line.trim_prefix("[").get_slice("]", 0)


class LineData extends RefCounted:
	var line := ""
	var type := Line.UNKNOWN
	var params := []
	var unix_time := -1


class Batch extends RefCounted:
	var lines: Array[LineData] = []
