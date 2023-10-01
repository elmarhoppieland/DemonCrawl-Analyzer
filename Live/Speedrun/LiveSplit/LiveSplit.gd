extends Control
class_name LiveSplit

# ==============================================================================
enum SplitFrequency {
	EACH_STAGE,
	EACH_QUEST
}
# ==============================================================================
static var attempt_count := 0
static var timer := 0.0
static var is_running := false
static var current_split := -1
static var split_times: PackedFloat32Array = []
# ==============================================================================
var mouse_is_in_window := false
var last_mouse_position := Vector2.ZERO
var is_dragging := false

var last_update := -1
var waiting_for_new_log_file := false

var previous_log_file_length := 0

var is_first_frame := true
# ==============================================================================
@onready var original_window_size := get_window().get_size_with_decorations()
@onready var original_window_mode := get_window().mode
@onready var splits := %Splits as Splits
# ==============================================================================

func _ready() -> void:
	ResourceLoader.load_threaded_request("res://Live/Speedrun/Speedrun.tscn")
	
	splits.set_category(LiveSplitEditor.category, true, LiveSplitEditor.split_frequency)
	
	initialize_dragging()
	
	initialize_autosplitter()


func _process(delta: float) -> void:
	handle_dragging()
	
	handle_autosplitter()
	
	if OS.is_debug_build() and Input.is_action_just_pressed("livesplit_split_manual"):
		if is_running:
			split()
		else:
			start()
	
	if is_running:
		timer += delta
		
		splits.set_timer(timer)


func start() -> void:
	if current_split:
		print_rich("[color=red]Resetting old run[/color]")
		reset()
	
	print_rich("[color=lime]Starting a new run[/color]")
	
	var file_name := Leaderboards.get_category_name(LiveSplitEditor.category)
	if LiveSplit.comparison_exists(file_name):
		print_rich("[color=gold]Loading comparison %s[/color]" % file_name)
		LiveSplitEditor.comparison = LiveSplit.load_comparison(file_name)
	else:
		print_rich("[color=gold]No comparison found for %s[/color]" % file_name)
	
	print_rich("[color=gold]Loading best times[/color]")
	LiveSplitEditor.load_best_times()
	
	if current_split >= 0:
		splits.get_split(current_split).deactivate()
	
	for i in splits.splits:
		var time := LiveSplitEditor.get_comparison_time_to_split(i.split_index + 1)
		var time_string = LiveSplit.get_time_string(time)
		i.time_label.text = time_string
	
	is_running = true
	
	timer = 0
	current_split = 0
	
	splits.get_split(0).activate()
	splits.scroll_to_split(0)


func split() -> void:
	splits.get_split(current_split).deactivate()
	if current_split + 1 >= splits.get_split_count():
		stop()
		return
	
	print_rich("[color=aqua]Splitting to split ", current_split + 1, " (%s)[/color]" % splits.get_split(current_split + 1).name)
	
	current_split += 1
	splits.get_split(current_split).activate()
	
	splits.scroll_to_split(current_split)


func stop() -> void:
	is_running = false
	
	LiveSplit.save_comparison(split_times, Leaderboards.get_category_name(LiveSplitEditor.category))
	
	LiveSplitEditor.save_best_times()


func reset() -> void:
	is_running = false
	
	timer = 0
	splits.set_timer(0)
	current_split = -1
	
	for i in splits.splits:
		i.reset()
	
	splits.splits_scroll_container.scroll_vertical = 0
	
	split_times.clear()


func handle_autosplitter() -> void:
	if waiting_for_new_log_file:
		is_first_frame = false
		return
	if FileAccess.get_modified_time(DemonCrawl.get_last_log_path()) <= last_update:
		is_first_frame = false
		return
	
	var log_file := DemonCrawl.open_last_log_file()
	if not log_file:
		push_error("Could not open the final log file: ", error_string(FileAccess.get_open_error()))
		return
	
	last_update = FileAccess.get_modified_time(DemonCrawl.get_last_log_path())
	
	log_file.seek(previous_log_file_length)
	previous_log_file_length = log_file.get_length()
	
	while true:
		var line := log_file.get_line()
		if line.is_empty():
			return
		var line_type := LogFileReader.get_line_type(line)
		match line_type:
			LogFileReader.Line.QUEST_CREATE:
				var split_data := LiveSplitEditor.splits[0]
				var quest_name := line.get_slice("Quest started: ", 1).get_slice(" on ", 0)
				if "section_condition" in split_data:
					if split_data.section_condition == "Quest::" + quest_name:
						start()
			LogFileReader.Line.STAGE_LEAVE:
				if not is_running:
					continue
				
				var current_split_data := LiveSplitEditor.splits[current_split]
				var stage_name := line.get_slice(" ", line.get_slice_count(" ") - 1)
				if current_split_data.condition == "Stage::" + stage_name:
					split()


