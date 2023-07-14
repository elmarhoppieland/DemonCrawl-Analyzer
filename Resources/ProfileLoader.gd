extends Node

# ==============================================================================
enum ExitCode {
	OK,
	READ_ERROR
}
# ==============================================================================
var profiles := {}

var quests: Array[Quest] = []

var _current_profile: Profile
# ==============================================================================
signal profiles_updated(new_profiles: Array[Profile])
# ==============================================================================

## Forces an update of the data, essentially reparsing all the data. Any data
## that is from log files that no longer exist will not be reparsed.
## [br][br][b]Note:[/b] This method is intended to be called from a [Thread].
func update_profiles() -> void:
	if Analyzer.is_first_launch():
		LoadingScreen.start(DemonCrawl.get_logs_count(), "Initializing...")
		initiate_first_launch()
		LoadingScreen.progress_increment()
		
		LoadingScreen.set_message("Saving data...")
		save_data_to_disk()
		LoadingScreen.progress_increment()
		return
	
	if FileAccess.file_exists(Analyzer.get_quests_file_path()):
		LoadingScreen.start(DemonCrawl.get_logs_count() + 1, "Loading saved data...")
	else:
		LoadingScreen.start(DemonCrawl.get_logs_count() + 2, "Updating saved data...")
		_update_from_savedata()
		LoadingScreen.progress_increment()
	
	LoadingScreen.set_message("Loading saved data...")
	
	var log_file := DemonCrawl.open_log_file(0)
	var start_timestamp := log_file.get_line().get_slice("]", 0).trim_prefix("[")
	
	read_quests(func(quest: Quest): return quest.creation_timestamp > start_timestamp)
	
	read_profiles()
	
	Analyzer.save_setting("-Data", "version", Analyzer.get_version())
	
	LoadingScreen.progress_increment()
	
	read_logs_dir(1)
	
	profiles_updated.emit(get_used_profiles())


## Loads the profiles stored in the user's data directory, and parses new data
## if able.
## [br][br]To retrieve the profiles, use [method get_profiles] or [method get_used_profiles].
## [br][br][b]Note:[/b] This method is intended to be called from a [Thread].
func load_profiles(freeze_data: bool = false) -> void:
	if Analyzer.is_first_launch():
		LoadingScreen.start(DemonCrawl.get_logs_count(), "Initializing...")
		initiate_first_launch()
		return
	
	LoadingScreen.start(DemonCrawl.get_logs_count() + 1, "Loading saved data...")
	
	var read_index := 0
	if not FileAccess.file_exists(Analyzer.get_quests_file_path()):
		# it's not a first launch, but the quests file does not exist
		# that means the previous launched version must have used savedata files formatting
		# (i.e. it was 1.2.x or lower)
		# we should load the savedata files, and then save the data in quests formatting
		read_index = 1
		_update_from_savedata()
	else:
		read_index = read_saved_data()
		LoadingScreen.progress_increment()
	
	if read_index < 0:
		printerr("An error occurred while attempting to read the saved data. Aborting...")
		get_tree().quit(ExitCode.READ_ERROR)
		return
	
	if read_index == 0:
		LoadingScreen.progress_finish()
		return
	
	if read_index > DemonCrawl.get_logs_count():
		print_rich("[color=aqua]Save data is up to date.[/color]")
		LoadingScreen.progress_finish()
		return
	
	if freeze_data:
		LoadingScreen.progress_finish()
		return
	
	LoadingScreen.set_step_count(DemonCrawl.get_logs_count() - read_index + 2)
	
	print_rich("[color=aqua]Save data is outdated.[/color]\n[color=aqua]Reading log files at index %s and beyond...[/color]" % read_index)
	read_logs_dir(read_index)
	
	quests.clear()
	for profile in get_used_profiles():
		quests.append_array(profile.quests)
	
	save_data_to_disk()
	
	profiles_updated.emit(get_used_profiles())
	
	# LoadingScreen should be finished automatically


