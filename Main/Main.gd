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
# ==============================================================================

func _ready() -> void:
	if Analyzer.is_first_launch():
		button.text = BUTTON_TEXT_FIRST_LAUNCH
		save_status_label.text = LABEL_TEXT_FIRST_LAUNCH
		return
	
	var file := Analyzer.open_savedata_file(-1)
	var json = JSON.parse_string(file.get_as_text())
	
	if json is Dictionary:
		if "version" in json:
			var version: String = json.version
			if version != Analyzer.CURRENT_VERSION:
				button.text = BUTTON_TEXT_UPDATE
				save_status_label.text = LABEL_TEXT_UPDATE
				return
		if "start_unix" in json:
			var start_unix_json: int = json.start_unix
			var log_file := DemonCrawl.open_log_file(DemonCrawl.get_logs_count())
			var start_unix_log := TimeHelper.get_unix_time_from_timestamp(log_file.get_line().get_slice("]", 0).trim_prefix("["))
			if start_unix_json != start_unix_log:
				save_status_label.text = LABEL_TEXT_NEW_DATA
				return
		
		button.text = BUTTON_TEXT_UP_TO_DATE
		save_status_label.text = LABEL_TEXT_UP_TO_DATE


func _on_button_pressed() -> void:
	SceneHandler.switch_scene(preload("res://Statistics/Statistics.tscn"))
