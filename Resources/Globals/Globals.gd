@tool
extends Resource
class_name Globals

# ==============================================================================
static var prestige_colors := {
	0: Color.WHITE,
	1: Color.WHITE,
	2: Color.WHITE,
	3: Color.WHITE,
	4: Color.WHITE,
	5: Color.WHITE,
	6: Color.WHITE,
	7: Color.WHITE,
	8: Color.WHITE,
	9: Color.WHITE,
	10: Color.WHITE,
}
# ==============================================================================

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	for i in 11:
		properties.append({
			"name": "Prestige Colors/%d" % i,
			"type": TYPE_COLOR,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	return properties


func _set(property: StringName, value: Variant) -> bool:
	if property.match("Prestige Colors/*"):
		prestige_colors[property.get_slice("/", 1).to_int()] = value
		return false
	
	return true


func _get(property: StringName) -> Variant:
	if property.match("Prestige Colors/*"):
		return prestige_colors[property.get_slice("/", 1).to_int()]
	
	return null


func _property_can_revert(_property: StringName) -> bool:
	return true


func _property_get_revert(property: StringName) -> Variant:
	if property.match("Prestige Colors/*"):
		return Color.WHITE
	
	return null