## Renames the profile that is currently known as [code]old_name[/code] to [code]new_name[/code].
## [br][br][b]Note:[/b] This method is intended to be called from a [Thread].
func rename_profile(old_name: String, new_name: String) -> void:
	if not old_name in profiles:
		LoadingScreen.start(1, "Renaming save file...")
		var old_path := DemonCrawl.get_save_file_path(old_name)
		DirAccess.copy_absolute(old_path, Analyzer.SAVE_FILE_BACKUP_PATH)
		var new_path := old_path.get_base_dir().path_join(new_name + ".ini")
		DirAccess.rename_absolute(old_path, new_path)
		LoadingScreen.progress_increment()
		return
	
	LoadingScreen.start(5, "Duplicating profile...")
	profiles[new_name] = profiles[old_name]
	LoadingScreen.progress_increment()
	
	LoadingScreen.set_message("Renaming profile...")
	get_profile(new_name).name = new_name
	LoadingScreen.progress_increment()
	
	LoadingScreen.set_message("Erasing the old profile...")
	profiles.erase(old_name)
	LoadingScreen.progress_increment()
	
	LoadingScreen.set_message("Saving new data...")
	save_data_to_disk()
	LoadingScreen.progress_increment()
	
	LoadingScreen.set_message("Renaming save file...")
	var old_path := DemonCrawl.get_save_file_path(old_name)
	DirAccess.copy_absolute(old_path, Analyzer.SAVE_FILE_BACKUP_PATH)
	var new_path := old_path.get_base_dir().path_join(new_name + ".ini")
	DirAccess.rename_absolute(old_path, new_path)
	LoadingScreen.progress_increment()
	
	profiles_updated.emit(get_used_profiles())


## Initializes the Analyzer, for the first launch (when the data files do not yet exist).
## Parses data from the log files and stores it into the user's data directory.
func initiate_first_launch() -> void:
	print_rich("[color=green]First launch detected. Initializing...[/color]")
	
	var log_file := DemonCrawl.open_log_file(1)
	var start_unix := TimeHelper.get_unix_time_from_timestamp(log_file.get_line().get_slice("]", 0).trim_prefix("["))
	SettingsFile.set_setting_static("-Data", "start_unix", start_unix)
	
	print_rich("[color=green]Finished initializing. Reading log files...[/color]")
	
	read_logs_dir(1)


## Reads the saved data and sets the singleton's properties to the stored values.
## [br][br]Returns the index of the log file that should be read. Returns [code]-1[/code]
## if an error occurred. Returns [code]0[/code] if no log files should be read.
## [br][br][b]Note:[/b] The returned index is 1-indexed, so that the index matches
## with how DemonCrawl indexes its log files.
func read_saved_data() -> int:
	create_backups()
	
	match Analyzer.get_data_status():
		Analyzer.DataStatus.UP_TO_DATE:
			read_quests()
			read_profiles()
			return 0
		Analyzer.DataStatus.NEW_DATA_FOUND:
			read_quests()
			
			if quests.is_empty():
				return 1
			
			read_profiles()
			
			var final_timestamp := quests[-1].creation_timestamp
			for log_index in range(DemonCrawl.get_logs_count(), 0, -1):
				var log_file := DemonCrawl.open_log_file(log_index)
				var start_timestamp := log_file.get_line().get_slice("]", 0).trim_prefix("[")
				if TimeHelper.timestamp_is_before_timestamp(start_timestamp, final_timestamp):
					# the next log file will contain new data
					return log_index + 1
			
			return -1
		Analyzer.DataStatus.OUTDATED_VERSION:
			var log_file := DemonCrawl.open_log_file(0)
			var start_timestamp := log_file.get_line().get_slice("]", 0).trim_prefix("[")
			
			read_quests(func(quest: Quest): return quest.creation_timestamp > start_timestamp)
			
			read_profiles()
			
			Analyzer.save_setting("-Data", "version", Analyzer.get_version())
			
			return 1
	
	return -1


