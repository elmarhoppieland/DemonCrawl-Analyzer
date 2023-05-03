extends Node

# ==============================================================================
enum ItemType {
	UNKNOWN,
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
var item_data := {}
var item_requests: PackedStringArray = []
# ==============================================================================
signal finished_loading(item_name: String, item_icon: ImageTexture, item_description: String, item_price: int, item_type: ItemType)
signal item_request_completed(data: Dictionary)
# ==============================================================================

func request_item_data(item_name: String, callable: Callable) -> void:
	if is_item_in_cache(item_name):
		callable.call(item_data[item_name])
		return
	
	if not item_name in item_requests:
		item_requests.append(item_name)
		
		var item_page_http_request := HTTPRequest.new()
		var icon_page_http_request := HTTPRequest.new()
		
		add_child(item_page_http_request)
		add_child(icon_page_http_request)
		
		load_item(item_name, item_page_http_request, icon_page_http_request)
	
	item_request_completed.connect(func(data: ItemDataSource):
		if data.item == item_name:
			if item_name in item_requests:
				item_requests.remove_at(item_requests.find(item_name))
			if data.is_found():
				item_data[item_name] = data
			callable.call(data)
	)


func load_item(item_name: String, item_page_http_request: HTTPRequest, icon_page_http_request: HTTPRequest) -> ItemDataSource:
	var data_source := ItemDataSource.new()
	data_source.item = item_name
	
	item_page_http_request.request_completed.connect(_on_item_http_request_request_completed.bind(item_page_http_request, icon_page_http_request, data_source))
	item_page_http_request.request(data_source.get_url())
	
	icon_page_http_request.request_completed.connect(_on_icon_page_request_request_completed.bind(icon_page_http_request, data_source))
	
	data_source.completed.connect(func():
		item_request_completed.emit(data_source)
	)
	
	return data_source


func is_item_in_cache(item_name: String) -> bool:
	return item_name in item_data


func _on_item_http_request_request_completed(result: HTTPRequest.Result, _response_code: int, _headers: PackedStringArray, body: PackedByteArray, item_page_http_request: HTTPRequest, icon_page_http_request: HTTPRequest, data_source: ItemDataSource) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		data_source.description = "Unable to load information about the item. (Error code %s)" % result
		data_source.icon = ImageTexture.create_from_image(preload("res://Sprites/Unknown.png"))
		data_source.cost = 0
		data_source.type = ItemType.CONSUMABLE
		
		item_page_http_request.queue_free()
		return
	
	var html := body.get_string_from_utf8()
	
	var icon_found := false
	
	if OS.is_debug_build() and data_source.item == "Magic Smoke Bomb":
		FileAccess.open("user://temp.txt", FileAccess.WRITE).store_string(html)
	
	for slice_index in html.get_slice_count("\n"):
		var slice := html.get_slice("\n", slice_index)
		if slice == "<TITLE> 508 Resource Limit Is Reached</TITLE>":
			# we asked too much from the server, try connecting again
			get_tree().create_timer(0.5).timeout.connect(item_page_http_request.request.bind(data_source.get_url()))
			return
		if slice == "<p>There is currently no text in this page.":
			data_source.description = "The item was not found on the DemonCrawl wiki."
			data_source.icon = ImageTexture.create_from_image(preload("res://Sprites/Unknown.png"))
			data_source.cost = 0
			data_source.type = ItemType.CONSUMABLE
			
			item_page_http_request.queue_free()
			return
		if slice.match("<td class=\"description\">*</td>"):
			data_source.description = remove_html(slice)
			continue
		if slice.match("<div class=\"infobox-image\"><a href=\"*\" class=\"image\"><img alt=\"*\" src=\"*\" decoding=\"async\" width=\"*\" height=\"*\" /></a></div>"):
			if icon_page_http_request.get_http_client_status() == 0:
				var source := slice.get_slice("src=\"", 1).get_slice("\"", 0)
				icon_page_http_request.request("https://demoncrawl.com" + source)
				icon_found = true
			continue
		if slice.match("<td><img src=\"*\" /> <a href=\"*\" title=\"*\">*</a></td>"):
			var string := slice.get_slice(">", 3).get_slice("<", 0)
			if string.ends_with(" coins"):
				data_source.cost = string.to_int()
			else:
				data_source.type = ItemType[string.to_upper()]
			continue
		if slice.begins_with("<div class=\"printfooter\">Retrieved from "):
			break
	
	if data_source.description.is_empty():
		data_source.description = "Unable to find the description of this item."
	if not icon_found:
		data_source.icon = ImageTexture.create_from_image(preload("res://Sprites/Unknown.png"))
	if not data_source.is_complete():
		var properties := data_source.get_unset_properties()
		if "icon" in properties:
			properties.remove_at(properties.find("icon"))
	
	item_page_http_request.queue_free()


func _on_icon_page_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray, icon_page_http_request: HTTPRequest, data_source: ItemDataSource) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		return
	
	var image := Image.new()
	var error := image.load_png_from_buffer(body)
	if error:
		return
	
	var texture := ImageTexture.create_from_image(image)
	
	data_source.icon = texture
	
	icon_page_http_request.queue_free()


func remove_html(html_string: String) -> String:
	var new_string := ""
	
	var html_depth := 0
	for character in html_string:
		if character == "<":
			html_depth += 1
			continue
		if character == ">":
			html_depth -= 1
			continue
		
		if html_depth < 1:
			new_string += character
	
	return new_string
