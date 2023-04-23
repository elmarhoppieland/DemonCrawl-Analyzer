extends RefCounted
class_name DemonCrawl

# ==============================================================================
const LOG_FILE_NAME := "log%d.txt"
# ==============================================================================

static func get_logs_dir() -> String:
	return OS.get_data_dir().get_base_dir().path_join("Local/demoncrawl/logs")


static func get_log_path(index: int) -> String:
	return get_logs_dir().path_join(LOG_FILE_NAME % index)


static func get_logs_count() -> int:
	return DirAccess.get_files_at(DemonCrawl.get_logs_dir()).size() - 1 # substract 1 to exclude the _repairs.txt file


static func open_log_file(index: int, flags: FileAccess.ModeFlags = FileAccess.READ) -> FileAccess:
	if index < 1:
		index += get_logs_count()
	
	var path := get_logs_dir().path_join(LOG_FILE_NAME % index)
	
	return FileAccess.open(path, flags)
