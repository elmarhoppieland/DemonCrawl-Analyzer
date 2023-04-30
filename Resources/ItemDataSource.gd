extends RefCounted
class_name ItemDataSource

# ==============================================================================
var item := "" :
	set(value):
		item = value
		if is_complete():
			completed.emit()
var description := "" :
	set(value):
		description = value
		if is_complete():
			completed.emit()
var icon: ImageTexture :
	set(value):
		icon = value
		if is_complete():
			completed.emit()
var type := DemonCrawlWiki.ItemType.UNKNOWN :
	set(value):
		type = value
		if is_complete():
			completed.emit()
var cost := -1 :
	set(value):
		cost = value
		if is_complete():
			completed.emit()
# ==============================================================================
signal completed()
# ==============================================================================

func get_url() -> String:
	return "https://demoncrawl.com/wiki/index.php/%s" % item.replace(" ", "_")


func is_found() -> bool:
	if description.match("Unable to load information about the item. (Error code *)"):
		return false
	if description == "The item was not found on the DemonCrawl wiki.":
		return false
	
	return true


func is_loaded() -> bool:
	return not description.match("Unable to load information about the item. (Error code *)")


func is_complete() -> bool:
	if item.is_empty() \
	or description.is_empty() \
	or not icon \
	or type == DemonCrawlWiki.ItemType.UNKNOWN \
	or cost < 0:
		return false
	
	return true


func get_unset_properties() -> PackedStringArray:
	var properties: PackedStringArray = []
	
	if item.is_empty():
		properties.append("item")
	if description.is_empty():
		properties.append("description")
	if not icon:
		properties.append("icon")
	if type == DemonCrawlWiki.ItemType.UNKNOWN:
		properties.append("type")
	if cost < 0:
		properties.append("cost")
	
	return properties
