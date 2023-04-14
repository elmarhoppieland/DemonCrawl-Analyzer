@tool
extends HBoxContainer
class_name TimeSelection

# ==============================================================================
@export_enum("24h", "12h") var type := 0 :
	set(value):
		type = value
		type_selector.select(value)
		period_selector.visible = value == 1
		time_hour = time_hour # call the setter
@export_enum("AM", "PM") var period := 0 :
	set(value):
		period = value
		period_selector.select(value)
@export var can_specify_type := true :
	set(value):
		can_specify_type = value
		type_selector.visible = value
@export_group("Time", "time_")
@export var time_hour := 0 :
	set(value):
		time_hour = value % (12 * (2 - type))
		if type == 1 and time_hour == 0:
			time_hour = 12
		
		update_time_edit()
@export var time_minute := 0 :
	set(value):
		time_minute = value % 60
		update_time_edit()
# ==============================================================================
@onready var time_edit: LineEdit = $TimeEdit
@onready var period_selector: OptionButton = $PeriodSelector
@onready var type_selector: OptionButton = $TypeSelector
# ==============================================================================
signal time_selected(hours: int, minutes: int)
# ==============================================================================

func _ready() -> void:
	update_time_edit()
	
	var hour := time_hour
	var minute := time_minute
	
	if type == 1 and hour == 12:
		hour = 0
	
	if type == 1 and period == 1:
		hour += 12
	
	time_selected.emit(hour, minute)


func set_time(time: String) -> void:
	time_edit.text = time
	time_edit.text_submitted.emit(time)


## Returns the selected time in 24h format.
func get_time() -> String:
	var hour := time_hour
	var minute := time_minute
	
	if type == 1 and hour == 12:
		hour = 0
	
	if type == 1 and period == 1:
		hour += 12
	
	var time := "%02d:%02d" % [hour, minute]
	
	return time


## Updates the [member time_edit] to show the selected time.
func update_time_edit() -> void:
	if time_edit:
		time_edit.text = "%02d:%02d" % [time_hour, time_minute] 


func _on_line_edit_text_submitted(new_text: String) -> void:
	if not ":" in new_text:
		update_time_edit()
		return
	
	var split := new_text.split(":")
	time_hour = split[0].to_int()
	time_minute = split[1].to_int()
	
	var hour := time_hour
	var minute := time_minute
	
	if type == 1 and hour == 12:
		hour = 0
	
	if type == 1 and period == 1:
		hour += 12
	
	time_selected.emit(hour, minute)


func _on_type_selector_item_selected(index: int) -> void:
	type = index


func _on_period_selector_item_selected(index: int) -> void:
	period = index
