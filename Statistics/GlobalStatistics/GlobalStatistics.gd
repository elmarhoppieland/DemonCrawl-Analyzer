extends Control
class_name GlobalStatistics

# ==============================================================================
@export var columns: Array[String] = []
# ==============================================================================
var load_thread := Thread.new()
# ==============================================================================
@onready var tree: Tree = %Tree
@onready var main: Statistics = owner
# ==============================================================================

func _ready() -> void:
	_initialize_tree()
	
	load_thread.start(populate_tree)


func _process(_delta: float) -> void:
	if load_thread.is_started() and not load_thread.is_alive():
		load_thread.wait_to_finish()


func _initialize_tree() -> void:
	tree.columns = columns.size()
	
	for i in columns.size():
		var column = columns[i]
		
		tree.set_column_title(i, column)
	
	for i in range(1, tree.columns):
		tree.set_column_expand(i, false)


func populate_tree(filters: Dictionary = {}) -> void:
	tree.clear()
	
	var root := tree.create_item()
	
	var total_stats := {}
	for i in Quest.Statistic.COUNT:
		total_stats[i] = 0
	
	for profile in ProfileLoader.get_used_profiles():
		var profile_item := root.create_child()
		profile_item.set_text(0, profile.name)
		profile_item.set_tooltip_text(0, " ")
		
		for i in Quest.Statistic.COUNT:
			var value := 0
			for quest in profile.quests:
				if not quest.matches_filters(filters):
					continue
				
				value += quest.get_statistic(i)
			
			profile_item.set_text(i + 1, "" if value < 0 else (" " + str(value)))
			profile_item.set_tooltip_text(i + 1, " ")
			
			total_stats[i] += value
	
	var total_item := root.create_child()
	total_item.set_text(0, "Total")
	total_item.set_tooltip_text(0, " ")
	for i in Quest.Statistic.COUNT:
		var value: int = total_stats[i]
		total_item.set_text(i + 1, "" if value < 0 else " " + str(value))
		total_item.set_tooltip_text(i + 1, " ")


func _on_filters_saved(filters: Dictionary) -> void:
	load_thread.start(populate_tree.bind(filters))
