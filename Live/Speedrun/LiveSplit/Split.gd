extends MarginContainer
class_name Split

# ==============================================================================
@export var ahead_gaining_color := Color.LIME_GREEN
@export var ahead_losing_color := Color.LIME_GREEN
@export var behind_gaining_color := Color.RED
@export var behind_losing_color := Color.RED
@export var gold_color := Color.GOLD
# ==============================================================================
var split_section: SplitSection

var time_before := 0.0

var split_index := -1
# ==============================================================================
@onready var split_name_label: Label = %SplitNameLabel
@onready var comparison_label: Label = %ComparisonLabel
@onready var time_label: Label = %TimeLabel
@onready var active_color_rect: ColorRect = %ActiveColorRect
# ==============================================================================

func _ready() -> void:
	split_name_label.text = name


func _set(property: StringName, value: Variant) -> bool:
	if property == "name":
		name = value
		if split_name_label:
			split_name_label.text = value
	
	return true


func with(property: StringName, value: Variant) -> Split:
	set(property, value)
	return self


func with_split_section(_split_section: SplitSection) -> Split:
	split_section = _split_section
	return self


func with_split_index(idx: int) -> Split:
	split_index = idx
	return self


func activate() -> void:
	active_color_rect.show()
	
	time_before = LiveSplit.timer
	
	if split_section:
		split_section.open()


func deactivate() -> void:
	active_color_rect.hide()
	
	var split_time := LiveSplit.timer - time_before
	
	time_label.text = LiveSplit.get_time_string(LiveSplit.timer)
	
	LiveSplit.split_times.append(split_time)
	
	if LiveSplitEditor.comparison.is_empty():
		comparison_label.text = "-"
		if LiveSplitEditor.best_times[split_index] > split_time:
			comparison_label.label_settings.font_color = gold_color
		else:
			comparison_label.label_settings.font_color = Color.WHITE
	else:
		var offset := LiveSplit.timer - LiveSplitEditor.get_comparison_time_to_split(split_index + 1)
		if offset < 0:
			comparison_label.text = "-"
			if split_time < LiveSplitEditor.comparison[split_index]:
				comparison_label.label_settings.font_color = ahead_gaining_color
			else:
				comparison_label.label_settings.font_color = ahead_losing_color
		else:
			comparison_label.text = "+"
			if split_time < LiveSplitEditor.comparison[split_index]:
				comparison_label.label_settings.font_color = behind_gaining_color
			else:
				comparison_label.label_settings.font_color = behind_losing_color
		
		if split_time < LiveSplitEditor.best_times[split_index]:
			comparison_label.label_settings.font_color = gold_color
			LiveSplitEditor.best_times[split_index] = split_time
		
		comparison_label.text += LiveSplit.get_time_string(absf(offset), 1)
	
	if split_section:
		split_section.close()


func reset() -> void:
	active_color_rect.hide()
	
	comparison_label.text = ""
	time_label.text = "-"
	
	if split_section:
		split_section.close()
