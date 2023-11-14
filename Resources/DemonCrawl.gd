extends RefCounted
class_name DemonCrawl

# ==============================================================================
static var log_files := []
static var stage_bg_images := {}
static var quest_bg_images := {}
# ==============================================================================

static func poll_logs_dir() -> void:
	var files := DirAccess.get_files_at(get_user_data_dir().path_join("logs"))
	log_files = Array(files).filter(func(a: String):
		return not a.begins_with("_")
	)
	log_files.sort_custom(func(a: String, b: String):
		return a.to_int() < b.to_int()
	)


static func get_user_data_dir() -> String:
	return OS.get_data_dir().get_base_dir().path_join("Local/demoncrawl")


static func get_data_dir() -> String:
	return "C:/Program Files (x86)/Steam/steamapps/common/DemonCrawl"


## Returns the directory that contains all the user's log files.
static func get_logs_dir() -> String:
	var dir := ProjectSettings.get_setting_with_override("custom/demoncrawl/logs_directory") as String
	return dir.replace("%localappdata%", OS.get_data_dir().get_base_dir().path_join("Local"))


## Returns the path to the log file at the given [code]index[/code].
static func get_log_path(index: int) -> String:
	return get_logs_dir().path_join(log_files[index])


## Returns the path to the last (most recent) log file.
static func get_last_log_path() -> String:
	return get_logs_dir().path_join(log_files[-1])


## Returns the index of the last (most recent) log file that starts after [code]after_unix[/code].
## Returns [code]-1[/code] if no such log file exists.
static func get_last_log_file_index_after(after_unix: int) -> int:
	for i in get_logs_count():
		var time := TimeHelper.get_unix_time_from_timestamp(get_log_start_timestamp(i))
		if time > after_unix:
			return i
	
	return -1


## Returns the number of log files used by the user.
static func get_logs_count() -> int:
	return log_files.size()


## Opens the log file at the given [code]index[/code] and returns the created [FileAccess],
## using the given [code]flags[/code] as a [enum FileAccess.ModeFlags] constant to open it.
static func open_log_file(index: int, flags: FileAccess.ModeFlags = FileAccess.READ) -> FileAccess:
	if index < 0:
		index += get_logs_count()
	
	var path := get_log_path(index)
	
	return FileAccess.open(path, flags)


## Opens the last (most recent) log file and returns the created [FileAccess],
## using the given [code]flags[/code] as a [enum FileAccess.ModeFlags] constant to open it.
static func open_last_log_file(flags: FileAccess.ModeFlags = FileAccess.READ) -> FileAccess:
	return FileAccess.open(get_last_log_path(), flags)


## Returns the directory that contains all the user's DemonCrawl save files.
static func get_save_files_dir() -> String:
	var dir_path := ProjectSettings.get_setting_with_override("custom/demoncrawl/saves_directory") as String
	return dir_path.replace("%localappdata%", OS.get_data_dir().get_base_dir().path_join("Local"))


## Returns the path to the save file with the given [code]save_name[/code].
## [br][br][b]Note:[/b] Since save files are encrypted, there is no way to extract
## data from the save file directly.
static func get_save_file_path(save_name: String) -> String:
	return get_save_files_dir().path_join(save_name + ".ini")


## Returns whether an instance of DemonCrawl is currently running.
static func is_running() -> bool:
	return not Analyzer.get_active_window_pids("demoncrawl.exe").is_empty()


## Returns the PID (process ID) of the DemonCrawl instance, if it is running.
## If DemonCrawl is not running, returns [code]-1[/code].
static func get_pid() -> int:
	var pids := Analyzer.get_active_window_pids("demoncrawl.exe")
	if pids.is_empty():
		return -1
	
	return pids[0]


## Runs DemonCrawl.
static func run() -> void:
	OS.shell_open("steam://rungameid/1141220")


## Opens the [code]settings.ini[/code] file in the user's data dir. Does [b]not[/b] handle errors.
static func open_settings_file() -> ConfigFile:
	var file := ConfigFile.new()
	var error := file.load(get_user_data_dir().path_join("settings.ini"))
	if error:
		return null
	return file


## Returns the DemonCrawl-formatted timestamp in the first line in the log file at the given [code]index[/code].
static func get_log_start_timestamp(index: int) -> String:
	var file := open_log_file(index)
	return file.get_line().trim_prefix("[").get_slice("]", 0)


## Returns the background [ImageTexture] used for the given [code]stage[/code].
## Creates a new [Image] if needed, but will load from the cache if able.
static func get_stage_bg(stage: String) -> ImageTexture:
	if not stage in stage_bg_images:
		var thread := AutoThread.new()
		thread.start_execution(func():
			var image := Image.load_from_file(DemonCrawl.get_data_dir().path_join("assets/skins/%s/bg.png" % stage.to_lower()))
			stage_bg_images[stage] = image
		)
	
	while not stage_bg_images.get(stage):
		await Analyzer.get_tree().process_frame
	
	return ImageTexture.create_from_image(stage_bg_images[stage])


## Returns the background [ImageTexture] used for the quest with the given
## [code]index[/code]. Creates a new [Image] if needed, but will load from the
## cache if able.
static func get_quest_bg(index: int) -> ImageTexture:
	if not index in quest_bg_images:
		var thread := AutoThread.new()
		thread.start_execution(func():
			var image := Image.load_from_file(DemonCrawl.get_data_dir().path_join("assets/bg/stages%d.png" % index))
			quest_bg_images[index] = image
		)
	
	while not quest_bg_images.get(index):
		await Analyzer.get_tree().process_frame
	
	return ImageTexture.create_from_image(quest_bg_images[index])
