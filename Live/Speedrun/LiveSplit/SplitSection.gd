extends VBoxContainer
class_name SplitSection

# ==============================================================================
var start_split_index := -1
# ==============================================================================
@onready var name_label: Label = %NameLabel
@onready var comparison_label: Label = %ComparisonLabel
@onready var time_label: Label = %TimeLabel
@onready var sub_splits_container: VBoxContainer = %SubSplitsContainer
@onready var background_color_rect: ColorRect = %BackgroundColorRect
@onready var sub_splits_margin_container: MarginContainer = %SubSplitsMarginContainer
# ==============================================================================

func _ready() -> void:
	name_label.text = name


func _set(property: StringName, value: Variant) -> bool:
	if property == "name":
		name = value
		if name_label:
			name_label.text = value
	
	return true


func with_start_split_index(idx: int) -> SplitSection:
	start_split_index = idx
	return self


func add_subsplit(subsplit: Split) -> void:
	sub_splits_container.add_child(subsplit.with_split_section(self))


func get_subsplit(idx: int) -> Split:
	return sub_splits_container.get_child(idx)


func get_subsplit_count() -> int:
	return sub_splits_container.get_child_count()


func is_open() -> bool:
	return sub_splits_margin_container.visible


func open() -> void:
	background_color_rect.show()
	sub_splits_margin_container.show()


func close() -> void:
	background_color_rect.hide()
	sub_splits_margin_container.hide()
