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
	
	stage_enter.inventory = Inventory.from_array(dict.inventory.items)
	stage_enter.stats = PlayerStats.from_string(dict.stats)
	
	return stage_enter


func _import_inventory(json: Dictionary) -> void:
	inventory = HistoryData.from_json(json, Inventory)


func _import_stats(data: String) -> void:
	stats = PlayerStats.from_string(data)


func _export_stats() -> String:
	return stats.to_string()
