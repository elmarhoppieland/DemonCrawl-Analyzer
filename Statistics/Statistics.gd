extends TabContainer

# ==============================================================================
enum LogError {
	UNKNOWN = -1, ## Unknown error.
	OK, ## No error.
	EOF_REACHED, ## End of file reached.
	PLAYER_DIED, ## Player died.
	QUEST_COMPLETE, ## Quest complete.
	INVALID_TIMESTAMP ## Does not contain logs after the specified timestamp.
}
# ==============================================================================
const SAVE_DATA_PATH := "user://profiles.dcstat"
const SAVE_DATA_PATH_DEBUG := "user://profiles_debug.dcstat"

## The current version. Formatted as [code]MAJOR.minor.bugfix.debug[/code].
const CURRENT_VERSION := "1.1.0.5"
# ==============================================================================
var default_log_dir := OS.get_data_dir().get_base_dir().path_join("Local/demoncrawl/logs")
# ------------------------------------------------------------------------------
var profiles := {}
var latest_recorded_time := 0.0
var latest_recorded_version := "0.0.0"

var disk_data: Array[Dictionary] = []
# ------------------------------------------------------------------------------
var previous_read_quest: Quest = null

var current_profile: Profile
# ==============================================================================

func _enter_tree() -> void:
	current_tab = 0
	
	read_saved_data()
	
	read_logs_dir()
	
#	save_data_to_disk()


func read_saved_data() -> void:
	if not FileAccess.file_exists(get_savedata_path()):
		FileAccess.open(get_savedata_path(), FileAccess.WRITE)
	
	var file := FileAccess.open(get_savedata_path(), FileAccess.READ)
	if not file:
		push_error("Error occurred during read operation: %s. Aborting process..." % error_string(FileAccess.get_open_error()))
		return
	
	while true:
		var text := file.get_line()
		if text.is_empty():
			break
		
		var parse = JSON.parse_string(text)
		if parse is Dictionary:
			disk_data.append(parse)
	
	file.close()
	
	var log_file := LogFileReader.read(default_log_dir.path_join("log1.txt"))
	log_file.next_line()
	var log_timestamp := log_file.get_timestamp()
	log_file.close()
	
	var old_data := {} # the data before the first log file. If an update occurs, this data will be kept.
	var new_data: Array[Dictionary] = [] # the data stored in log files. If an update occurs, this data will be deleted.
	for data in disk_data:
		if not "start_timestamp" in data or not data.start_timestamp is String:
			continue
		
		var timestamp: String = data.start_timestamp
		if log_timestamp == timestamp:
			old_data = data
		elif not old_data.is_empty() and old_data.version == CURRENT_VERSION:
			# if old_data is not empty then we must have reached a log file
			# if old_data.version != CURRENT_VERSION then it must be outdated
			new_data.append(data)
	
	if old_data.is_empty():
		# data is not yet set up correctly; this usually only happens on first launch
		# file should be empty but we truncate the file just in case
		FileAccess.open(get_savedata_path(), FileAccess.WRITE)
		return
	
	save_json(old_data, true)
	
	if new_data.is_empty(): # there was an update
		print_rich("[color=green]Updating...[/color]")
		load_from_json(old_data)
		return
	
	for data in new_data:
		save_json(data, false)
	
	load_from_json(new_data[-1])


func load_from_json(json: Dictionary) -> void:
	for property in json:
		match property:
			"profiles":
				for profile in json.profiles:
					profiles[profile] = Profile._from_dict(json.profiles[profile])
			"time":
				latest_recorded_time = json.time
			"version":
				latest_recorded_version = json.version


func read_logs_dir() -> void:
	for index in range(1, 101):
		var error := read_log("log%s.txt" % index, int(latest_recorded_time))
		if not error in [LogError.EOF_REACHED, LogError.INVALID_TIMESTAMP]:
			return


func save_data_to_disk(truncate: bool = true, start_timestamp: String = "", end_timestamp: String = "") -> void:
	var dict := {
		"profiles": {},
		"time": latest_recorded_time,
		"version": CURRENT_VERSION,
		"start_timestamp": start_timestamp,
		"end_timestamp": end_timestamp
	}
	for profile in get_profiles():
		dict.profiles[profile.name] = profile._to_dict()
	
	save_json(dict, truncate)


func save_json(json: Dictionary, truncate: bool = true) -> void:
	var file := FileAccess.open(get_savedata_path(), FileAccess.WRITE if truncate else FileAccess.READ_WRITE)
	if not file:
		push_error("Error occurred during write operation: %s. Aborting process..." % error_string(FileAccess.get_open_error()))
		return
	
	file.seek_end()
	
	file.store_line(JSON.stringify(json))


func read_log(log_name: String, after_unix: int) -> LogError:
	var log_reader := LogFileReader.read(default_log_dir.path_join(log_name), -1 if savedata_is_outdated() else after_unix)
	if not log_reader:
		return LogError.INVALID_TIMESTAMP
	
	log_reader.next_line()
	
	var timestamp := log_reader.get_timestamp()
	
	while not log_reader.get_current_line().is_empty():
		if Time.get_unix_time_from_datetime_string(log_reader.get_date() + "T" + log_reader.get_time()) > after_unix:
			parse_line(log_reader)
			latest_recorded_time = Time.get_unix_time_from_datetime_string(log_reader.get_date() + "T" + log_reader.get_time())
		
		log_reader.next_line()
	
	var end_timestamp := log_reader.get_last_timestamp()
	
	save_data_to_disk(false, timestamp, end_timestamp)
	
	return LogError.EOF_REACHED


func parse_line(log_reader: LogFileReader) -> void:
	var data := log_reader.handle_current_line(LogFileReader.Line.ALL, current_profile)
	if data is Profile:
		if data.name in profiles:
			current_profile = profiles[data.name]
		else:
			profiles[data.name] = data
			current_profile = data


func get_profile(profile_name: String) -> Profile:
	var profile = profiles[profile_name]
	if profile is Profile:
		return profile
	
	return null


func get_used_profiles() -> Array[Profile]:
	var profile_array: Array[Profile] = []
	
	for profile in profiles.values():
		if profile is Profile and not profile.quests.is_empty():
			profile_array.append(profile)
	
	return profile_array


func get_profiles() -> Array[Profile]:
	var profile_array: Array[Profile] = []
	
	for profile in profiles.values():
		if profile is Profile:
			profile_array.append(profile)
	
	return profile_array


func get_error(line: String) -> LogError:
	if line.is_empty():
		return LogError.EOF_REACHED
	if line.match("* was killed!"):
		return LogError.PLAYER_DIED
	if line == "Alert: Submitting score to Leaderboard...":
		return LogError.QUEST_COMPLETE
	
	return LogError.OK


func get_savedata_path() -> String:
	if OS.is_debug_build():
		return SAVE_DATA_PATH_DEBUG
	
	return SAVE_DATA_PATH


func savedata_is_outdated() -> bool:
	var savedata_split := latest_recorded_version.split(".")
	var current_split := CURRENT_VERSION.split(".")
	
	for i in 3:
		if savedata_split[i].to_int() < current_split[i].to_int():
			return true
		elif savedata_split[i].to_int() > current_split[i].to_int():
			break
	
	return false
