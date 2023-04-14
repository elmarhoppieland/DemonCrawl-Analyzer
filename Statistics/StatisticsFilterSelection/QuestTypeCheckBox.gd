extends CheckBox
class_name QuestTypeCheckBox

# ==============================================================================
@export var difficulty := Quest.Difficulty.CASUAL
@export var type := Quest.Type.GLORY_DAYS
# ==============================================================================

func _ready() -> void:
	if owner is StatisticsFilterSelection:
		pressed.connect(owner._on_quest_type_check_box_pressed.bind(self))


func get_value() -> int:
	if button_pressed:
		return difficulty | type
	
	return -1
