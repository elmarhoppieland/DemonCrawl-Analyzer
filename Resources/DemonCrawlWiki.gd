extends Node

# ==============================================================================
enum ItemType {
	CONSUMABLE,
	PASSIVE,
	MAGIC,
	LEGENDARY,
	OMEN
}
const TYPE_COLORS := {
	ItemType.CONSUMABLE: Color.LIGHT_GREEN,
	ItemType.PASSIVE: Color.DARK_GRAY,
	ItemType.MAGIC: Color.CORNFLOWER_BLUE,
	ItemType.LEGENDARY: Color.GOLDENROD,
	ItemType.OMEN: Color.RED,
}
# ==============================================================================
signal finished_loading(item_name: String, item_icon: ImageTexture, item_description: String, item_price: int, item_type: ItemType)
# ==============================================================================

func request_item_data(item_name: String, callable: Callable) -> void:
	var item_page_http_request := HTTPRequest.new()
	var icon_page_http_request := HTTPRequest.new()
	
	add_child(item_page_http_request)
	add_child(icon_page_http_request)
	
	var data_source := load_item(item_name, item_page_http_request, icon_page_http_request)
	
	icon_page_http_request.request_completed.connect(_on_icon_page_request_request_completed.bind(callable, data_source))
	
	await icon_page_http_request.request_completed
	
	item_page_http_request.queue_free()
	icon_page_http_request.queue_free()


func load_item(item_name: String, item_page_http_request: HTTPRequest, icon_page_http_request: HTTPRequest) -> Dictionary:
	var data_source := {}
	
	data_source.item = item_name
	data_source.icon = null
	data_source.description = ""
	data_source.price = 0
	data_source.type = ItemType.CONSUMABLE
	
	item_page_http_request.request_completed.connect(_on_item_http_request_request_completed.bind(icon_page_http_request, data_source))
	item_page_http_request.request("https://demoncrawl.com/wiki/index.php/%s" % item_name.replace(" ", "_"))
	
	return data_source


func _on_item_http_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray, icon_page_http_request: HTTPRequest, data_source: Dictionary) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		return
	
	var html := body.get_string_from_utf8()
	
	FileAccess.open("user://temp.txt", FileAccess.WRITE).store_string(html)
	
	for slice_index in html.get_slice_count("\n"):
		var slice := html.get_slice("\n", slice_index)
		if slice.match("<td class=\"description\">*</td>"):
			data_source.description = slice.trim_prefix("<td class=\"description\">").trim_suffix("</td>")
		if slice.match("<div class=\"infobox-image\"><a href=\"*\" class=\"image\"><img alt=\"*\" src=\"*\" decoding=\"async\" width=\"*\" height=\"*\" /></a></div>"):
			var source := slice.get_slice("src=\"", 1).get_slice("\"", 0)
			icon_page_http_request.request("https://demoncrawl.com" + source)
		if slice.match("<td><img src=\"*\" /> <a href=\"*\" title=\"*\">*</a></td>"):
			var string := slice.get_slice(">", 3).get_slice("<", 0)
			if string.ends_with(" coins"):
				data_source.price = string.to_int()
				break
			else:
				data_source.type = ItemType[string.to_upper()]
		if slice.begins_with("<div class=\"printfooter\">Retrieved from "):
			break


func _on_icon_page_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray, return_callable: Callable, data_source: Dictionary) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		return
	
	var image := Image.new()
	var error := image.load_png_from_buffer(body)
	if error:
		return
	
	var texture := ImageTexture.create_from_image(image)
	
	data_source.icon = texture
	
	finished_loading.emit(data_source.item, texture, data_source.description, data_source.price, data_source.type)
	
	return_callable.call(data_source)
