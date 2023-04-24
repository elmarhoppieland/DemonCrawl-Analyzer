extends Control
class_name Errors

# ==============================================================================
const ERROR_MESSAGE := preload("res://Errors/ErrorMessage.tscn")
# ==============================================================================
@onready var main: Statistics = owner
@onready var flow_container: HFlowContainer = %HFlowContainer
# ==============================================================================

func _ready() -> void:
	populate()


func populate() -> void:
	var errors := main.errors.duplicate()
	errors.reverse() # make sure the most recent error is the first one in the list
	for error in errors:
		var message_instance := ERROR_MESSAGE.instantiate()
		flow_container.add_child(message_instance)
		
		message_instance.error_code = error.code
		message_instance.error_info = error.info
		message_instance.error_message = error.long_message
		message_instance.error_stack_trace = error.stack_trace
		message_instance.error_date = error.date
