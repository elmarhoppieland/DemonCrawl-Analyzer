extends RefCounted
class_name DemonCrawl

# ==============================================================================
const LOG_FILE_NAME := "log%d.txt"
# ==============================================================================

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
	return get_logs_dir().path_join(LOG_FILE_NAME % index)


## Returns the path to the last (most recent) log file.
static func get_last_log_path() -> String:
	var log_files := DirAccess.get_files_at(get_logs_dir()) as Array
	log_files.sort_custom(func(a: String, b: String) -> bool:
		return a.to_int() < b.to_int()
	)
	return get_logs_dir().path_join(log_files[-1])


## Returns the number of log files used by the user.
static func get_logs_count() -> int:
	return DirAccess.get_files_at(DemonCrawl.get_logs_dir()).size() - 1 # substract 1 to exclude the _repairs.txt file


## Opens the log file at the given [code]index[/code] and returns the created [FileAccess],
## using the given [code]flags[/code] as a [enum FileAccess.ModeFlags] constant to open it.
static func open_log_file(index: int, flags: FileAccess.ModeFlags = FileAccess.READ) -> FileAccess:
	if index < 1:
		index += get_logs_count()
	
	var path := get_logs_dir().path_join(LOG_FILE_NAME % index)
	
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
