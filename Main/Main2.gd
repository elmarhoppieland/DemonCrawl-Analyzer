extends Control
class_name Main2

# ==============================================================================
const RUNNING_CHECK_DELTA := 0.25
# ==============================================================================
@onready var run_game_button: Button = %RunGameButton
@onready var analyze_live_button: Button = %AnalyzeLiveButton
@onready var view_history_button: Button = %ViewHistoryButton
@onready var open_wiki_button: Button = %OpenWikiButton
@onready var settings_button: Button = %SettingsButton
@onready var progress_bar: ProgressBar = %ProgressBar
# ==============================================================================

func _ready() -> void:
	_check_running_cycle(RUNNING_CHECK_DELTA)
	
	HistoryLoader.load_history().progress_updated.connect(func(progress: int):
		progress_bar.value = progress
	)
	progress_bar.max_value = HistoryLoader.get_progress().max_progress
	HistoryLoader.get_progress().max_progress_updated.connect(func(max_progress: int):
		progress_bar.max_value = max_progress
	)


func _check_running_cycle(cycle_length: float) -> void:
	var thread := AutoThread.new(self)
	var expectation := not run_game_button.visible
	thread.start_execution(func():
		if expectation:
			if not DemonCrawl.is_running():
				run_game_button.show.call_deferred()
				analyze_live_button.hide.call_deferred()
		else:
			if DemonCrawl.is_running():
				run_game_button.hide.call_deferred()
				analyze_live_button.show.call_deferred()
	)
	
	await thread.finished
	
	await get_tree().create_timer(cycle_length).timeout
	
	_check_running_cycle(cycle_length)


func _on_run_game_button_pressed() -> void:
	DemonCrawl.run()
	run_game_button.hide()
	analyze_live_button.show()
	
	analyze_live_button.disabled = true
	
	while not DemonCrawl.is_running():
		await get_tree().create_timer(0.1).timeout
	
	analyze_live_button.disabled = false


func _on_open_wiki_button_pressed() -> void:
	DemonCrawlWiki.open()


func _on_analyze_live_button_pressed() -> void:
	SceneHandler.switch_scene(preload("res://Live/Live.tscn"))
