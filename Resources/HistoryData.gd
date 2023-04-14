extends Resource
class_name HistoryData

# ==============================================================================
const NO_EXPORT := "<no-export>"
const USE_DEFAULT := "<use-default>"
# ==============================================================================

func to_dict() -> Dictionary:
	var dict := {}
	
	for property in get_script().get_script_property_list():
		if not property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		
		var value = export_property(property.name)
		if not value is String or value != NO_EXPORT:
			dict[property.name] = value
	
	return dict


func export_property(property: StringName) -> Variant:
	var override = _export(property)
	if override != USE_DEFAULT:
		return override
	
	if has_method("_export_" + property):
		return call("_export_" + property)
	
	var value = get(property)
	if value is HistoryData:
		return value.to_json()
	
	return value


func _export(_property: StringName) -> Variant:
	return USE_DEFAULT


## Creates a new HistoryData [Object] from the provided [code]json[/code].
## The [Object] will be of type [code]data_type[/code], which should inherit from HistoryData.
static func from_json(json: Dictionary, data_type: GDScript) -> HistoryData:
	var data: HistoryData = data_type.new()
	
	for property_name in json:
		if not property_name in data:
			push_error("Invalid property '%s' in provided json." % property_name)
			continue
		
		var value = json[property_name]
		if value == null:
			continue
		
		if data.has_method("_import_" + property_name):
			data.call("_import_" + property_name, value)
			continue
		
		data.set(property_name, value)
	
	return data


## Converts the data into json format.
func to_json() -> Variant:
	var dict := {}
	
	for property in get_script().get_script_property_list():
		if not property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		
		var value: Variant = export_property(property.name)
		if not value is String or value != NO_EXPORT:
			dict[property.name] = value
	
	return dict
