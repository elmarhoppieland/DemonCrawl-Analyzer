extends HistoryData
class_name StageExit

# ==============================================================================
var inventory: Inventory
# ==============================================================================

static func _from_dict(dict: Dictionary) -> StageExit:
	if not "inventory" in dict:
		return null
	
	var stage_exit := StageExit.new()
	
	stage_exit.inventory = Inventory._from_array(dict.inventory.items)
	
	return stage_exit
