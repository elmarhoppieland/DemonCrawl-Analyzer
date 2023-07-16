extends Control
class_name TimeLine

# ==============================================================================
var load_thread := Thread.new()
# ==============================================================================
@onready var h_flow_container: HFlowContainer = %HFlowContainer
@onready var tree: Tree = %Tree
@onready var inventory_panel: PanelContainer = %InventoryPanel
@onready var inventory_screen: Control = %InventoryScreen
@onready var tree_split_container: HSplitContainer = %TreeSplitContainer
# ==============================================================================

func _ready() -> void:
	tree.hide()
	inventory_panel.hide()
	tree_split_container.hide()
	
	load_thread.start(populate_timeline)
	while load_thread.is_alive():
		await get_tree().process_frame
	load_thread.wait_to_finish()


func populate_timeline() -> void:
	var start_unix: int = Analyzer.get_setting("-Data", "start_unix")
	var start_datetime_dict := Time.get_datetime_dict_from_unix_time(start_unix)
	
	var current_date := Calendar.get_date()
	
	var date := current_date
	while true:
		var timeline_month := TimeLineMonth.instantiate()
		h_flow_container.add_child(timeline_month)
		timeline_month.update_calendar_buttons(date)
		
		date = date.duplicate()
		date.change_to_prev_month()
		if date.month < start_datetime_dict.month and date.year == start_datetime_dict.year:
			return
		if date.year < start_datetime_dict.year:
			return


static func get_tab() -> TimeLine:
	return Analyzer.get_tab(Analyzer.Tab.TIMELINE)


func _on_filters_saved(filters: Dictionary) -> void:
	for month in h_flow_container.get_children() as Array[TimeLineMonth]:
		month.update_filters(filters)


func _on_tree_cell_selected() -> void:
	var item := tree.get_selected()
	if item.get_meta("type") == History.ItemType.INVENTORY:
		var inventory: Inventory = item.get_meta("inventory")
		inventory_panel.show()
		inventory_screen.show_inventory(inventory)
	else:
		inventory_panel.hide()
		tree.deselect_all()
