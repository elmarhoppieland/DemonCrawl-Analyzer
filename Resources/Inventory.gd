extends HistoryData
class_name Inventory

# ==============================================================================
var items: PackedStringArray = (func(): var r := []; r.resize(24); r.fill(""); return r).call()
# ==============================================================================

## Creates a copy of this [Inventory] and returns it.
func get_state() -> Inventory:
	var inventory := Inventory.new()
	inventory.items = items.duplicate()
	
	return inventory


## Returns the index of the first free (empty) iventory slot.
func get_free_slot() -> int:
	var index := 0
	if items.count("") != 24:
		while index < 23 and (not items[index].is_empty() or items[index - 1].is_empty()):
			index += 1
	
	return index


static func _from_array(item_array: Array) -> Inventory:
	var inventory := Inventory.new()
	
	inventory.items = item_array
	
	return inventory
