extends Node

# ==============================================================================
const HISTORY_FILE := "user://logs.dch"
# ==============================================================================
static var _load_progress_ptr: Progress

static var _history: Array[HistoryFile.LineData] = []
# ==============================================================================

func get_progress() -> Progress:
	return _load_progress_ptr


func load_history() -> Progress:
	if get_progress():
		return get_progress()
	
	var progress := Progress.new()
	
	var file := FileAccess.open(HISTORY_FILE, FileAccess.READ)
	if not file:
		push_error("Could not open the history file to get its length.")
		return null
	
	progress.max_progress = file.get_length()
	
	_load_progress_ptr = progress
	
	var thread := Thread.new()
	thread.start(func(): _load())
	progress.finished.connect(func(): thread.wait_to_finish())
	
	return progress


func _load() -> void:
	_check_update()
	
	var file := HistoryFile.open(HISTORY_FILE)
	
	get_progress().max_progress = file.get_length()
	
	while true:
		var batch := file.get_batch()
		if batch.is_empty():
			break
		
		Packages.call_method("history_load_batch", [batch])
		
		for line in batch.lines:
			Packages.call_method("history_load_line", [line])
			
			var returns := Packages.call_method("history_load_line_keep", [line])
			if true in returns:
				_save_event(line)
		
		get_progress().set_progress(file.get_position())


func _save_event(event: HistoryFile.LineData) -> void:
	_history.append(event)


func _check_update() -> void:
	var data_unix_time := FileAccess.get_modified_time(HISTORY_FILE)
	var logs_unix_time := FileAccess.get_modified_time(DemonCrawl.get_log_path(1))
	
	if logs_unix_time > data_unix_time:
		_update()


func _update() -> void:
	pass


class Progress extends RefCounted:
	var progress := 0
	var max_progress := 0 :
		set(value):
			max_progress = value
			(func(): max_progress_updated.emit()).call_deferred()
			
			if is_finished():
				(func(): finished.emit()).call_deferred()
	
	signal progress_updated(new_progress: int)
	signal max_progress_updated(new_max_progress: int)
	signal finished()
	
	
	func progress_increment() -> void:
		progress += 1
		(func(): progress_updated.emit(progress)).call_deferred()
		
		if is_finished():
			(func(): finished.emit()).call_deferred()
	
	
	func set_progress(value: int) -> void:
		progress = value
		(func(): progress_updated.emit(progress)).call_deferred()
		
		if is_finished():
			(func(): finished.emit()).call_deferred()
	
	
	func is_finished() -> bool:
		return progress >= max_progress
