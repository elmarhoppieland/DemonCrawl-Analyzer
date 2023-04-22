extends CanvasLayer

# ==============================================================================
const BUTTON_TEXT_FIRST_LAUNCH := "Initialize Analyzer"
const LABEL_TEXT_FIRST_LAUNCH := "No analyzed data was found."
const BUTTON_TEXT_UPDATE := "Update Analyzed Data"
const LABEL_TEXT_UPDATE := "Analyzed data is from an earlier Analyzer version."
const LABEL_TEXT_NEW_DATA := "New data can be retrieved."
const BUTTON_TEXT_UP_TO_DATE := "Analyze DemonCrawl History"
const LABEL_TEXT_UP_TO_DATE := "Analyzed data is up to date."
# ==============================================================================
@onready var button: Button = %Button
@onready var save_status_label: Label = %SaveStatusLabel
@onready var version_label: Label = %VersionLabel
# ==============================================================================

func _ready() -> void:
	_initialize_button_text()
	
	version_label.text %= Analyzer.get_version()
	if OS.is_debug_build():
		version_label.text += " (DEBUG)"


func _initialize_button_text() -> void:
	if Analyzer.is_first_launch():
		button.text = BUTTON_TEXT_FIRST_LAUNCH
		save_status_label.text = LABEL_TEXT_FIRST_LAUNCH
		return
	
	match Analyzer.get_data_status():
		Analyzer.DataStatus.OUTDATED_VERSION:
			button.text = BUTTON_TEXT_UPDATE
			save_status_label.text = LABEL_TEXT_UPDATE
		Analyzer.DataStatus.NEW_DATA_FOUND:
			button.text = BUTTON_TEXT_UP_TO_DATE
			save_status_label.text = LABEL_TEXT_NEW_DATA
		Analyzer.DataStatus.UP_TO_DATE:
			button.text = BUTTON_TEXT_UP_TO_DATE
			save_status_label.text = LABEL_TEXT_UP_TO_DATE


func _on_button_pressed() -> void:
	SceneHandler.switch_scene(preload("res://Statistics/Statistics.tscn"))
