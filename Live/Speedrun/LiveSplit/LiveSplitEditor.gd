extends ScrollContainer
class_name LiveSplitEditor

# ==============================================================================
static var category := Leaderboards.Category.CASUAL_FRESH_FILE_1_88
static var split_frequency := LiveSplit.SplitFrequency.EACH_STAGE
static var livesplit_title := ""

static var splits: Array[Dictionary] = []
static var comparison := PackedFloat32Array()
static var best_times := PackedFloat32Array()
# ==============================================================================
@onready var title_edit: LineEdit = %TitleEdit
@onready var difficulty_select: OptionButton = %DifficultySelect
@onready var type_select: OptionButton = %TypeSelect
@onready var hdfs_select: CheckButton = %HDFSSelect
@onready var version_select: OptionButton = %VersionSelect
@onready var split_frequency_select: OptionButton = %SplitFrequencySelect
@onready var attempt_count_edit: LineEdit = %AttemptCountEdit
# ==============================================================================
signal title_changed(new_title: String)
signal category_changed(new_category: Leaderboards.Category)
signal split_frequency_changed(new_frequency: LiveSplit.SplitFrequency)
signal attempt_count_changed(new_count: int)
# ==============================================================================

func _ready() -> void:
	for i in difficulty_select.item_count:
		difficulty_select.set_item_metadata(i, (0x10 * (i + 1)) as Leaderboards.Difficulty)
	
	title_edit.text = livesplit_title
	attempt_count_edit.text = str(LiveSplit.attempt_count)
	
	set_category(category)


func set_category(new_category: Leaderboards.Category) -> void:
	var level := Leaderboards.get_category_level(new_category)
	var difficulty := Leaderboards.get_category_difficulty(new_category)
	
	match difficulty:
		Leaderboards.Difficulty.CASUAL:
			difficulty_select.select(0)
		Leaderboards.Difficulty.CASUAL_RANDOM:
			difficulty_select.select(1)
		Leaderboards.Difficulty.NORMAL:
			difficulty_select.select(2)
		Leaderboards.Difficulty.HARD:
			difficulty_select.select(3)
	
	match level:
		Leaderboards.IL.DISABLED:
			if new_category & Leaderboards.FRESH_FILE:
				type_select.select(0)
			else:
				type_select.select(1)
		Leaderboards.IL.GLORY_DAYS:
			type_select.select(2)
		Leaderboards.IL.RESPITES_END:
			type_select.select(3)
		Leaderboards.IL.ANOTHER_WAY:
			type_select.select(4)
		Leaderboards.IL.AROUND_THE_BEND:
			type_select.select(5)
		Leaderboards.IL.SHADOWMAN:
			type_select.select(6)
	
	hdfs_select.button_pressed = new_category & Leaderboards.HDFS
	hdfs_select.disabled = new_category & Leaderboards.FRESH_FILE
	
	version_select.select(int(new_category & Leaderboards.DOWNPATCHED == 0))
	
	category_changed.emit(new_category)


func get_il() -> Leaderboards.IL:
	var selected_idx := type_select.selected
	var selected_item := type_select.get_item_text(selected_idx)
	
	match selected_item:
		"Fresh File", "All Quests":
			return Leaderboards.IL.DISABLED
		"Glory Days":
			return Leaderboards.IL.GLORY_DAYS
		"Respite's End":
			return Leaderboards.IL.RESPITES_END
		"Another Way":
			return Leaderboards.IL.ANOTHER_WAY
		"Around The Bend":
			return Leaderboards.IL.AROUND_THE_BEND
		"Shadowman":
			return Leaderboards.IL.SHADOWMAN
	
	return Leaderboards.IL.DISABLED


func get_difficulty() -> Leaderboards.Difficulty:
	return difficulty_select.get_selected_metadata()


func is_hdfs() -> bool:
	return hdfs_select.button_pressed


func is_fresh_file() -> bool:
	return type_select.get_item_text(type_select.selected) == "Fresh File"


func is_downpatched() -> bool:
	const DOWNPATCHED_VERSION_ID := 0
	
	return version_select.selected == DOWNPATCHED_VERSION_ID


func get_category() -> Leaderboards.Category:
	category = Leaderboards.get_category(
		get_difficulty(),
		get_il(),
		is_hdfs(),
		is_fresh_file(),
		is_downpatched()
	)
	return category


static func load_splits(file_path: String) -> void:
	splits.clear()
	
	match file_path.get_extension():
		"lss":
			_load_splits_from_lss(file_path)
		"dcsl":
			_load_splits_from_dcsl(file_path)
		_:
			push_error("Cannot load splits from '%s'; incompatible extension" % file_path)
			return


static func _load_splits_from_lss(_file_path: String) -> void:
	pass


