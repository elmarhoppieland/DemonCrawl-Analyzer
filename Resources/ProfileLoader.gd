extends Node

# ==============================================================================
enum ExitCode {
	OK,
	READ_ERROR
}
# ==============================================================================
var profiles := {}

var _current_profile: Profile

var errors := []
# ==============================================================================
signal profiles_loaded(used_profiles: Array[Profile])
# ==============================================================================

func update_profiles() -> void:
	if Analyzer.is_first_launch():
		LoadingScreen.start(DemonCrawl.get_logs_count(), "Initializing...")
		initiate_first_launch()
		return
	
	LoadingScreen.start(DemonCrawl.get_logs_count() + 1, "Loading saved data...")
	
	create_backups()
	
	update_savedata()
	
	LoadingScreen.progress_increment()
	
	read_logs_dir(1)
	
	profiles_loaded.emit(get_used_profiles())


func load_profiles() -> void:
	if Analyzer.is_first_launch():
		LoadingScreen.start(DemonCrawl.get_logs_count(), "Initializing...")
		initiate_first_launch()
		return
	
	LoadingScreen.start(DemonCrawl.get_logs_count() + 1, "Loading saved data...")
	
	var read_index := read_saved_data()
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
	
	LoadingScreen.set_step_count(DemonCrawl.get_logs_count() - read_index + 2)
	
	print_rich("[color=aqua]Save data is outdated.[/color]\n[color=aqua]Reading log files at index %s and beyond...[/color]" % read_index)
	read_logs_dir(read_index)
	
	profiles_loaded.emit(get_used_profiles())
	
	# LoadingScreen should be finished automatically


func initiate_first_launch() -> void:
	print_rich("[color=green]First launch detected. Initializing...[/color]")
	
	DirAccess.make_dir_absolute(Analyzer.get_savedata_directory())
	
	save_data_to_disk(0, -1, -1)
	
	var log_file := DemonCrawl.open_log_file(1)
	var start_unix := TimeHelper.get_unix_time_from_timestamp(log_file.get_line().get_slice("]", 0).trim_prefix("["))
	SettingsFile.set_setting_static("-Data", "start_unix", start_unix)
	
	print_rich("[color=green]Finished initializing. Reading log files...[/color]")
	
	read_logs_dir(1)
	
	profiles_loaded.emit(get_used_profiles())


## Reads the saved data and sets the properties to the stored values.
## [br][br]Returns the index of the log file that should be read. Returns [code]-1[/code]
## if an error occurred. Returns [code]0[/code] if no log files should be read.
## [br][br][b]Note:[/b] The returned index is 1-indexed, so that the index matches
## with how DemonCrawl indexes its log files.
func read_saved_data() -> int:
	match Analyzer.get_data_status():
		Analyzer.DataStatus.UP_TO_DATE:
			load_from_json(Analyzer.get_savedata(-1))
			return 0
	
	create_backups()
	
	var file := Analyzer.open_savedata_file(-1)
	if not file:
		push_error("Error occurred during read operation: %s. Aborting process..." % error_string(FileAccess.get_open_error()))
		return -1
	
	var text := file.get_as_text()
	var parse = JSON.parse_string(text)
	if parse is Dictionary:
		if "version" in parse and parse.version == Analyzer.get_version():
			# there is no update; we now want to load from this savedata file
			# and start reading from the log file after the one the
			# savedata file is associated with
			load_from_json(parse)
			
			var log_index := get_log_file_index(parse.start_unix) + 1
			
			move_savedata_files(DemonCrawl.get_logs_count() - log_index)
			
			return log_index
		
		# there is an update; we now want to load from the last file that
		# does not have a log file associated with it
		update_savedata()
		
		# we need to read from the first log file; the data that was saved
		# should be overwritten with the data in the log files
		return 1
	
	push_error("Invalid data in the last profiles.dcstat file. Aborting read operation...")
	file.close()
	return -1


## Copies the entire savedata directory into the backup directory.
func create_backups() -> void:
	if not DirAccess.dir_exists_absolute(Analyzer.get_backup_directory()):
		DirAccess.make_dir_absolute(Analyzer.get_backup_directory())
	for file in DirAccess.get_files_at(Analyzer.get_savedata_directory()):
		DirAccess.copy_absolute(Analyzer.get_savedata_directory().path_join(file), Analyzer.get_backup_directory().path_join(file))


## Returns the index of the log file that starts at unix [code]start_unix[/code],
## or [code]0[/code] if there is no such file.
## [br][br][b]Note:[/b] The log files's starting timestamp should match [b]exactly[/b]
## with [code]start_unix[/code]. Even if they differ by 1 second, this method
## will not find it.
func get_log_file_index(start_unix: int) -> int:
	for log_index in range(1, DemonCrawl.get_logs_count() + 1):
		var log_file := DemonCrawl.open_log_file(log_index)
		
		var line := log_file.get_line()
		var log_timestamp := line.get_slice("]", 0).trim_prefix("[")
		var log_unix := TimeHelper.get_unix_time_from_timestamp(log_timestamp)
		if start_unix == log_unix:
			return log_index
	
	return 0


