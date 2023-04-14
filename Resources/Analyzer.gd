extends RefCounted
class_name Analyzer

# ==============================================================================
const SAVE_DATA_DIRECTORY := "user://Profiles"
const SAVE_DATA_DIRECTORY_DEBUG := "user://Profiles_debug"
const SAVE_DATA_BACKUPS_DIRECTORY := "user://Backups"
const SAVE_DATA_BACKUPS_DIRECTORY_DEBUG := "user://Backups_debug"
const SAVE_DATA_FILENAME := "profiles%d.dcstat"

const SETTINGS_FILE := "user://settings.cfg"

## The current version. Formatted as [code]MAJOR.minor.bugfix.debug[/code].
const CURRENT_VERSION := "1.0.0.8"
# ==============================================================================

static func get_settings() -> SettingsFile:
	var config := SettingsFile.new()
	if FileAccess.file_exists(SETTINGS_FILE):
		config.load(SETTINGS_FILE)
	else:
		# create the file
		FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	
	return config


static func save_settings(new_settings: SettingsFile) -> void:
	new_settings.save_settings()


static func get_backup_directory() -> String:
	if OS.is_debug_build():
		return SAVE_DATA_BACKUPS_DIRECTORY_DEBUG
	
	return SAVE_DATA_BACKUPS_DIRECTORY


static func get_savedata_directory() -> String:
	if OS.is_debug_build():
		return SAVE_DATA_DIRECTORY_DEBUG
	
	return SAVE_DATA_DIRECTORY


static func get_savedata_path(index: int) -> String:
	var dir_path := get_savedata_directory()
	
	if index < 0:
		index += DirAccess.get_files_at(dir_path).size()
	
	return dir_path.path_join(SAVE_DATA_FILENAME % index)


static func open_savedata_file(index: int, allow_create: bool = false) -> FileAccess:
	var path := get_savedata_path(index)
	if allow_create and not FileAccess.file_exists(path):
		FileAccess.open(path, FileAccess.WRITE)
	
	var file :=  FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Error occurred while trying to read from path %s: %s. Aborting process..." % [path, error_string(FileAccess.get_open_error())])
		return null
	
	return file


static func is_first_launch() -> bool:
	return not DirAccess.dir_exists_absolute(Analyzer.get_savedata_directory())
