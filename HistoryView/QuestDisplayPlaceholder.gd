extends Control
class_name QuestDisplayPlaceholder

# ==============================================================================
static var scene: PackedScene
# ==============================================================================
@export var border_width := 4
@export var border_visible := true
@export var background_color := Color(0.6, 0.6, 0.6)
@export var stage_name := ""
@export_group("Quest", "quest_")
@export var quest_type := Quest.Type.GLORY_DAYS
@export var quest_difficulty := Quest.Difficulty.NORMAL
# ==============================================================================

func load_instance() -> void:
	var quest_display := QuestDisplay.instantiate()
	
	quest_display.border_width = border_width
	quest_display.background_color = background_color
	quest_display.stage_name = stage_name
	
	quest_display.quest_type = quest_type
	quest_display.quest_difficulty = quest_difficulty
	
	quest_display.custom_minimum_size = custom_minimum_size
	
	add_sibling.call_deferred(quest_display)
	
	queue_free()


static func instantiate() -> QuestDisplayPlaceholder:
	if not scene:
		scene = load("res://HistoryView/QuestDisplayPlaceholder.tscn")
	
	return scene.instantiate()
