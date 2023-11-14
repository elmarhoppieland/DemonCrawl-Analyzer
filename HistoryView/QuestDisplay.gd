@tool
extends MarginContainer
class_name QuestDisplay

# ==============================================================================
const QUEST_TEXT := "%s on %s"
# ==============================================================================
static var scene: PackedScene
# ==============================================================================
@export var border_width := 4 :
	set(value):
		border_width = value
		if not border_visible:
			return
		if not panel:
			await ready
		
		var style_box := panel.get_theme_stylebox("panel") as StyleBoxFlat
		style_box.set_border_width_all(value)
		style_box.set_expand_margin_all(value)
@export var border_visible := true :
	set(value):
		border_visible = value
		if not panel:
			await ready
		
		var style_box := panel.get_theme_stylebox("panel") as StyleBoxFlat
		style_box.set_border_width_all(border_width * int(value))
		style_box.set_expand_margin_all(border_width * int(value))
@export var background_color := Color(0.6, 0.6, 0.6) :
	set(value):
		background_color = value
		if not panel:
			await ready
		
		var style_box := panel.get_theme_stylebox("panel") as StyleBoxFlat
		style_box.bg_color = value
@export var stage_name := "" :
	set(value):
		stage_name = value
		
		if not stage_background_rect:
			await ready
		
		stage_background_rect.texture = null
		
		if value.begins_with("$"):
			stage_background_rect.texture = await DemonCrawl.get_quest_bg(value.to_int())
			return
		
		if not Stage.stage_exists(value):
			return
		stage_background_rect.texture = await DemonCrawl.get_stage_bg(value)
@export_group("Quest", "quest_")
@export var quest_type := Quest.Type.GLORY_DAYS :
	set(value):
		quest_type = value
		if not quest_name_label:
			await ready
		if value == Quest.Type.BEYOND:
			quest_name_label.text = "Beyond"
			return
		quest_name_label.text = QUEST_TEXT % [
			Quest.Type.find_key(value).capitalize().replace("Respites", "Respite's"),
			Quest.Difficulty.find_key(quest_difficulty).capitalize()
		]
@export var quest_difficulty := Quest.Difficulty.NORMAL :
	set(value):
		quest_difficulty = value
		if not quest_name_label:
			await ready
		if value == Quest.Difficulty.BEYOND:
			quest_name_label.text = "Beyond"
			return
		quest_name_label.text = QUEST_TEXT % [
			Quest.Type.find_key(quest_type).capitalize().replace("Respites", "Respite's"),
			Quest.Difficulty.find_key(value).capitalize()
		]
# ==============================================================================
@onready var panel: PanelContainer = %Panel
@onready var stage_background_rect: TextureRect = %StageBackgroundRect
@onready var quest_name_label: Label = %QuestNameLabel
# ==============================================================================

func _init() -> void:
	if not Engine.is_editor_hint():
		border_hide()


func border_show() -> void:
	border_visible = true


func border_hide() -> void:
	border_visible = false


func set_quest_int(quest_int: int) -> void:
	quest_type = quest_int & 0b11100 as Quest.Type
	quest_difficulty = quest_int & 0b00011 as Quest.Difficulty


static func instantiate() -> QuestDisplay:
	if not scene:
		scene = load("res://HistoryView/QuestDisplay.tscn")
	
	return scene.instantiate()
