extends PanelContainer
class_name Live

# ==============================================================================
const SELECTED_PROFILE_TEXT := "Selected Profile: %s"
const NO_QUEST_TEXT := "No Quest Started"
const NOT_RUNNING_TEXT := "DemonCrawl is not running"
const QUEST_TEXT := "%s on %s"
# ==============================================================================
var selected_quest: Quest

var selected_profile := ""

var last_stage: Stage

var previous_log_file_length := 0

var live_stage_minimum_height := 250.0
# ==============================================================================
@onready var main_label: Label = %MainLabel
@onready var profile_label: Label = %ProfileLabel
@onready var live_stage_container: HBoxContainer = %LiveStageContainer
@onready var scroll_extender_left: Control = %ScrollExtenderLeft
@onready var scroll_extender_right: Control = %ScrollExtenderRight
# ==============================================================================

func _ready() -> void:
	resize_live_stages()
	get_window().size_changed.connect(resize_live_stages)
	
	check()
	get_window().focus_entered.connect(check)
	
	if ResourceLoader.load_threaded_get_status("res://Main/Main2.tscn") == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		ResourceLoader.load_threaded_request("res://Main/Main2.tscn")


func _process(_delta: float) -> void:
	scroll_extender_left.custom_minimum_size.x = get_window().size.x / 2.0 - live_stage_minimum_height / 2 - 16
	scroll_extender_right.custom_minimum_size.x = get_window().size.x / 2.0 - live_stage_minimum_height / 2 - 16


func check() -> void:
	if not DemonCrawl.is_running():
		main_label.text = NOT_RUNNING_TEXT
		profile_label.hide()
		return
	
	profile_label.show()
	if not selected_quest:
		main_label.text = NO_QUEST_TEXT
	
	var settings_file := DemonCrawl.open_settings_file()
	var log_file := DemonCrawl.open_log_file(DemonCrawl.get_logs_count())
	
	selected_profile = settings_file.get_value("player", "name")
	
	profile_label.text = SELECTED_PROFILE_TEXT % selected_profile
	
	if not log_file:
		return
	
	if log_file.get_length() == previous_log_file_length:
		return
	
	log_file.seek_end()
	var pos := log_file.get_position()
	while pos > 0:
		pos -= 1
		log_file.seek(pos)
		var character := log_file.get_8()
		if char(character) == "\n":
			break
	
	if log_file.get_line().match("*DemonCrawl closed"):
		# this file is not of the current game
		log_file = null
		return
	
	log_file.seek(previous_log_file_length)
	previous_log_file_length = log_file.get_length()
	
	analyze_log_file(log_file)


func analyze_log_file(log_file: FileAccess) -> void:
	while true:
		var line := log_file.get_line()
		if line.is_empty():
			break
		
		var line_trimmed := line.get_slice("] ", 1).trim_prefix("Alert: ")
		
		var type := LogFileReader.get_line_type(line)
		
		match type:
			LogFileReader.Line.QUEST_ABORT:
				selected_quest = null
				for child in live_stage_container.get_children():
					if not child in [scroll_extender_left, scroll_extender_right]:
						child.queue_free()
			LogFileReader.Line.QUEST_CREATE:
				selected_quest = Live.create_quest(line)
				main_label.text = QUEST_TEXT % [selected_quest.name, Quest.Difficulty.find_key(selected_quest.type % 4).capitalize()]
			LogFileReader.Line.MASTERY_SELECTED:
				selected_quest.mastery = line_trimmed.trim_prefix("Mastery selected: ").get_slice(" tier ", 0)
				selected_quest.mastery_tier = line_trimmed.to_int() as Quest.MasteryTier
			LogFileReader.Line.STAGE_BEGIN:
				last_stage = Stage.new().with_name(line_trimmed.trim_prefix("Begin stage "))
				
				selected_quest.stages.append(last_stage)
				selected_quest.in_stage = true
			LogFileReader.Line.STAGE_FINISH:
				last_stage.time_spent = line_trimmed.get_slice(" in ", 1)
			LogFileReader.Line.STAGE_LEAVE:
				selected_quest.in_stage = false
			LogFileReader.Line.CHEST_OPENED:
				last_stage.chests_opened += 1
			LogFileReader.Line.ARTIFACT_COLLECTED:
				last_stage.artifacts_collected += 1
			LogFileReader.Line.LIVES_RESTORED:
				last_stage.lives_restored += line_trimmed.get_slice(" ", 0).to_int()
			LogFileReader.Line.COINS_GAINED:
				last_stage.coins_gained += line_trimmed.to_int()
			LogFileReader.Line.COINS_SPENT:
				last_stage.coins_spent += line_trimmed.get_slice(" ", 0).to_int()
			LogFileReader.Line.POINTS_GAINED:
				last_stage.points_gained += line_trimmed.get_slice(" ", 1).to_int()
				
				if selected_quest.stages.size() == 1:
					scroll_extender_left.hide()
					scroll_extender_right.hide()
				else:
					scroll_extender_left.show()
					scroll_extender_right.show()
				
				var live_stage := preload("res://Live/LiveStage.tscn").instantiate()
				live_stage.stage = last_stage
				live_stage.custom_minimum_size = Vector2(live_stage_minimum_height, live_stage_minimum_height)
				live_stage_container.add_child(live_stage)
				live_stage_container.move_child(live_stage, -2)


func resize_live_stages() -> void:
	live_stage_minimum_height = get_window().size.y - 150
	for node in live_stage_container.get_children():
		if node in [scroll_extender_left, scroll_extender_right]:
			continue
		node.custom_minimum_size = Vector2(live_stage_minimum_height, live_stage_minimum_height)


static func create_quest(line: String) -> Quest:
	var line_trimmed := line.get_slice("] ", 1).trim_prefix("Alert: ")
	
	var quest := Quest.new()
	
	quest.name = line_trimmed.get_slice("Quest started: ", 1).get_slice(" on ", 0)
	quest.type = Quest.Type[quest.name.to_upper().replace(" ", "_").replace("'", "")] | line_trimmed.to_int()
	quest.creation_timestamp = line.get_slice("] ", 0).trim_prefix("[")
	
	return quest


func _on_back_button_pressed() -> void:
	SceneHandler.switch_scene(ResourceLoader.load_threaded_get("res://Main/Main2.tscn"))
