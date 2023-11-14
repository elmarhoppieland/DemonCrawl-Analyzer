extends Node
class_name HistorySaver

# ==============================================================================
var _log_files: Array[LogFile] = []
# ==============================================================================

func load_log_files(files: Array[LogFile]) -> void:
	_log_files = files


func save(path: String, override: bool = false) -> void:
	if override:
		FileAccess.open(path, FileAccess.WRITE).close()
	
	for file in _log_files:
		file.save_compiled(path, false)
