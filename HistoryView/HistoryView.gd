extends Control
class_name HistoryView

# ==============================================================================
@export var profile := "Bolghro151"
# ==============================================================================
@onready var xp_bar: TextureProgressBar = %XpBar
@onready var profile_icon: TextureRect = %ProfileIcon
@onready var recent_quests_container: VBoxContainer = %RecentQuestsContainer
# ==============================================================================

func _ready() -> void:
	Packages.call_method("load_history_view", [profile])
	
	build_recent_quests_list()
	
	ResourceLoader.load_threaded_request("res://Main/Main2.tscn")


func build_recent_quests_list() -> void:
	Packages.call_method("build_recent_quests_list", [profile])
	
	var quests := get_recent_quests_list()
	
	for quest in quests:
		const HEIGHT := 128
		
		var instance := QuestDisplay.instantiate()
		instance.stage_name = quest.background_stage_name
		instance.quest_type = quest.type
		instance.quest_difficulty = quest.difficulty
		instance.custom_minimum_size.y = HEIGHT
		
		recent_quests_container.add_child(instance)


func get_recent_quests_list() -> Array[QuestData]:
	var r := Packages.call_method("get_recent_quests_list", [profile])
	
	var quests: Array[QuestData] = []
	var unix_timestamps: PackedInt32Array = []
	for value in r:
		if not value is Array:
			continue
		for data in value:
			if not data is Dictionary:
				continue
			if not "start_unix_time" in data:
				continue
			if data.start_unix_time in unix_timestamps:
				continue
			
			unix_timestamps.append(data.start_unix_time)
			
			if "exclude" in data and data.exclude:
				continue
			
			quests.append(QuestData.from_dict(data))
	
	quests.sort_custom(func(a: QuestData, b: QuestData): return a.start_unix_time > b.start_unix_time)
	
	return quests


func build_profile_miniview() -> void:
	Packages.call_method("build_profile_miniview", [profile])
	
	var icon: Texture2D = Packages.get_single_return_value("get_profile_icon", TYPE_OBJECT, [profile])
	if icon:
		profile_icon.texture = icon
	
	var max_xp: int = Packages.get_single_return_value("get_profile_max_xp", TYPE_INT, [profile])
	if max_xp > 0:
		xp_bar.max_value = max_xp
	
	var xp: int = Packages.get_single_return_value("get_profile_xp", TYPE_INT, [profile])
	if xp >= 0:
		xp_bar.value = xp


class QuestData extends RefCounted:
	var type := Quest.Type.GLORY_DAYS
	var difficulty := Quest.Difficulty.NORMAL
	var background_stage_name := ""
	var start_unix_time := -1
	
	
	static func from_dict(dict: Dictionary) -> QuestData:
		var data := QuestData.new()
		
		if "type" in dict:
			data.type = dict.type
		if "difficulty" in dict:
			data.difficulty = dict.difficulty
		if "start_unix_time" in dict:
			data.start_unix_time = dict.start_unix_time
		if "background_stage_name" in dict:
			data.background_stage_name = dict.background_stage_name
		
		return data


func _on_back_button_pressed() -> void:
	SceneHandler.switch_scene(ResourceLoader.load_threaded_get("res://Main/Main2.tscn"))
