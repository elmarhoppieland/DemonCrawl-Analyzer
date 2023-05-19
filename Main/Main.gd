extends CanvasLayer
class_name Main

# ==============================================================================
enum LaunchMethod {
	NORMAL = -1,
	REPARSE,
	FREEZE,
	BLOCKING
}
# ==============================================================================
const BUTTON_TEXT_FIRST_LAUNCH := "Initialize Analyzer"
const LABEL_TEXT_FIRST_LAUNCH := "No analyzed data was found."
const BUTTON_TEXT_UPDATE := "Update Analyzed Data"
const LABEL_TEXT_UPDATE := "Analyzed data is from an earlier Analyzer version."
const LABEL_TEXT_NEW_DATA := "New data can be retrieved."
const BUTTON_TEXT_UP_TO_DATE := "Analyze DemonCrawl History"
const LABEL_TEXT_UP_TO_DATE := "Analyzed data is up to date."
# ==============================================================================
var load_thread := Thread.new()
# ==============================================================================
@onready var start_button: Button = %StartButton
@onready var save_status_label: Label = %SaveStatusLabel
@onready var version_label: Label = %VersionLabel
@onready var force_update_button: Button = %ForceUpdateButton
@onready var launch_options: ItemList = %LaunchOptions
# ==============================================================================

func _ready() -> void:
	_initialize_button_text()
	
	version_label.text %= Analyzer.get_version()
	if OS.is_debug_build():
		version_label.text += " (DEBUG)"
	else:
		force_update_button.hide()
	
	launch_options.hide()


func launch(method: LaunchMethod) -> void:
	if not load_thread.is_started():
		match method:
			LaunchMethod.NORMAL:
				load_thread.start(ProfileLoader.load_profiles)
			LaunchMethod.REPARSE:
				load_thread.start(ProfileLoader.update_profiles)
			LaunchMethod.FREEZE:
				load_thread.start(ProfileLoader.load_profiles.bind(true))
			LaunchMethod.BLOCKING:
				ProfileLoader.load_profiles()
	
	while load_thread.is_alive():
		await get_tree().process_frame
	
	load_thread.wait_to_finish()
	SceneHandler.switch_scene(preload("res://Statistics/Statistics.tscn"))


func _initialize_button_text() -> void:
	if Analyzer.is_first_launch():
		start_button.text = BUTTON_TEXT_FIRST_LAUNCH
		save_status_label.text = LABEL_TEXT_FIRST_LAUNCH
		return
	
	match Analyzer.get_data_status():
		Analyzer.DataStatus.OUTDATED_VERSION:
			start_button.text = BUTTON_TEXT_UPDATE
			save_status_label.text = LABEL_TEXT_UPDATE
		Analyzer.DataStatus.NEW_DATA_FOUND:
			start_button.text = BUTTON_TEXT_UP_TO_DATE
			save_status_label.text = LABEL_TEXT_NEW_DATA
		Analyzer.DataStatus.UP_TO_DATE:
			start_button.text = BUTTON_TEXT_UP_TO_DATE
			save_status_label.text = LABEL_TEXT_UP_TO_DATE


func _on_button_pressed() -> void:
	launch(LaunchMethod.NORMAL)


func _exit_tree() -> void:
	if load_thread.is_started():
		load_thread.wait_to_finish()


func _on_force_update_button_pressed() -> void:
	load_thread.start(ProfileLoader.update_profiles)


func _on_launch_options_item_selected(index: LaunchMethod) -> void:
	launch(index)
