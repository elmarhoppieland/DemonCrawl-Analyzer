@tool
extends VBoxContainer
class_name TimeFilter

# ==============================================================================
@export_placeholder("<title>") var title := "" :
	set(value):
		title = value
		if not title_label:
			return
		if value.is_empty():
			title_label.text = "<title>"
		else:
			title_label.text = value
@export_enum("DD-MM-YYYY", "DD-MM-YY") var date_format := "DD-MM-YYYY" :
	set(value):
		date_format = value
		if not date_label:
			return
		if Engine.is_editor_hint():
			date_label.text = value
		else:
			date_label.text = current_date.date(value)
# ==============================================================================
var current_date: Date
var datetime_string := "YYYY-MM-DDTHH:MM:00"
# ==============================================================================
@onready var title_label: Label = %TitleLabel
@onready var calendar_button: TextureButton = %CalendarButton
@onready var date_label: Label = %DateLabel

@onready var time_selection: TimeSelection = %TimeSelection
# ==============================================================================
signal time_changed(new_time: String)
# ==============================================================================

func _ready() -> void:
	if title.is_empty():
		title_label.text = "<title>"
	else:
		title_label.text = title
	
	if not Engine.is_editor_hint():
		_date_selected(Calendar.get_date())


func set_time(time: String) -> void:
	time_selection.set_time(time)


func set_date(date_string: String) -> void:
	_date_selected(Date.new(date_string.get_slice("-", 2).to_int(), date_string.get_slice("-", 1).to_int(), date_string.get_slice("-", 0).to_int()))


## Returns the datetime [Dictionary] selected by the user.
## [br][br]If [code]weekday[/code] is [code]false[/code], then the weekday entry is excluded
## (the calculation is relatively expensive).
func get_datetime_dict(weekday: bool = false) -> Dictionary:
	return Time.get_datetime_dict_from_datetime_string(datetime_string, weekday)


func _date_selected(date: Date) -> void:
	current_date = date
	date_label.text = date.date(date_format)
	
	datetime_string = date.date("YYYY-MM-DD") + "T" + datetime_string.get_slice("T", 1)
	
	time_changed.emit(datetime_string)


func _on_time_selected(hours: int, minutes: int) -> void:
	if "HH" in datetime_string:
		datetime_string = datetime_string.replace("HH", str(hours).pad_zeros(2))
	else:
		datetime_string[11] = str(hours).pad_zeros(2)[0]
		datetime_string[12] = str(hours).pad_zeros(2)[1]
	
	if "MM" in datetime_string:
		datetime_string = datetime_string.replace("MM", str(hours).pad_zeros(2))
	else:
		datetime_string[14] = str(minutes).pad_zeros(2)[0]
		datetime_string[15] = str(minutes).pad_zeros(2)[1]
	
	time_changed.emit(datetime_string)
