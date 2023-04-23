extends VBoxContainer
class_name QuestFilter

# ==============================================================================
var filters := {}
# ==============================================================================
@onready var quest_type_check_boxes: Array[QuestTypeCheckBox] = [
	$HBoxContainer/Casual/GloryDays as QuestTypeCheckBox,
	$HBoxContainer/Casual/RespitesEnd as QuestTypeCheckBox,
	$HBoxContainer/Casual/AnotherWay as QuestTypeCheckBox,
	$HBoxContainer/Casual/AroundTheBend as QuestTypeCheckBox,
	$HBoxContainer/Casual/Shadowman as QuestTypeCheckBox,
	$HBoxContainer/Normal/GloryDays as QuestTypeCheckBox,
	$HBoxContainer/Normal/RespitesEnd as QuestTypeCheckBox,
	$HBoxContainer/Normal/AnotherWay as QuestTypeCheckBox,
	$HBoxContainer/Normal/AroundTheBend as QuestTypeCheckBox,
	$HBoxContainer/Normal/Shadowman as QuestTypeCheckBox,
	$HBoxContainer/Hard/GloryDays as QuestTypeCheckBox,
	$HBoxContainer/Hard/RespitesEnd as QuestTypeCheckBox,
	$HBoxContainer/Hard/AnotherWay as QuestTypeCheckBox,
	$HBoxContainer/Hard/AroundTheBend as QuestTypeCheckBox,
	$HBoxContainer/Hard/Shadowman as QuestTypeCheckBox,
	$HBoxContainer/Hard/EndlessMultiverse as QuestTypeCheckBox,
	$HBoxContainer/Hard/HeroTrials as QuestTypeCheckBox,
	$HBoxContainer/Hard/Beyond as QuestTypeCheckBox
]
# ==============================================================================
signal filters_changed(new_filters: Dictionary)
# ==============================================================================

func _ready() -> void:
	filters.clear()
	
	for check_box in quest_type_check_boxes:
		filters[check_box] = check_box.get_value()
		check_box.pressed.connect(_on_quest_type_check_box_pressed.bind(check_box))
	
	filters_changed.emit(filters)


func _on_quest_type_check_box_pressed(check_box: QuestTypeCheckBox) -> void:
	filters[check_box] = check_box.get_value()
	
	filters_changed.emit(filters.duplicate())