func handle_dragging() -> void:
	if Input.is_action_just_pressed("livesplit_return"):
		get_window().size = original_window_size
		get_window().always_on_top = false
		get_window().borderless = false
		get_window().mode = original_window_mode
		
		SceneHandler.switch_scene(ResourceLoader.load_threaded_get("res://Live/Speedrun/Speedrun.tscn"))
		return
	
	if mouse_is_in_window and Input.is_action_just_pressed("ui_left_click"):
		last_mouse_position = get_window().get_mouse_position()
		is_dragging = true
		return
	
	if Input.is_action_just_released("ui_left_click"):
		is_dragging = false
		return
	
	if is_dragging and Input.is_action_pressed("ui_left_click"):
		get_window().position += Vector2i(get_window().get_mouse_position() - last_mouse_position)
		
		last_mouse_position = get_window().get_mouse_position()


func initialize_autosplitter() -> void:
	var log_file := DemonCrawl.open_last_log_file()
	if not log_file:
		push_error("Could not open the final log file: ", error_string(FileAccess.get_open_error()))
		return
	
	var pos := log_file.get_length() - 1
	while pos > 0:
		pos -= 1
		log_file.seek(pos)
		var character := log_file.get_8()
		if char(character) == "\n":
			break
	
	var line := log_file.get_line()
	if not line.match("*DemonCrawl closed"):
		# this file is of the current game
		waiting_for_new_log_file = false
		previous_log_file_length = log_file.get_length()
		return
	
	waiting_for_new_log_file = true
	
	var logs_count := DemonCrawl.get_logs_count()
	
	while DemonCrawl.get_logs_count() == logs_count:
		await get_tree().physics_frame
	
	waiting_for_new_log_file = false


func initialize_dragging() -> void:
	get_window().borderless = true
	get_window().always_on_top = true
	await get_tree().process_frame
	get_window().size = splits.size
	
	mouse_is_in_window = \
		get_window().get_mouse_position().x < get_window().size.x and \
		get_window().get_mouse_position().y < get_window().size.y
	
	get_window().mouse_entered.connect(func(): mouse_is_in_window = true)
	get_window().mouse_exited.connect(func(): mouse_is_in_window = false)


static func get_time_string(time_sec: float, decimal_count: int = 2) -> String:
	var time_string := Time.get_time_string_from_unix_time(int(time_sec))
	if decimal_count > 0:
		time_string += "." + str(int(fmod(time_sec, 1) * 10 ** decimal_count))
	
	if time_sec >= 36000: # over 10 hours
		return time_string
	time_string = time_string.trim_prefix("0")
	
	if time_sec >= 3600: # over 1 hour
		return time_string
	time_string = time_string.trim_prefix("0:")
	
	if time_sec >= 600: # over 10 min
		return time_string
	time_string = time_string.trim_prefix("0")
	
	if time_sec >= 60: # over 1 min
		return time_string
	
	time_string = time_string.trim_prefix("0:")
	if time_sec >= 10: # over 10 sec
		return time_string
	
	return time_string.trim_prefix("0")


static func save_comparison(times: PackedFloat32Array, file_name: String, directory: String = "user://speedrunning") -> void:
	var file := FileAccess.open(directory.path_join(file_name + ".dcst"), FileAccess.WRITE)
	if not file:
		push_error("Could not save comparison '%s' (to dir %s): %s" % [file_name, directory, error_string(FileAccess.get_open_error())])
		return
	
	for time in times:
		file.store_float(time)


static func load_comparison(file_name: String, directory: String = "user://speedrunning") -> PackedFloat32Array:
	var file := FileAccess.open(directory.path_join(file_name + ".dcst"), FileAccess.READ)
	if not file:
		push_error("Could not load comparison '%s': %s" % [file_name, FileAccess.get_open_error()])
		return []
	
	var times := PackedFloat32Array()
	
	while file.get_position() < file.get_length():
		times.append(file.get_float())
	
	return times


static func comparison_exists(file_name: String, directory: String = "user://speedrunning") -> bool:
	return FileAccess.file_exists(directory.path_join(file_name + ".dcst"))