## Reads the quests saved in [code]user://quests.dca[/code] (or
## [code]user://quests-debug.dca[/code] if in debug mode).
## [br][br]If a [code]condition[/code] is specified and returns [code]false[/code],
## stops reading. The specified [Callable] should take in 1 argument for the
## [Quest] that is being read.
func read_quests(condition: Callable = Callable()) -> void:
	var file := Analyzer.open_quests_file()
	while true:
		var json_string := file.get_line()
		if json_string.is_empty():
			return
		
		var json = JSON.parse_string(json_string)
		var quest := HistoryData.from_json(json, Quest) as Quest
		if not condition.is_null() and not condition.call(quest):
			return
		
		quests.append(quest)


## Reads the profiles file and adds keys into the [member profiles] [Dictionary]
## for each [Profile], and adds each [Quest] into the corresponding profile.
func read_profiles() -> void:
	var file := Analyzer.open_profiles_file()
	var json_string := file.get_line()
	if json_string.is_empty():
		return
	
	var json = JSON.parse_string(json_string)
	if not json is Dictionary:
		return
	
	for profile_name in json:
		var profile := Profile.new()
		for quest_index in json[profile_name]:
			if quests.size() > quest_index:
				profile.quests.append(quests[quest_index])
		
		profile.name = profile_name
		if not profile.quests.is_empty():
			profile.in_quest = not profile.quests[-1].finished
		profiles[profile_name] = profile


## Reads the data stored in savedata files. This is used to update from savedata
## formatting.
func read_savedata_files(before_timestamp: String) -> void:
	var index := get_savedata_index_before_unix(TimeHelper.get_unix_time_from_timestamp(before_timestamp))
	load_from_savedata(Analyzer.get_savedata(index))


## Creates backups of the quests and profiles files.
func create_backups() -> void:
	DirAccess.copy_absolute(Analyzer.get_quests_file_path(), Analyzer.get_quests_backup_file_path())
	DirAccess.copy_absolute(Analyzer.get_profiles_file_path(), Analyzer.get_profiles_backup_file_path())


## Returns the index of the last savedata file that started before [code]unix[/code]
## (i.e. [code]start_unix < unix[/code]). Prints an error and returns [code]-1[/code]
## if no such file exists.
func get_savedata_index_before_unix(unix: int) -> int:
	# iterates in reverse order and returns the index of the first one before 'unix' it finds
	for index in range(DirAccess.get_files_at(Analyzer.get_savedata_directory()).size() - 1, -1, -1):
		var file := Analyzer.open_savedata_file(index)
		
		var text := file.get_as_text()
		var parse = JSON.parse_string(text)
		if parse is Dictionary and "start_unix" in parse:
			if parse.start_unix < unix:
				return index
	
	push_error("Could not find a savedata file before unix %s." % unix)
	return -1


func load_from_json(json: Dictionary) -> void:
	for property in json:
		match property:
			"profiles":
				for profile in json.profiles:
					profiles[profile] = HistoryData.from_json(json.profiles[profile], Profile)


func load_from_savedata(json: Dictionary) -> void:
	load_from_json(json)
	
	for profile in get_used_profiles():
		quests.append_array(profile.quests)
	sort_quests()


func read_logs_dir(starting_index: int) -> void:
	for index in range(starting_index, DemonCrawl.get_logs_count() + 1):
		LoadingScreen.set_message("Parsing %s..." % (DemonCrawl.LOG_FILE_NAME % index))
		read_log(index)
		LoadingScreen.progress_increment()


func save_data_to_disk() -> void:
	sort_quests()
	
	var file := Analyzer.open_quests_file(FileAccess.WRITE)
	for quest in quests:
		file.store_line(JSON.stringify(quest.to_json()))
	file = Analyzer.open_profiles_file(FileAccess.WRITE)
	file.store_line(JSON.stringify(get_profile_indexes()))


