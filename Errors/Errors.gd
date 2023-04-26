extends Control
class_name Errors

# ==============================================================================
const ERROR_MESSAGE := preload("res://Errors/ErrorMessage.tscn")
# ==============================================================================
var load_thread := Thread.new()
# ==============================================================================
@onready var main: Statistics = owner
@onready var flow_container: HFlowContainer = %HFlowContainer
# ==============================================================================

func _ready() -> void:
	load_thread.start(populate)


func _process(_delta: float) -> void:
	if load_thread.is_started() and not load_thread.is_alive():
		load_thread.wait_to_finish()


func populate() -> void:
	var errors := ProfileLoader.errors.duplicate()
	errors.reverse() # make sure the most recent error is the first one in the list
	for error in errors:
		var message_instance := ERROR_MESSAGE.instantiate()
		flow_container.add_child(message_instance)
		
		message_instance.error_code = error.code
		message_instance.error_info = error.info
		message_instance.error_message = error.long_message
		message_instance.error_stack_trace = error.stack_trace
		message_instance.error_date = error.date


func _exit_tree() -> void:
	if load_thread.is_started():
		load_thread.wait_to_finish()
