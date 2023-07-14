extends Node

## Singleton for functions regarding the Analyzer.

# ==============================================================================
## The status of the data. To obtain the status, use [method get_data_status].
enum DataStatus {
	UP_TO_DATE, ## The data is from the current Analyzer version, and contains data from all log files.
	NEW_DATA_FOUND, ## The data is from the current Analyzer version, but new log files were created since the last Analyzer launch.
	OUTDATED_VERSION ## The data was from a different (usually older) Analyzer version. New data may or may not be found.
}
## The tabs in the Analyzer. To obtain a tab, use [method get_tab] or [code]TabName.get_tab()[/code].
enum Tab {
	HISTORY, ## The [History] tab.
	WINS, ## The [Wins] tab.
	STATISTICS, ## The [GlobalStatistics] tab.
	TIMELINE, ## The [TimeLine] tab.
	ERRORS, ## The [Errors] tab.
	ADVANCED ## The [Advanced] tab.
}
# ==============================================================================
const _SAVE_DATA_DIRECTORY := "user://Profiles"
const _SAVE_DATA_DIRECTORY_DEBUG := "user://Profiles_debug"
const _SAVE_DATA_FILENAME := "profiles%d.dcstat"

## The path to the quests file.
const QUESTS_FILE := "user://quests.dca"
## The path to the quests file while in debug mode.
const QUESTS_FILE_DEBUG := "user://quests-debug.dca"
## The path to the backup of quests file.
const QUESTS_BACKUP_FILE := "user://quests-backup.dca"
## The path to the backup of quests file while in debug mode.
const QUESTS_BACKUP_FILE_DEBUG := "user://quests-debug-backup.dca"
## The path to the profiles file.
const PROFILES_FILE := "user://profiles.dca"
## The path to the profiles file while in debug mode.
const PROFILES_FILE_DEBUG := "user://profiles-debug.dca"
## The path to the backup of the profiles file.
const PROFILES_BACKUP_FILE := "user://profiles-backup.dca"
## The path to the backup of the profiles file while in debug mode.
const PROFILES_BACKUP_FILE_DEBUG := "user://profiles-debug-backup.dca"

## The path to the settings file.
const SETTINGS_FILE := "user://settings.cfg"

## The current version. Formatted as [code]MAJOR.minor.bugfix.debug[/code].
const CURRENT_VERSION := "1.3.0.0"

## The path to the backup file for save files.
const SAVE_FILE_BACKUP_PATH := "user://save-backup.ini"
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
	var tab_path: String = "/root/Statistics/TabContainer/" + Tab.find_key(tab).capitalize()
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


## Returns the path to the savedata directory.
## [br][br][b]Note:[/b] This method is [b]deprecated[/b] as savedata files are no longer used.
func get_savedata_directory() -> String:
	if OS.is_debug_build():
		return _SAVE_DATA_DIRECTORY_DEBUG
	
	return _SAVE_DATA_DIRECTORY


## Returns the path to the savedata file with the given [code]index[/code].
## [br][br][b]Note:[/b] This method is [b]deprecated[/b] as savedata files are no longer used.
func get_savedata_path(index: int) -> String:
	var dir_path := get_savedata_directory()
	
	if index < 0:
		index += DirAccess.get_files_at(dir_path).size()
	
	return dir_path.path_join(_SAVE_DATA_FILENAME % index)


## Opens the savedata file at the given [code]index[/code], using [constant FileAccess.WRITE].
## [br][br][b]Note:[/b] This method is [b]deprecated[/b] as savedata files are no longer used.
func open_savedata_file(index: int, allow_create: bool = false) -> FileAccess:
	var path := get_savedata_path(index)
	if allow_create and not FileAccess.file_exists(path):
		FileAccess.open(path, FileAccess.WRITE)
	
	var file :=  FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Error occurred while trying to read from path %s: %s. Aborting process..." % [path, error_string(FileAccess.get_open_error())])
		return null
	
	return file


## Returns the savedata in the file in the given [code]index[/code] as a [Dictionary].
## [br][br][b]Note:[/b] This method is [b]deprecated[/b] as savedata files are no longer used.
func get_savedata(index: int) -> Dictionary:
	var file := open_savedata_file(index)
	var json = JSON.parse_string(file.get_as_text())
	if not json is Dictionary:
		return {}
	
	return json


## Returns the path to the backup file of the quests file (i.e. [constant QUESTS_BACKUP_FILE] or
## [constant QUESTS_BACKUP_FILE_DEBUG]).
func get_quests_backup_file_path(debug: bool = OS.is_debug_build()) -> String:
	return QUESTS_BACKUP_FILE_DEBUG if debug else QUESTS_BACKUP_FILE


## Returns the path to the quests file (i.e. [constant QUESTS_FILE] or
## [constant QUESTS_FILE_DEBUG]).
func get_quests_file_path(debug: bool = OS.is_debug_build()) -> String:
	return QUESTS_FILE_DEBUG if debug else QUESTS_FILE


## Opens the quests file at path [constant QUESTS_FILE] and returns it.
func open_quests_file(flags: FileAccess.ModeFlags = FileAccess.READ) -> FileAccess:
	return FileAccess.open(get_quests_file_path(), flags)


## Returns the path to the backup file of the profiles file (i.e. [constant PROFILES_BACKUP_FILE]
## or [constant PROFILES_BACKUP_FILE_DEBUG]).
func get_profiles_backup_file_path(debug: bool = OS.is_debug_build()) -> String:
	return PROFILES_BACKUP_FILE_DEBUG if debug else PROFILES_BACKUP_FILE


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
	if TimeHelper.timestamp_is_before_timestamp(get_setting("-Data", "end_timestamp"), log_timestamp):
		return DataStatus.NEW_DATA_FOUND
	
	return DataStatus.UP_TO_DATE


func is_first_launch() -> bool:
	return first_launch
