extends RefCounted
class_name DemonCrawl


# ==============================================================================
const LOG_FILE_NAME := "log%d.txt"
# ==============================================================================

## Returns the directory that contains all the user's log files.
static func get_logs_dir() -> String:
	var dir := ProjectSettings.get_setting_with_override("custom/demoncrawl/logs_directory") as String
	return dir.replace("%localappdata%", OS.get_data_dir().get_base_dir().path_join("Local"))


## Returns the path to the log file at the given [code]index[/code].
static func get_log_path(index: int) -> String:
	return get_logs_dir().path_join(LOG_FILE_NAME % index)


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


## Returns the directory that contains all the user's DemonCrawl save files.
static func get_save_files_dir() -> String:
	var dir_path := ProjectSettings.get_setting_with_override("custom/demoncrawl/saves_directory") as String
	return dir_path.replace("%localappdata%", OS.get_data_dir().get_base_dir().path_join("Local"))


## Returns the path to the save file with the given [code]save_name[/code].
## [br][br][b]Note:[/b] Since the files are encrypted, there is no way to extract
## data from the save file directly.
static func get_save_file_path(save_name: String) -> String:
	return get_save_files_dir().path_join(save_name + ".ini")
