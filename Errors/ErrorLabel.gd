@tool
extends Label
class_name ErrorLabel

# ==============================================================================
const ERROR_TEMPLATE := "%s
%s
___
#####################################################
ERROR in
%s
#####################################################
%s"
# ==============================================================================
@export_group("Error", "error_")
@export var error_code := "" :
	set(value):
		error_code = value
		regenerate_error()
@export var error_info: PackedStringArray = [] :
	set(value):
		error_info = value
		regenerate_error()
@export_multiline var error_message := "" :
	set(value):
		error_message = value
		regenerate_error()
@export var error_short_message := "" :
	set(value):
		error_short_message = value
		regenerate_error()
@export var error_stack_trace: PackedStringArray = [] :
	set(value):
		error_stack_trace = value
		regenerate_error()
# ==============================================================================

func regenerate_error() -> void:
	text = ERROR_TEMPLATE % [error_code, "\n".join(error_info), error_message, "\n".join(error_stack_trace)]