func read_log(index: int) -> void:
	var log_reader := LogFileReader.read(DemonCrawl.get_log_path(index))
	if not log_reader:
		push_error("Error occurred when attempting to read log file at index %s: %s" % [index, error_string(FileAccess.get_open_error())])
#		DirAccess.copy_absolute(Analyzer.get_savedata_path(index - 1), Analyzer.get_savedata_path(index))
		return
	
	log_reader.next_line()
	
	var start_timestamp := log_reader.get_timestamp()
#	var start_unix := TimeHelper.get_unix_time_from_timestamp(start_timestamp)
	
	var end_timestamp := log_reader.get_last_timestamp()
#	var end_unix := TimeHelper.get_unix_time_from_timestamp(end_timestamp)
	
	if end_timestamp.is_empty():
		# the log file does not contain readable lines
#		save_data_to_disk(index, start_unix, end_unix)
		return
	
	while not log_reader.get_current_line().is_empty():
		parse_line(log_reader)
		
		log_reader.next_line()
	
	if index == DemonCrawl.get_logs_count():
		Analyzer.save_setting("-Data", "end_timestamp", start_timestamp)
	
#	save_data_to_disk(index, start_unix, end_unix)


func parse_line(log_reader: LogFileReader) -> void:
	var data := log_reader.handle_current_line(LogFileReader.Line.ALL, _current_profile)
	if data is Profile:
		if data.name in profiles:
			_current_profile = profiles[data.name]
		else:
			profiles[data.name] = data
			_current_profile = data


func sort_quests() -> void:
	quests.sort_custom(func(a: Quest, b: Quest): return TimeHelper.timestamp_is_before_timestamp(a.creation_timestamp, b.creation_timestamp))


func get_profile(profile_name: String, allow_unused: bool = true) -> Profile:
	var profile = profiles[profile_name]
	if profile is Profile and (allow_unused or not profile.quests.is_empty()):
		return profile
	
	return null


func get_used_profiles() -> Array[Profile]:
	var used_profiles: Array[Profile] = []
	
	for profile in profiles.values():
		if profile is Profile and not profile.quests.is_empty():
			used_profiles.append(profile)
	
	return used_profiles


func get_profiles() -> Array[Profile]:
	var profile_array: Array[Profile] = []
	
	for profile in profiles.values():
		if profile is Profile:
			profile_array.append(profile)
	
	return profile_array


## Returns a [Dictionary] that points each (used) profile to quest indexes.
func get_profile_indexes() -> Dictionary:
	var profile_indexes := {}
	
	for profile in get_used_profiles():
		profile_indexes[profile.name] = PackedInt32Array()
		for quest in profile.quests:
			profile_indexes[profile.name].append(quests.find(quest))
	
	return profile_indexes


func find_quests() -> Array[Quest]:
	quests.clear()
	for profile in get_used_profiles():
		quests.append_array(profile.quests)
	return quests


func get_profile_names() -> PackedStringArray:
	return profiles.keys()


# ------------------------------------------------------------------------------
# _update() functions below

func _update_from_savedata() -> void:
	LoadingScreen.set_message("Updating saved data...")
	
	var first_log_file := DemonCrawl.open_log_file(1)
	var first_timestamp := first_log_file.get_line().get_slice("]", 0).trim_prefix("[")
	read_savedata_files(first_timestamp)
	save_data_to_disk()
	
	var log_file := DemonCrawl.open_log_file(DemonCrawl.get_logs_count())
	var timestamp := log_file.get_line().get_slice("]", 0).trim_prefix("[")
	Analyzer.save_setting("-Data", "end_timestamp", timestamp)
	Analyzer.save_setting("-Data", "version", Analyzer.get_version())
	
	LoadingScreen.progress_increment()
	LoadingScreen.set_message("Loading saved data...")