static func _load_splits_from_dcsl(file_path: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("An error occured when trying to load splits from '%s': %s" % [file_path, error_string(FileAccess.get_open_error())])
		return
	
	while true:
		var line := file.get_line()
		if line.is_empty():
			return
		
		if line.begins_with("["):
			var section_name := line.trim_prefix("[").get_slice("]", 0)
			var section_condition := line.get_slice(",", 1)
			
			var subsplits_file := FileAccess.open(line.get_slice("{", 1).get_slice("}", 0), FileAccess.READ)
			if not subsplits_file:
				push_error("Could not open subsplits file '%s': %s" % [line.get_slice("{", 1).get_slice("}", 0), error_string(FileAccess.get_open_error())])
				continue
			
			while true:
				var subsplit_line := subsplits_file.get_line()
				if subsplit_line.is_empty():
					break
				
				var split := subsplit_line.split(",", true, 2)
				var split_name := split[0]
				var split_condition := split[1]
				splits.append({
					"name": split_name,
					"condition": split_condition,
					"section": section_name,
					"section_condition": section_condition
				})
			
			continue
		
		var split := line.split(",", true, 2)
		var split_name := split[0]
		var split_condition := split[1]
		splits.append({
			"name": split_name,
			"condition": split_condition
		})


func _on_title_edit_text_changed(new_text: String) -> void:
	livesplit_title = new_text
	
	title_changed.emit(new_text)


func _on_difficulty_select_item_selected(_index: int) -> void:
	category_changed.emit(get_category())


func _on_type_select_item_selected(index: int) -> void:
	const FRESH_FILE_ID := 0
	const IL_MIN_ID := 2
	
	if index == FRESH_FILE_ID:
		hdfs_select.button_pressed = false
		hdfs_select.disabled = true
	else:
		hdfs_select.disabled = false
	
	if index >= IL_MIN_ID:
		split_frequency_select.set_item_disabled(LiveSplit.SplitFrequency.EACH_QUEST, true)
		split_frequency_select.select(LiveSplit.SplitFrequency.EACH_STAGE)
	else:
		split_frequency_select.set_item_disabled(LiveSplit.SplitFrequency.EACH_QUEST, false)
	
	category_changed.emit(get_category())


func _on_hdfs_select_toggled(_button_pressed: bool) -> void:
	category_changed.emit(get_category())


func _on_version_select_item_selected(_index: int) -> void:
	category_changed.emit(get_category())


func _on_split_frequency_select_item_selected(index: int) -> void:
	split_frequency = index as LiveSplit.SplitFrequency
	
	split_frequency_changed.emit(index)


func _on_attempt_count_edit_text_changed(new_text: String) -> void:
	attempt_count_changed.emit(new_text.to_int())


func _on_attempt_count_edit_text_submitted(new_text: String) -> void:
	attempt_count_edit.text = str(new_text.to_int())


static func get_comparison_time_to_split(split_idx: int) -> float:
	var time := 0.0
	for i in split_idx:
		time += comparison[i]
	return time


static func load_best_times(of_category: Leaderboards.Category = category) -> void:
	best_times.clear()
	
	var path := "user://speedrunning/best"
	
	if of_category & Leaderboards.DOWNPATCHED:
		path = path.path_join("1.87")
	else:
		path = path.path_join("1.88+")
	
	if of_category & Leaderboards.FRESH_FILE:
		path = path.path_join("Fresh File")
	elif of_category & Leaderboards.HDFS:
		path = path.path_join("HDFS")
	else:
		path = path.path_join("No HDFS")
	
	if of_category & Leaderboards.IL.ENABLED:
		var level := Leaderboards.get_category_level(of_category)
		var key: String = Leaderboards.IL.find_key(level)
		
		var file_name := str(level & 0b110) + "-" + key.capitalize().replace("Respites", "Respite's")
		if LiveSplit.comparison_exists(file_name):
			best_times = LiveSplit.load_comparison(file_name, path)
		best_times.resize(10)
		return
	
	for level in Leaderboards.IL.values().filter(func(a: Leaderboards.IL): return a > Leaderboards.IL.ENABLED):
		var file_name: String = str(level & 0b110) + "-" + Leaderboards.IL.find_key(level).capitalize().replace("Respites", "Respite's")
		
		if LiveSplit.comparison_exists(file_name):
			best_times.append_array(LiveSplit.load_comparison(file_name, path))
		else:
			var empty_times := PackedFloat32Array()
			empty_times.resize(10)
			empty_times.fill(INF)
			best_times.append_array(empty_times)


static func save_best_times(to_category: Leaderboards.Category = category) -> void:
	var path := get_best_times_path(to_category)
	
	if to_category & Leaderboards.IL.ENABLED:
		LiveSplit.save_comparison(best_times, path.get_file().get_basename(), path.get_base_dir())
		return
	
	for i in int(best_times.size() / 10.0):
		var segment := best_times.slice(10 * i, 10 * (i + 1))
		var level := i << 1 + 1 as Leaderboards.IL
		var key: String = Leaderboards.IL.find_key(level)
		var file_name := str(i + 1) + "-" + key.capitalize().replace("Respites", "Respite's")
		LiveSplit.save_comparison(segment, file_name, path)


static func get_best_times_path(of_category: Leaderboards.Category = category) -> String:
	var path := "user://speedrunning/best"
	
	if of_category & Leaderboards.DOWNPATCHED:
		path = path.path_join("1.87")
	else:
		path = path.path_join("1.88+")
	
	if of_category & Leaderboards.FRESH_FILE:
		path = path.path_join("Fresh File")
	elif of_category & Leaderboards.HDFS:
		path = path.path_join("HDFS")
	else:
		path = path.path_join("No HDFS")
	
	match Leaderboards.get_category_level(of_category):
		Leaderboards.IL.DISABLED:
			return path
		Leaderboards.IL.GLORY_DAYS:
			return path.path_join("1-Glory Days")
		Leaderboards.IL.RESPITES_END:
			return path.path_join("2-Respite's End")
		Leaderboards.IL.ANOTHER_WAY:
			return path.path_join("3-Another Way")
		Leaderboards.IL.AROUND_THE_BEND:
			return path.path_join("4-Around The Bend")
		Leaderboards.IL.SHADOWMAN:
			return path.path_join("5-Shadowman")
	
	return path