## Reads from the first savedata file that no longer has a log file, and moves all
## savedata files so that all data after that will be overwritten. This is typically
## used when updating the Analyzer.
func update_savedata() -> void:
	print_rich("[color=green]Updating...[/color]")
	
	var first_log_file := DemonCrawl.open_log_file(1)
	var first_log_unix := TimeHelper.get_unix_time_from_timestamp(first_log_file.get_line().get_slice("]", 0).trim_prefix("["))
	
	first_log_file.close()
	
	var savedata_index := get_savedata_index_before_unix(first_log_unix)
	if savedata_index < 0:
		# this shouldn't every happen but if it does then there's no reason to continue
		return
	
	var savedata_file := Analyzer.open_savedata_file(savedata_index)
	
	var savedata_text := savedata_file.get_as_text()
	var savedata_parse = JSON.parse_string(savedata_text)
	if savedata_parse is Dictionary:
		load_from_json(savedata_parse)
	
	savedata_file.close()
	
	move_savedata_files(savedata_index)


## Returns the index of the last savedata file that started before [code]unix[/code]
## (i.e. [code]start_unix < unix[/code]). Prints an error message if no such file exists.
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
			"errors":
				errors = json[property]


## Moves all savedata files so that the file at index [code]new_zero_index[/code]
## is now at index [code]0[/code], and all files after that are moved accordingly.
func move_savedata_files(new_zero_index: int) -> void:
	if new_zero_index < 1:
		# we don't need to move any files
		return
	
	for index in DemonCrawl.get_logs_count() - new_zero_index:
		var current_path := Analyzer.get_savedata_path(new_zero_index + index)
		var new_path := Analyzer.get_savedata_path(index)
		var error := DirAccess.rename_absolute(current_path, new_path)
		if error:
			push_error("Error occurred during move operation: %s. Can't rename file '%s' to '%s'" % [error_string(error), Analyzer.get_savedata_path(new_zero_index + index), Analyzer.get_savedata_path(index)])
			breakpoint


func read_logs_dir(starting_index: int) -> void:
	for index in range(starting_index, DemonCrawl.get_logs_count() + 1):
		LoadingScreen.set_message("Parsing %s..." % (DemonCrawl.LOG_FILE_NAME % index))
		read_log(index)
		LoadingScreen.progress_increment()



func save_data_to_disk(index: int, start_unix: int, end_unix: int) -> void:
	var dict := {
		"profiles": {},
		"version": Analyzer.get_version(),
		"start_unix": start_unix,
		"end_unix": end_unix,
		"errors": errors
	}
	for profile in get_used_profiles():
		dict.profiles[profile.name] = profile.to_json()
	
	save_json(dict, index)


func save_json(json: Dictionary, index: int) -> void:
	var file := FileAccess.open(Analyzer.get_savedata_path(index), FileAccess.WRITE)
	if not file:
		push_error("Error occurred during write operation: %s. Aborting process..." % error_string(FileAccess.get_open_error()))
		return
	
	file.store_line(JSON.stringify(json))


func read_log(index: int) -> void:
	var log_reader := LogFileReader.read(DemonCrawl.get_log_path(index))
	if not log_reader:
		push_error("Error occurred when attempting to read log file at index %s: %s" % [index, error_string(FileAccess.get_open_error())])
		DirAccess.copy_absolute(Analyzer.get_savedata_path(index - 1), Analyzer.get_savedata_path(index))
		return
	
	errors.append_array(log_reader.errors)
	
	log_reader.next_line()
	
	var start_timestamp := log_reader.get_timestamp()
	var start_unix := TimeHelper.get_unix_time_from_timestamp(start_timestamp)
	
	var end_timestamp := log_reader.get_last_timestamp()
	var end_unix := TimeHelper.get_unix_time_from_timestamp(end_timestamp)
	
	if end_timestamp.is_empty():
		# the log file does not contain readable lines
		# I don't know how this happens exactly but it's possible
		save_data_to_disk(index, start_unix, end_unix)
		return
	
	while not log_reader.get_current_line().is_empty():
		parse_line(log_reader)
		
		log_reader.next_line()
	
	save_data_to_disk(index, start_unix, end_unix)
	
	return


func parse_line(log_reader: LogFileReader) -> void:
	var data := log_reader.handle_current_line(LogFileReader.Line.ALL, _current_profile)
	if data is Profile:
		if data.name in profiles:
			_current_profile = profiles[data.name]
		else:
			profiles[data.name] = data
			_current_profile = data


func get_profile(profile_name: String, allow_unused: bool = true) -> Profile:
	var profile = profiles[profile_name]
	if profile is Profile and (allow_unused or not profile.quests.is_empty()):
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
