extends Node

# ==============================================================================
## The status of the data. To obtain the status, use [method get_data_status].
enum DataStatus {
	UP_TO_DATE, ## The data is from the current Analyzer version, and contains data from all log files.
	NEW_DATA_FOUND, ## The data is from the current Analyzer version, but new log files were created since the last Analyzer launch.
	OUTDATED_VERSION ## The data was from a different (usually older) Analyzer version. New data may or may not be found.
}
enum Tab {
	HISTORY,
	WINS,
	STATISTICS,
	TIMELINE,
	ERRORS
}
# ==============================================================================
const SAVE_DATA_DIRECTORY := "user://Profiles"
const SAVE_DATA_DIRECTORY_DEBUG := "user://Profiles_debug"
const SAVE_DATA_BACKUPS_DIRECTORY := "user://Backups"
const SAVE_DATA_BACKUPS_DIRECTORY_DEBUG := "user://Backups_debug"
const SAVE_DATA_FILENAME := "profiles%d.dcstat"

## The path to the quests file while not in debug mode.
const QUESTS_FILE := "user://quests.dca"
## The path to the quests file while in debug mode.
const QUESTS_FILE_DEBUG := "user://quests-debug.dca"
## The path to the profiles file while not in debug mode.
const PROFILES_FILE := "user://profiles.dca"
## The path to the profiles file while in debug mode.
const PROFILES_FILE_DEBUG := "user://profiles-debug.dca"

## The path to the settings file.
const SETTINGS_FILE := "user://settings.cfg"

## The current version. Formatted as [code]MAJOR.minor.bugfix.debug[/code].
const CURRENT_VERSION := "1.3.0.0"
# ==============================================================================
## Whether the Analzer was launched for the first time (i.e. no data was saved before this launch).
var first_launch := false : get = is_first_launch
# ==============================================================================

func _ready() -> void:
	check_first_launch()


## Checks whether this launch was the first launch and sets [member first_launch]
## to the correct value.
func check_first_launch() -> void:
	first_launch = not DirAccess.dir_exists_absolute(get_savedata_directory())


## Returns the specified tab if it exists, or [code]null[/code] otherwise.
## See the [enum Tab] constants for more information about each tab.
func get_tab(tab: Tab) -> Control:
	var tab_path: String = "/root/Statistics/" + Tab.find_key(tab).capitalize()
	return get_node_or_null(tab_path)


## Saves the [code]setting[/code] in the [code]section[/code] to [code]value[/code] in the settings file.
func save_setting(section: String, setting: String, value: Variant) -> void:
	SettingsFile.set_setting_static(section, setting, value)


## Returns the current Analyzer version. If [code]include_debug[/code] is [code]false[/code],
## removes the [code]debug[/code] part of the version identifier. If no value is
## specified, will use [method OS.is_debug_build] to determine whether the debug
## should be included.
func get_version(include_debug: bool = OS.is_debug_build()) -> String:
	if include_debug:
		return CURRENT_VERSION
	
	var split := CURRENT_VERSION.split(".", false, 2)
	split[-1] = split[-1].get_slice(".", 0)
	return ".".join(split)


## Returns the value of [code]setting[/code] in [code]section[/code] of the settings
## file, or [code]default[/code] if it does not exist. If it does not exists and
## [code]default[/code] is [code]null[/code], will print an error message.
func get_setting(section: String, setting: String, default: Variant = null) -> Variant:
	return get_settings().get_value(section, setting, default)


## Returns a new [code]SettingsFile[/code] that contains data from the settings file.
func get_settings() -> SettingsFile:
	var settings := SettingsFile.new()
	if FileAccess.file_exists(SETTINGS_FILE):
		settings.load(SETTINGS_FILE)
	else:
		# create the file
		FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	
	return settings


## Saves the settings in [code]new_settings[/code] to disk.
func save_settings(new_settings: SettingsFile) -> void:
	new_settings.save_settings()


func get_backup_directory() -> String:
	if OS.is_debug_build():
		return SAVE_DATA_BACKUPS_DIRECTORY_DEBUG
	
	return SAVE_DATA_BACKUPS_DIRECTORY


func get_savedata_directory() -> String:
	if OS.is_debug_build():
		return SAVE_DATA_DIRECTORY_DEBUG
	
	return SAVE_DATA_DIRECTORY


func get_savedata_path(index: int) -> String:
	var dir_path := get_savedata_directory()
	
	if index < 0:
		index += DirAccess.get_files_at(dir_path).size()
	
	return dir_path.path_join(SAVE_DATA_FILENAME % index)


func open_savedata_file(index: int, allow_create: bool = false) -> FileAccess:
	var path := get_savedata_path(index)
	if allow_create and not FileAccess.file_exists(path):
		FileAccess.open(path, FileAccess.WRITE)
	
	var file :=  FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Error occurred while trying to read from path %s: %s. Aborting process..." % [path, error_string(FileAccess.get_open_error())])
		return null
	
	return file


func savedata_file_exists(index: int) -> bool:
	return FileAccess.file_exists(get_savedata_path(index))


func get_savedata(index: int) -> Dictionary:
	var file := open_savedata_file(index)
	var json = JSON.parse_string(file.get_as_text())
	if not json is Dictionary:
		return {}
	
	return json


## Returns the path to the quests file (i.e. [constant QUESTS_FILE] or
## [constant QUESTS_FILE_DEBUG]).
func get_quests_file_path(debug: bool = OS.is_debug_build()) -> String:
	return QUESTS_FILE_DEBUG if debug else QUESTS_FILE


## Opens the quests file at path [constant QUESTS_FILE] and returns it.
func open_quests_file(flags: FileAccess.ModeFlags = FileAccess.READ) -> FileAccess:
	return FileAccess.open(get_quests_file_path(), flags)


## Returns the path to the profiles file (i.e. [constant PROFILES_FILE] or
## [constant PROFILES_FILE_DEBUG]).
func get_profiles_file_path(debug: bool = OS.is_debug_build()) -> String:
	return PROFILES_FILE_DEBUG if debug else PROFILES_FILE


## Opens the profiles file at path [constant PROFILES_FILE] and returns it.
func open_profiles_file(flags: FileAccess.ModeFlags = FileAccess.READ) -> FileAccess:
	return FileAccess.open(get_profiles_file_path(), flags)


## Returns the status of the saved data as a [enum DataStatus] constant:
## [br]- [constant UP_TO_DATE]: The data is up to date. No new data can be retrieved,
## and the data is from the current Analyzer version.
## [br]- [constant NEW_DATA_FOUND]: The data is from the current Analyzer version,
## but a new log file was created since the last Analyzer launch.
## [br]- [constant OUTDATED_VERSION]: The data is from a different (usually older)
## Analyzer version. The data may or may not be outdated.
func get_data_status() -> DataStatus:
	if get_setting("-Data", "version", "0.0.0") != get_version():
		return DataStatus.OUTDATED_VERSION
	
	var log_file := DemonCrawl.open_log_file(DemonCrawl.get_logs_count())
	var log_timestamp := log_file.get_line().get_slice("]", 0).trim_prefix("[")
#	if get_setting("-Data", "end_timestamp") < log_timestamp:
	if TimeHelper.timestamp_is_before_timestamp(get_setting("-Data", "end_timestamp"), log_timestamp):
		return DataStatus.NEW_DATA_FOUND
	
	return DataStatus.UP_TO_DATE


func is_first_launch() -> bool:
	return first_launch
