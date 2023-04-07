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
# ==============================================================================
@onready var title_label: Label = %TitleLabel
@onready var calendar_button: TextureButton = %CalendarButton
@onready var date_label: Label = %DateLabel
# ==============================================================================

func _ready() -> void:
	if title.is_empty():
		title_label.text = "<title>"
	else:
		title_label.text = title
	
	if not Engine.is_editor_hint():
		date_label.text = Calendar.get_date().date(date_format)


func _date_selected(date: Date) -> void:
	current_date = date
	date_label.text = date.date(date_format)
