extends PanelContainer
class_name Splits

# ==============================================================================
const SPLIT_HEIGHT := 26.0
const SPLIT_SEPERATION := 4.0
const MIN_SPLITS_COUNT := 5

const TIMER_LABEL_TEXT := "[right][font_size=48]%s[/font_size][font_size=32].%02d[/font_size]"
# ==============================================================================
var subsplits_enabled := false

var splits: Array[Split] = []
# ==============================================================================
@onready var title_label: Label = %TitleLabel
@onready var category_label: Label = %CategoryLabel
@onready var attempt_counter: Label = %AttemptCounter
@onready var splits_scroll_container: ScrollContainer = %SplitsScrollContainer
@onready var splits_container: VBoxContainer = %SplitsContainer
@onready var return_instructions: Label = %ReturnInstructions
@onready var timer_label: RichTextLabel = %TimerLabel
# ==============================================================================

func _ready() -> void:
	splits_scroll_container.custom_minimum_size.y = MIN_SPLITS_COUNT * (SPLIT_HEIGHT + SPLIT_SEPERATION) - SPLIT_SEPERATION


func scroll_to_split(idx: int) -> void:
	var index := 0
	var split_count := 0
	while true:
		var child := splits_container.get_child(index)
		if child is Split:
			if split_count == idx:
				break
			index += 1
			split_count += 1
			continue
		if not child.is_open():
			index += 1
			split_count += 1
			idx -= child.get_subsplit_count()
			continue
		
		split_count = index + idx + 1
		break
	
	splits_scroll_container.scroll_vertical = int(SPLIT_HEIGHT + SPLIT_SEPERATION) * (split_count - 2)


func get_split(idx: int) -> Split:
	if true: return splits[idx]
	############################
	
	if not subsplits_enabled:
		return splits_container.get_child(idx)
	
	var split_count := 0
	for child in splits_container.get_children():
		if child is Split:
			if split_count == idx:
				return child
			split_count += 1
			continue
		
		# the child is a SplitSection
		var new_split_count: int = split_count + child.get_subsplit_count()
		if new_split_count > idx:
			return child.get_subsplit(idx - split_count)
		
		split_count = new_split_count
	
	return null


func get_split_count() -> int:
	if not subsplits_enabled:
		return splits_container.get_child_count()
	
	var split_count := 0
	for child in splits_container.get_children():
		if child is Split:
			split_count += 1
			continue
		split_count += child.get_subsplit_count()
	
	return split_count


func set_timer(time: float) -> void:
	timer_label.text = TIMER_LABEL_TEXT % [LiveSplit.get_time_string(int(time), 0), fmod(time, 1) * 100]


func set_title(new_title: String) -> void:
	title_label.text = new_title


func set_category(new_category: Leaderboards.Category, update_splits: bool = false, split_frequency: LiveSplit.SplitFrequency = LiveSplit.SplitFrequency.EACH_STAGE, open_sections: bool = false) -> void:
	category_label.text = Leaderboards.get_category_name(new_category)
	if new_category & Leaderboards.IL.AROUND_THE_BEND:
		category_label.text = category_label.text.replace("Random", "R.")
	
	if not update_splits:
		return
	
	match split_frequency:
		LiveSplit.SplitFrequency.EACH_QUEST:
			load_splits("res://Live/Speedrun/Splits/0-AllQuests.dcsl", open_sections)
		LiveSplit.SplitFrequency.EACH_STAGE:
			if new_category & Leaderboards.IL.ENABLED:
				match Leaderboards.get_category_level(new_category):
					Leaderboards.IL.GLORY_DAYS:
						load_splits("res://Live/Speedrun/Splits/1-GloryDaysStages.dcsl", open_sections)
					Leaderboards.IL.RESPITES_END:
						load_splits("res://Live/Speedrun/Splits/2-RespitesEndStages.dcsl", open_sections)
					Leaderboards.IL.ANOTHER_WAY:
						load_splits("res://Live/Speedrun/Splits/3-AnotherWayStages.dcsl", open_sections)
					Leaderboards.IL.AROUND_THE_BEND:
						load_splits("res://Live/Speedrun/Splits/4-AroundTheBendStages.dcsl", open_sections)
					Leaderboards.IL.SHADOWMAN:
						load_splits("res://Live/Speedrun/Splits/5-ShadowmanStages.dcsl", open_sections)
			else:
				load_splits("res://Live/Speedrun/Splits/0-AllQuestsStages.dcsl", open_sections)


func set_attempt_count(count: int) -> void:
	LiveSplit.attempt_count = count
	
	attempt_counter.text = str(count)


func load_splits(file_path: String, open_sections: bool = false) -> void:
	subsplits_enabled = false
	
	match file_path.get_extension():
		"lss":
			for child in splits_container.get_children():
				child.queue_free()
			
			await get_tree().process_frame
			
			_load_splits_from_lss(file_path, open_sections)
		"dcsl":
			for child in splits_container.get_children():
				child.queue_free()
			
			await get_tree().process_frame
			
			_load_splits_from_dcsl(file_path, open_sections)
		_:
			push_error("Cannot load splits from '%s'; incompatible extension" % file_path)
			return


func _load_splits_from_lss(_file_path: String, _open_sections: bool = false) -> void:
	pass


func _load_splits_from_dcsl(file_path: String, open_sections: bool = false) -> void:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Could not open file '%s': %s" % [file_path, error_string(FileAccess.get_open_error())])
		return
	
	var split_count := 0
	while true:
		var line := file.get_line()
		if line.is_empty():
			return
		
		if line.match("[*]{*},*"):
			var section := preload("res://Live/Speedrun/LiveSplit/SplitSection.tscn").instantiate()
			section.start_split_index = split_count
			section.name = line.get_slice("]", 0).trim_prefix("[")
			
			splits_container.add_child(section)
			
			var subsplits_file_path := line.get_slice("{", 1).get_slice("}", 0)
			if not subsplits_file_path.is_empty():
				_load_subsplits_from_dcsl(subsplits_file_path, section)
			
			if open_sections:
				section.open()
			
			split_count += section.get_subsplit_count()
			continue
		
		var split := preload("res://Live/Speedrun/LiveSplit/Split.tscn").instantiate()
		split.name = line.get_slice(",", 0)
		split.split_index = split_count
		splits.append(split)
		
		splits_container.add_child(split)
		
		split_count += 1


func _load_subsplits_from_dcsl(file_path: String, section: SplitSection) -> void:
	subsplits_enabled = true
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Could not open file '%s': %s" % [file_path, error_string(FileAccess.get_open_error())])
		return
	
	var index := 0
	while true:
		var line := file.get_line()
		if line.is_empty():
			return
		
		var split := preload("res://Live/Speedrun/LiveSplit/Split.tscn").instantiate()
		split.name = line.get_slice(",", 0)
		split.split_index = index
		
		splits.append(split)
		
		section.add_subsplit(split)
		
		index += 1
