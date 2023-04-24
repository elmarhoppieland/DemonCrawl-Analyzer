extends Node

# ==============================================================================
enum DataStatus {
	UP_TO_DATE,
	NEW_DATA_FOUND,
	OUTDATED_VERSION
}
# ==============================================================================
const SAVE_DATA_DIRECTORY := "user://Profiles"
const SAVE_DATA_DIRECTORY_DEBUG := "user://Profiles_debug"
const SAVE_DATA_BACKUPS_DIRECTORY := "user://Backups"
const SAVE_DATA_BACKUPS_DIRECTORY_DEBUG := "user://Backups_debug"
const SAVE_DATA_FILENAME := "profiles%d.dcstat"

const SETTINGS_FILE := "user://settings.cfg"

## The current version. Formatted as [code]MAJOR.minor.bugfix.debug[/code].
const CURRENT_VERSION := "1.1.0.12"
# ==============================================================================
var first_launch := false : get = is_first_launch
# ==============================================================================

func _ready() -> void:
	check_first_launch()


func check_first_launch() -> void:
	first_launch = not DirAccess.dir_exists_absolute(get_savedata_directory())


func save_setting(section: String, setting: String, value: Variant) -> void:
	SettingsFile.set_setting_static(section, setting, value)


func get_version(include_debug: bool = OS.is_debug_build()) -> String:
	if include_debug:
		return CURRENT_VERSION
	
	var split := CURRENT_VERSION.split(".", false, 2)
	split[-1] = split[-1].get_slice(".", 0)
	print(split)
	return ".".join(split)


func get_setting(section: String, setting: String, default: Variant = null) -> Variant:
	return get_settings().get_value(section, setting, default)


func get_settings() -> SettingsFile:
	var settings := SettingsFile.new()
	if FileAccess.file_exists(SETTINGS_FILE):
		settings.load(SETTINGS_FILE)
	else:
		# create the file
		FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	
	return settings


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


func get_data_status() -> DataStatus:
	var file := open_savedata_file(-1)
	var json = JSON.parse_string(file.get_as_text())
	
	if json is Dictionary:
		if "version" in json:
			var version: String = json.version
			if version != get_version():
				return DataStatus.OUTDATED_VERSION
		if "start_unix" in json:
			var start_unix_json: int = json.start_unix
			var log_file := DemonCrawl.open_log_file(DemonCrawl.get_logs_count())
			var start_unix_log := TimeHelper.get_unix_time_from_timestamp(log_file.get_line().get_slice("]", 0).trim_prefix("["))
			if start_unix_json != start_unix_log:
				return DataStatus.NEW_DATA_FOUND
	
	return DataStatus.UP_TO_DATE


func is_first_launch() -> bool:
	return first_launch
