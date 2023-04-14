extends Control
class_name GlobalStatistics

# ==============================================================================
@export var columns: Array[String] = []
# ==============================================================================
@onready var tree: Tree = %Tree
@onready var main: Statistics = owner
# ==============================================================================

func _ready() -> void:
	_initialize_tree()
	
	populate_tree()


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
	
	for profile in main.get_used_profiles():
		var profile_item := root.create_child()
		profile_item.set_text(0, profile.name)
		
		for i in Quest.Statistic.COUNT:
			var value := 0
			for quest in profile.quests:
				if not quest.matches_filters(filters):
					continue
				
				value += quest.get_statistic(i)
			
			profile_item.set_text(i + 1, "" if value < 0 else (" " + str(value)))


func _on_filters_saved(filters: Dictionary) -> void:
	populate_tree(filters)
