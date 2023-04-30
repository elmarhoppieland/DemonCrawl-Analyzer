@tool
extends MarginContainer
class_name ErrorMessage

# ==============================================================================
@export_group("Error", "error_")
@export var error_code := "" :
	set(value):
		error_code = value
		if error_label:
			error_label.error_code = value
@export var error_info: PackedStringArray = [] :
	set(value):
		error_info = value
		if error_label:
			error_label.error_info = value
@export_multiline var error_message := "" :
	set(value):
		error_message = value
		if error_label:
			error_label.error_message = value
@export var error_stack_trace: PackedStringArray = [] :
	set(value):
		error_stack_trace = value
		if error_label:
			error_label.error_stack_trace = value
@export_placeholder("YYYY-MM-DD @ HH-MM-SS") var error_date := "" :
	set(value):
		error_date = value
		if date_label:
			date_label.text = "YYYY-MM-DD @ HH-MM-SS" if value.is_empty() else value
# ==============================================================================
@onready var error_label: ErrorLabel = %ErrorLabel
@onready var date_label: Label = %DateLabel
# ==============================================================================

func _ready() -> void:
	error_label.error_code = error_code
	error_label.error_info = error_info
	error_label.error_message = error_message
	error_label.error_stack_trace = error_stack_trace
	date_label.text = error_date


func _on_button_pressed() -> void:
	DisplayServer.clipboard_set(error_label.text)
