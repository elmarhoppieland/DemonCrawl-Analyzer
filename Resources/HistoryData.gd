extends RefCounted
class_name HistoryData

# ==============================================================================

func _to_dict() -> Dictionary:
	var dict := {}
	
	for property in get_script().get_script_property_list():
		if not property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		
		var value = get(property.name)
		if value is PlayerStats:
			dict[property.name] = str(value)
		elif value is HistoryData:
			dict[property.name] = value._to_dict()
		elif value is Array:
			dict[property.name] = []
			
			for i in value:
				if i is HistoryData:
					dict[property.name].append(i._to_dict())
				else:
					dict[property.name].append(i)
		else:
			dict[property.name] = value
	
	return dict
