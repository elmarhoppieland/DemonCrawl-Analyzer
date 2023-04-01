extends HistoryData
class_name StageEnter

# ==============================================================================
var inventory: Inventory

var stats: PlayerStats
# ==============================================================================

static func _from_dict(dict: Dictionary) -> StageEnter:
	if not "inventory" in dict or not "stats" in dict:
		return null
	
	var stage_enter := StageEnter.new()
	
	stage_enter.inventory = Inventory._from_array(dict.inventory.items)
	stage_enter.stats = PlayerStats.from_string(dict.stats)
	
	return stage_enter
