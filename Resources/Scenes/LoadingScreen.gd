extends PopupPanel

# ==============================================================================
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var message_label: Label = %MessageLabel
# ==============================================================================
signal finished()
# ==============================================================================

func start(step_count: int, start_message: String) -> void:
	progress_bar.max_value = step_count
	progress_bar.value = 0
	
	message_label.text = start_message
	
	popup_centered()


func set_message(message: String) -> void:
	message_label.text = message


func set_step_count(step_count: int, reset_value: bool = false) -> void:
	progress_bar.max_value = step_count
	if reset_value:
		progress_bar.value = 0


func progress_increment() -> void:
	progress_bar.value += 1
	if progress_bar.value >= progress_bar.max_value:
		progress_finish()


func progress_set(step: int) -> void:
	progress_bar.value = step
	if progress_bar.value >= progress_bar.max_value:
		progress_finish()


func progress_finish() -> void:
	finished.emit()
	hide()
