extends RefCounted
class_name Leaderboards

# ==============================================================================
# Bits:
#  1 bit for Downpatched (1 for 1.87, 0 for 1.88+)
#  1 bit for Fresh File (1 for enabled, 0 for disabled)
#  1 bit for HDFS (1 for enabled, 0 for disabled; always disabled if Fresh File is enabled)
#  3 bits for Difficulty (see enum Difficulty)
#  4 bits for ILs (see enum IL; don't specify if category is Full Game)
# (10 bits total)

enum IL {
	DISABLED = 0, # _ _ _ ___ 0000
	ENABLED = 1, # _ _ _ ___ 0001
	GLORY_DAYS = 3, # _ _ _ ___ 0011
	RESPITES_END = 5, # _ _ _ ___ 0101
	ANOTHER_WAY = 7, # _ _ _ ___ 0111
	AROUND_THE_BEND = 9, # _ _ _ ___ 1001
	SHADOWMAN = 11 # _ _ _ ___ 1011
}
enum Difficulty {
	CASUAL = 0x10, # _ _ _ 001 ____
	CASUAL_RANDOM = 0x20, # _ _ _ 010 ____
	NORMAL = 0x30, # _ _ _ 011 ____
	HARD = 0x40 # _ _ _ 100 ____
}
const HDFS := 0x80 # _ _ 1 ___ ____
const FRESH_FILE := 0x100 # _ 1 _ ___ ____
const DOWNPATCHED := 0x200 # 1 _ _ ___ ____

enum Category {
	CASUAL_FRESH_FILE_1_87 = Difficulty.CASUAL | FRESH_FILE | DOWNPATCHED,
	CASUAL_FRESH_FILE_1_88 = Difficulty.CASUAL | FRESH_FILE,
	CASUAL_NO_HDFS_1_87 = Difficulty.CASUAL | DOWNPATCHED,
	CASUAL_NO_HDFS_1_88 = Difficulty.CASUAL,
	CASUAL_HDFS_1_87 = Difficulty.CASUAL | HDFS | DOWNPATCHED,
	CASUAL_HDFS_1_88 = Difficulty.CASUAL | HDFS,
	CASUAL_RANDOM_FRESH_FILE_1_87 = Difficulty.CASUAL_RANDOM | FRESH_FILE | DOWNPATCHED,
	CASUAL_RANDOM_FRESH_FILE_1_88 = Difficulty.CASUAL_RANDOM | FRESH_FILE,
	CASUAL_RANDOM_NO_HDFS_1_87 = Difficulty.CASUAL_RANDOM | DOWNPATCHED,
	CASUAL_RANDOM_NO_HDFS_1_88 = Difficulty.CASUAL_RANDOM,
	CASUAL_RANDOM_HDFS_1_87 = Difficulty.CASUAL_RANDOM | HDFS | DOWNPATCHED,
	CASUAL_RANDOM_HDFS_1_88 = Difficulty.CASUAL_RANDOM | HDFS,
	NORMAL_FRESH_FILE_1_87 = Difficulty.NORMAL | FRESH_FILE | DOWNPATCHED,
	NORMAL_FRESH_FILE_1_88 = Difficulty.NORMAL | FRESH_FILE,
	NORMAL_NO_HDFS_1_87 = Difficulty.NORMAL | DOWNPATCHED,
	NORMAL_NO_HDFS_1_88 = Difficulty.NORMAL,
	NORMAL_HDFS_1_87 = Difficulty.NORMAL | HDFS | DOWNPATCHED,
	NORMAL_HDFS_1_88 = Difficulty.NORMAL | HDFS,
	HARD_FRESH_FILE_1_87 = Difficulty.HARD | FRESH_FILE | DOWNPATCHED,
	HARD_FRESH_FILE_1_88 = Difficulty.HARD | FRESH_FILE,
	HARD_NO_HDFS_1_87 = Difficulty.HARD | DOWNPATCHED,
	HARD_NO_HDFS_1_88 = Difficulty.HARD,
	HARD_HDFS_1_87 = Difficulty.HARD | HDFS | DOWNPATCHED,
	HARD_HDFS_1_88 = Difficulty.HARD | HDFS,
	GLORY_DAYS_CASUAL_FRESH_FILE_1_87 = IL.GLORY_DAYS | Difficulty.CASUAL | FRESH_FILE | DOWNPATCHED,
	GLORY_DAYS_CASUAL_FRESH_FILE_1_88 = IL.GLORY_DAYS | Difficulty.CASUAL | FRESH_FILE,
	GLORY_DAYS_CASUAL_NO_HDFS_1_87 = IL.GLORY_DAYS | Difficulty.CASUAL | DOWNPATCHED,
	GLORY_DAYS_CASUAL_NO_HDFS_1_88 = IL.GLORY_DAYS | Difficulty.CASUAL,
	GLORY_DAYS_CASUAL_HDFS_1_87 = IL.GLORY_DAYS | Difficulty.CASUAL | HDFS | DOWNPATCHED,
	GLORY_DAYS_CASUAL_HDFS_1_88 = IL.GLORY_DAYS | Difficulty.CASUAL | HDFS,
	GLORY_DAYS_CASUAL_RANDOM_FRESH_FILE_1_87 = IL.GLORY_DAYS | Difficulty.CASUAL_RANDOM | FRESH_FILE | DOWNPATCHED,
	GLORY_DAYS_CASUAL_RANDOM_FRESH_FILE_1_88 = IL.GLORY_DAYS | Difficulty.CASUAL_RANDOM | FRESH_FILE,
	GLORY_DAYS_CASUAL_RANDOM_NO_HDFS_1_87 = IL.GLORY_DAYS | Difficulty.CASUAL_RANDOM | DOWNPATCHED,
	GLORY_DAYS_CASUAL_RANDOM_NO_HDFS_1_88 = IL.GLORY_DAYS | Difficulty.CASUAL_RANDOM,
	GLORY_DAYS_CASUAL_RANDOM_HDFS_1_87 = IL.GLORY_DAYS | Difficulty.CASUAL_RANDOM | HDFS | DOWNPATCHED,
	GLORY_DAYS_CASUAL_RANDOM_HDFS_1_88 = IL.GLORY_DAYS | Difficulty.CASUAL_RANDOM | HDFS,
	GLORY_DAYS_NORMAL_FRESH_FILE_1_87 = IL.GLORY_DAYS | Difficulty.NORMAL | FRESH_FILE | DOWNPATCHED,
	GLORY_DAYS_NORMAL_FRESH_FILE_1_88 = IL.GLORY_DAYS | Difficulty.NORMAL | FRESH_FILE,
	GLORY_DAYS_NORMAL_NO_HDFS_1_87 = IL.GLORY_DAYS | Difficulty.NORMAL | DOWNPATCHED,
	GLORY_DAYS_NORMAL_NO_HDFS_1_88 = IL.GLORY_DAYS | Difficulty.NORMAL,
	GLORY_DAYS_NORMAL_HDFS_1_87 = IL.GLORY_DAYS | Difficulty.NORMAL | HDFS | DOWNPATCHED,
	GLORY_DAYS_NORMAL_HDFS_1_88 = IL.GLORY_DAYS | Difficulty.NORMAL | HDFS,
	GLORY_DAYS_HARD_FRESH_FILE_1_87 = IL.GLORY_DAYS | Difficulty.HARD | FRESH_FILE | DOWNPATCHED,
	GLORY_DAYS_HARD_FRESH_FILE_1_88 = IL.GLORY_DAYS | Difficulty.HARD | FRESH_FILE,
	GLORY_DAYS_HARD_NO_HDFS_1_87 = IL.GLORY_DAYS | Difficulty.HARD | DOWNPATCHED,
	GLORY_DAYS_HARD_NO_HDFS_1_88 = IL.GLORY_DAYS | Difficulty.HARD,
	GLORY_DAYS_HARD_HDFS_1_87 = IL.GLORY_DAYS | Difficulty.HARD | HDFS | DOWNPATCHED,
	GLORY_DAYS_HARD_HDFS_1_88 = IL.GLORY_DAYS | Difficulty.HARD | HDFS,
	RESPITES_END_CASUAL_FRESH_FILE_1_87 = IL.RESPITES_END | Difficulty.CASUAL | FRESH_FILE | DOWNPATCHED,
	RESPITES_END_CASUAL_FRESH_FILE_1_88 = IL.RESPITES_END | Difficulty.CASUAL | FRESH_FILE,
	RESPITES_END_CASUAL_NO_HDFS_1_87 = IL.RESPITES_END | Difficulty.CASUAL | DOWNPATCHED,
	RESPITES_END_CASUAL_NO_HDFS_1_88 = IL.RESPITES_END | Difficulty.CASUAL,
	RESPITES_END_CASUAL_HDFS_1_87 = IL.RESPITES_END | Difficulty.CASUAL | HDFS | DOWNPATCHED,
	RESPITES_END_CASUAL_HDFS_1_88 = IL.RESPITES_END | Difficulty.CASUAL | HDFS,
	RESPITES_END_CASUAL_RANDOM_FRESH_FILE_1_87 = IL.RESPITES_END | Difficulty.CASUAL_RANDOM | FRESH_FILE | DOWNPATCHED,
	RESPITES_END_CASUAL_RANDOM_FRESH_FILE_1_88 = IL.RESPITES_END | Difficulty.CASUAL_RANDOM | FRESH_FILE,
	RESPITES_END_CASUAL_RANDOM_NO_HDFS_1_87 = IL.RESPITES_END | Difficulty.CASUAL_RANDOM | DOWNPATCHED,
	RESPITES_END_CASUAL_RANDOM_NO_HDFS_1_88 = IL.RESPITES_END | Difficulty.CASUAL_RANDOM,
	RESPITES_END_CASUAL_RANDOM_HDFS_1_87 = IL.RESPITES_END | Difficulty.CASUAL_RANDOM | HDFS | DOWNPATCHED,
	RESPITES_END_CASUAL_RANDOM_HDFS_1_88 = IL.RESPITES_END | Difficulty.CASUAL_RANDOM | HDFS,
	RESPITES_END_NORMAL_FRESH_FILE_1_87 = IL.RESPITES_END | Difficulty.NORMAL | FRESH_FILE | DOWNPATCHED,
	RESPITES_END_NORMAL_FRESH_FILE_1_88 = IL.RESPITES_END | Difficulty.NORMAL | FRESH_FILE,
	RESPITES_END_NORMAL_NO_HDFS_1_87 = IL.RESPITES_END | Difficulty.NORMAL | DOWNPATCHED,
	RESPITES_END_NORMAL_NO_HDFS_1_88 = IL.RESPITES_END | Difficulty.NORMAL,
	RESPITES_END_NORMAL_HDFS_1_87 = IL.RESPITES_END | Difficulty.NORMAL | HDFS | DOWNPATCHED,
	RESPITES_END_NORMAL_HDFS_1_88 = IL.RESPITES_END | Difficulty.NORMAL | HDFS,
	RESPITES_END_HARD_FRESH_FILE_1_87 = IL.RESPITES_END | Difficulty.HARD | FRESH_FILE | DOWNPATCHED,
	RESPITES_END_HARD_FRESH_FILE_1_88 = IL.RESPITES_END | Difficulty.HARD | FRESH_FILE,
	RESPITES_END_HARD_NO_HDFS_1_87 = IL.RESPITES_END | Difficulty.HARD | DOWNPATCHED,
	RESPITES_END_HARD_NO_HDFS_1_88 = IL.RESPITES_END | Difficulty.HARD,
	RESPITES_END_HARD_HDFS_1_87 = IL.RESPITES_END | Difficulty.HARD | HDFS | DOWNPATCHED,
	RESPITES_END_HARD_HDFS_1_88 = IL.RESPITES_END | Difficulty.HARD | HDFS,
	ANOTHER_WAY_CASUAL_FRESH_FILE_1_87 = IL.ANOTHER_WAY | Difficulty.CASUAL | FRESH_FILE | DOWNPATCHED,
	ANOTHER_WAY_CASUAL_FRESH_FILE_1_88 = IL.ANOTHER_WAY | Difficulty.CASUAL | FRESH_FILE,
	ANOTHER_WAY_CASUAL_NO_HDFS_1_87 = IL.ANOTHER_WAY | Difficulty.CASUAL | DOWNPATCHED,
	ANOTHER_WAY_CASUAL_NO_HDFS_1_88 = IL.ANOTHER_WAY | Difficulty.CASUAL,
	ANOTHER_WAY_CASUAL_HDFS_1_87 = IL.ANOTHER_WAY | Difficulty.CASUAL | HDFS | DOWNPATCHED,
	ANOTHER_WAY_CASUAL_HDFS_1_88 = IL.ANOTHER_WAY | Difficulty.CASUAL | HDFS,
	ANOTHER_WAY_CASUAL_RANDOM_FRESH_FILE_1_87 = IL.ANOTHER_WAY | Difficulty.CASUAL_RANDOM | FRESH_FILE | DOWNPATCHED,
	ANOTHER_WAY_CASUAL_RANDOM_FRESH_FILE_1_88 = IL.ANOTHER_WAY | Difficulty.CASUAL_RANDOM | FRESH_FILE,
	ANOTHER_WAY_CASUAL_RANDOM_NO_HDFS_1_87 = IL.ANOTHER_WAY | Difficulty.CASUAL_RANDOM | DOWNPATCHED,
	ANOTHER_WAY_CASUAL_RANDOM_NO_HDFS_1_88 = IL.ANOTHER_WAY | Difficulty.CASUAL_RANDOM,
	ANOTHER_WAY_CASUAL_RANDOM_HDFS_1_87 = IL.ANOTHER_WAY | Difficulty.CASUAL_RANDOM | HDFS | DOWNPATCHED,
	ANOTHER_WAY_CASUAL_RANDOM_HDFS_1_88 = IL.ANOTHER_WAY | Difficulty.CASUAL_RANDOM | HDFS,
	ANOTHER_WAY_NORMAL_FRESH_FILE_1_87 = IL.ANOTHER_WAY | Difficulty.NORMAL | FRESH_FILE | DOWNPATCHED,
	ANOTHER_WAY_NORMAL_FRESH_FILE_1_88 = IL.ANOTHER_WAY | Difficulty.NORMAL | FRESH_FILE,
	ANOTHER_WAY_NORMAL_NO_HDFS_1_87 = IL.ANOTHER_WAY | Difficulty.NORMAL | DOWNPATCHED,
	ANOTHER_WAY_NORMAL_NO_HDFS_1_88 = IL.ANOTHER_WAY | Difficulty.NORMAL,
	ANOTHER_WAY_NORMAL_HDFS_1_87 = IL.ANOTHER_WAY | Difficulty.NORMAL | HDFS | DOWNPATCHED,
	ANOTHER_WAY_NORMAL_HDFS_1_88 = IL.ANOTHER_WAY | Difficulty.NORMAL | HDFS,
	ANOTHER_WAY_HARD_FRESH_FILE_1_87 = IL.ANOTHER_WAY | Difficulty.HARD | FRESH_FILE | DOWNPATCHED,
	ANOTHER_WAY_HARD_FRESH_FILE_1_88 = IL.ANOTHER_WAY | Difficulty.HARD | FRESH_FILE,
	ANOTHER_WAY_HARD_NO_HDFS_1_87 = IL.ANOTHER_WAY | Difficulty.HARD | DOWNPATCHED,
	ANOTHER_WAY_HARD_NO_HDFS_1_88 = IL.ANOTHER_WAY | Difficulty.HARD,
	ANOTHER_WAY_HARD_HDFS_1_87 = IL.ANOTHER_WAY | Difficulty.HARD | HDFS | DOWNPATCHED,
	ANOTHER_WAY_HARD_HDFS_1_88 = IL.ANOTHER_WAY | Difficulty.HARD | HDFS,
	AROUND_THE_BEND_CASUAL_FRESH_FILE_1_87 = IL.AROUND_THE_BEND | Difficulty.CASUAL | FRESH_FILE | DOWNPATCHED,
	AROUND_THE_BEND_CASUAL_FRESH_FILE_1_88 = IL.AROUND_THE_BEND | Difficulty.CASUAL | FRESH_FILE,
	AROUND_THE_BEND_CASUAL_NO_HDFS_1_87 = IL.AROUND_THE_BEND | Difficulty.CASUAL | DOWNPATCHED,
	AROUND_THE_BEND_CASUAL_NO_HDFS_1_88 = IL.AROUND_THE_BEND | Difficulty.CASUAL,
	AROUND_THE_BEND_CASUAL_HDFS_1_87 = IL.AROUND_THE_BEND | Difficulty.CASUAL | HDFS | DOWNPATCHED,
	AROUND_THE_BEND_CASUAL_HDFS_1_88 = IL.AROUND_THE_BEND | Difficulty.CASUAL | HDFS,
	AROUND_THE_BEND_CASUAL_RANDOM_FRESH_FILE_1_87 = IL.AROUND_THE_BEND | Difficulty.CASUAL_RANDOM | FRESH_FILE | DOWNPATCHED,
	AROUND_THE_BEND_CASUAL_RANDOM_FRESH_FILE_1_88 = IL.AROUND_THE_BEND | Difficulty.CASUAL_RANDOM | FRESH_FILE,
	AROUND_THE_BEND_CASUAL_RANDOM_NO_HDFS_1_87 = IL.AROUND_THE_BEND | Difficulty.CASUAL_RANDOM | DOWNPATCHED,
	AROUND_THE_BEND_CASUAL_RANDOM_NO_HDFS_1_88 = IL.AROUND_THE_BEND | Difficulty.CASUAL_RANDOM,
	AROUND_THE_BEND_CASUAL_RANDOM_HDFS_1_87 = IL.AROUND_THE_BEND | Difficulty.CASUAL_RANDOM | HDFS | DOWNPATCHED,
	AROUND_THE_BEND_CASUAL_RANDOM_HDFS_1_88 = IL.AROUND_THE_BEND | Difficulty.CASUAL_RANDOM | HDFS,
	AROUND_THE_BEND_NORMAL_FRESH_FILE_1_87 = IL.AROUND_THE_BEND | Difficulty.NORMAL | FRESH_FILE | DOWNPATCHED,
	AROUND_THE_BEND_NORMAL_FRESH_FILE_1_88 = IL.AROUND_THE_BEND | Difficulty.NORMAL | FRESH_FILE,
	AROUND_THE_BEND_NORMAL_NO_HDFS_1_87 = IL.AROUND_THE_BEND | Difficulty.NORMAL | DOWNPATCHED,
	AROUND_THE_BEND_NORMAL_NO_HDFS_1_88 = IL.AROUND_THE_BEND | Difficulty.NORMAL,
	AROUND_THE_BEND_NORMAL_HDFS_1_87 = IL.AROUND_THE_BEND | Difficulty.NORMAL | HDFS | DOWNPATCHED,
	AROUND_THE_BEND_NORMAL_HDFS_1_88 = IL.AROUND_THE_BEND | Difficulty.NORMAL | HDFS,
	AROUND_THE_BEND_HARD_FRESH_FILE_1_87 = IL.AROUND_THE_BEND | Difficulty.HARD | FRESH_FILE | DOWNPATCHED,
	AROUND_THE_BEND_HARD_FRESH_FILE_1_88 = IL.AROUND_THE_BEND | Difficulty.HARD | FRESH_FILE,
	AROUND_THE_BEND_HARD_NO_HDFS_1_87 = IL.AROUND_THE_BEND | Difficulty.HARD | DOWNPATCHED,
	AROUND_THE_BEND_HARD_NO_HDFS_1_88 = IL.AROUND_THE_BEND | Difficulty.HARD,
	AROUND_THE_BEND_HARD_HDFS_1_87 = IL.AROUND_THE_BEND | Difficulty.HARD | HDFS | DOWNPATCHED,
	AROUND_THE_BEND_HARD_HDFS_1_88 = IL.AROUND_THE_BEND | Difficulty.HARD | HDFS,
	SHADOWMAN_CASUAL_FRESH_FILE_1_87 = IL.SHADOWMAN | Difficulty.CASUAL | FRESH_FILE | DOWNPATCHED,
	SHADOWMAN_CASUAL_FRESH_FILE_1_88 = IL.SHADOWMAN | Difficulty.CASUAL | FRESH_FILE,
	SHADOWMAN_CASUAL_NO_HDFS_1_87 = IL.SHADOWMAN | Difficulty.CASUAL | DOWNPATCHED,
	SHADOWMAN_CASUAL_NO_HDFS_1_88 = IL.SHADOWMAN | Difficulty.CASUAL,
	SHADOWMAN_CASUAL_HDFS_1_87 = IL.SHADOWMAN | Difficulty.CASUAL | HDFS | DOWNPATCHED,
	SHADOWMAN_CASUAL_HDFS_1_88 = IL.SHADOWMAN | Difficulty.CASUAL | HDFS,
	SHADOWMAN_CASUAL_RANDOM_FRESH_FILE_1_87 = IL.SHADOWMAN | Difficulty.CASUAL_RANDOM | FRESH_FILE | DOWNPATCHED,
	SHADOWMAN_CASUAL_RANDOM_FRESH_FILE_1_88 = IL.SHADOWMAN | Difficulty.CASUAL_RANDOM | FRESH_FILE,
	SHADOWMAN_CASUAL_RANDOM_NO_HDFS_1_87 = IL.SHADOWMAN | Difficulty.CASUAL_RANDOM | DOWNPATCHED,
	SHADOWMAN_CASUAL_RANDOM_NO_HDFS_1_88 = IL.SHADOWMAN | Difficulty.CASUAL_RANDOM,
	SHADOWMAN_CASUAL_RANDOM_HDFS_1_87 = IL.SHADOWMAN | Difficulty.CASUAL_RANDOM | HDFS | DOWNPATCHED,
	SHADOWMAN_CASUAL_RANDOM_HDFS_1_88 = IL.SHADOWMAN | Difficulty.CASUAL_RANDOM | HDFS,
	SHADOWMAN_NORMAL_FRESH_FILE_1_87 = IL.SHADOWMAN | Difficulty.NORMAL | FRESH_FILE | DOWNPATCHED,
	SHADOWMAN_NORMAL_FRESH_FILE_1_88 = IL.SHADOWMAN | Difficulty.NORMAL | FRESH_FILE,
	SHADOWMAN_NORMAL_NO_HDFS_1_87 = IL.SHADOWMAN | Difficulty.NORMAL | DOWNPATCHED,
	SHADOWMAN_NORMAL_NO_HDFS_1_88 = IL.SHADOWMAN | Difficulty.NORMAL,
	SHADOWMAN_NORMAL_HDFS_1_87 = IL.SHADOWMAN | Difficulty.NORMAL | HDFS | DOWNPATCHED,
	SHADOWMAN_NORMAL_HDFS_1_88 = IL.SHADOWMAN | Difficulty.NORMAL | HDFS,
	SHADOWMAN_HARD_FRESH_FILE_1_87 = IL.SHADOWMAN | Difficulty.HARD | FRESH_FILE | DOWNPATCHED,
	SHADOWMAN_HARD_FRESH_FILE_1_88 = IL.SHADOWMAN | Difficulty.HARD | FRESH_FILE,
	SHADOWMAN_HARD_NO_HDFS_1_87 = IL.SHADOWMAN | Difficulty.HARD | DOWNPATCHED,
	SHADOWMAN_HARD_NO_HDFS_1_88 = IL.SHADOWMAN | Difficulty.HARD,
	SHADOWMAN_HARD_HDFS_1_87 = IL.SHADOWMAN | Difficulty.HARD | HDFS | DOWNPATCHED,
	SHADOWMAN_HARD_HDFS_1_88 = IL.SHADOWMAN | Difficulty.HARD | HDFS,
}
# ==============================================================================
static var leaderboard_cache := {}
static var leaderboard_queue: Array[Category] = []

static var user_cache := {}
static var user_queue: PackedStringArray = []
# ==============================================================================

static func get_leaderboard(category: Category) -> Array[Dictionary]:
	var raw := await get_leaderboard_raw(category)
	if raw.is_empty():
		# no need to push an error; one should already be pushed in get_leaderboard_raw()
		return []
	
	var runs: Array[Dictionary] = []
	runs.append_array(raw.data.runs)
	return runs


static func get_leaderboard_raw(category: Category) -> Dictionary:
	if category in leaderboard_cache:
		return leaderboard_cache[category]
	if category in leaderboard_queue:
		while not category in leaderboard_cache:
			await Analyzer.get_tree().process_frame
		return leaderboard_cache[category]
	
	leaderboard_queue.append(category)
	
	var client := HTTPClient.new()
	var error := client.connect_to_host("https://www.speedrun.com")
	if error:
		push_error("Could not connect to the speedrun.com. Error: %s" % error_string(error))
		return {}
	
	while client.get_status() in [HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_RESOLVING]:
		client.poll()
		await Analyzer.get_tree().process_frame
	
	if not client.get_status() == HTTPClient.STATUS_CONNECTED:
		push_error("There was an error while trying to connect to the host.")
		return {}
	
	var headers: PackedStringArray = [
		"User-Agent: DemonCrawl Analyzer"
	]
	
	var url := get_category_link(category)
	error = client.request(HTTPClient.METHOD_GET, url, headers)
	if error:
		push_error("An error occured while trying to make an HTTP request to '%s': %s" % [url, error_string(error)])
		return {}
	
	while client.get_status() == HTTPClient.STATUS_REQUESTING:
		client.poll()
		await Analyzer.get_tree().process_frame
	
	if not client.get_status() in [HTTPClient.STATUS_BODY, HTTPClient.STATUS_CONNECTED]:
		push_error("There was an error while trying to retrieve an HTTP request from '%s'. Client status: ", [url, client.get_status()])
		return {}
	
	if not client.has_response():
		push_warning("No response from the API in the HTTP request to '%s'." % url)
		return {}
	
	var bytes: PackedByteArray = []
	
	while client.get_status() == HTTPClient.STATUS_BODY:
		client.poll()
		var chunk := client.read_response_body_chunk()
		if chunk.is_empty():
			await Analyzer.get_tree().process_frame
		bytes.append_array(chunk)
	
	var text := bytes.get_string_from_ascii()
	
	var leaderboard: Dictionary = JSON.parse_string(text)
	leaderboard_cache[category] = leaderboard
	leaderboard_queue.erase(category)
	
	return leaderboard


static func get_user(user_id: String, url: String) -> Dictionary:
	if user_id in user_cache:
		return user_cache[user_id]
	if user_id in user_queue:
		while not user_id in user_cache:
			await Analyzer.get_tree().process_frame
		return user_cache[user_id]
	
	user_queue.append(user_id)
	
	var client := HTTPClient.new()
	var error := client.connect_to_host("https://www.speedrun.com")
	if error:
		push_error("Could not connect to the speedrun.com. Error: %s" % error_string(error))
		return {}
	
	while client.get_status() in [HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_RESOLVING]:
		client.poll()
		await Analyzer.get_tree().process_frame
	
	if not client.get_status() == HTTPClient.STATUS_CONNECTED:
		push_error("There was an error while trying to connect to the host.")
		return {}
	
	var headers: PackedStringArray = [
		"User-Agent: DemonCrawl Analyzer"
	]
	
	error = client.request(HTTPClient.METHOD_GET, url, headers)
	if error:
		push_error("An error occured while trying to make an HTTP request to '%s': %s" % [url, error_string(error)])
		return {}
	
	while client.get_status() == HTTPClient.STATUS_REQUESTING:
		client.poll()
		await Analyzer.get_tree().process_frame
	
	if not client.get_status() in [HTTPClient.STATUS_BODY, HTTPClient.STATUS_CONNECTED]:
		push_error("There was an error while trying to retrieve an HTTP request from '%s'. Client status: ", [url, client.get_status()])
		return {}
	
	if not client.has_response():
		push_warning("No response from the API in the HTTP request to '%s'." % url)
		return {}
	
	var bytes: PackedByteArray = []
	
	while client.get_status() == HTTPClient.STATUS_BODY:
		client.poll()
		var chunk := client.read_response_body_chunk()
		if chunk.is_empty():
			await Analyzer.get_tree().process_frame
		bytes.append_array(chunk)
	
	var text := bytes.get_string_from_ascii()
	
	var user: Dictionary = JSON.parse_string(text)
	user_cache[user_id] = user
	user_queue.remove_at(user_queue.find(user_id))
	return user


static func get_user_name(user_id: String, url: String) -> String:
	var raw := await get_user(user_id, url)
	return raw.data.names.international


static func get_category(difficulty: Difficulty, il: IL = IL.DISABLED, hdfs: bool = false, fresh_file: bool = false, downpatched: bool = false) -> Category:
	var category_int := 0
	
	category_int |= difficulty
	category_int |= il
	if hdfs:
		category_int |= HDFS
	if fresh_file:
		category_int |= FRESH_FILE
	if downpatched:
		category_int |= DOWNPATCHED
	
	return category_int as Category


static func get_category_name(category: Category) -> String:
	var key: String = Leaderboards.Category.find_key(category)
	return key.capitalize().replace("1 88", "(1.88+)").replace("1 87", "(1.87)").replace("Hdfs", "HDFS").replace("Respites", "Respite's")


static func get_category_link(category: Category) -> String:
	if category & IL.ENABLED:
		var level := ""
		match get_category_level(category):
			IL.GLORY_DAYS:
				level = "xd182nyw"
			IL.RESPITES_END:
				level = "ewp0xl4d"
			IL.ANOTHER_WAY:
				level = "y9m1xn09"
			IL.AROUND_THE_BEND:
				level = "5wk163xd"
			IL.SHADOWMAN:
				level = "592nqy69"
		
		var difficulty := ""
		match get_category_difficulty(category):
			Difficulty.CASUAL:
				difficulty = "wkp1z6wk"
			Difficulty.CASUAL_RANDOM:
				difficulty = "mke9668d"
			Difficulty.NORMAL:
				difficulty = "5dw4wwek"
			Difficulty.HARD:
				difficulty = "wk6nllq2"
		
		var version := ""
		if category & DOWNPATCHED:
			version = "10v6vvwl"
		else:
			version = "qj7277eq"
		
		var quests := ""
		if category & FRESH_FILE:
			quests = "mlnr0e6q"
		elif category & HDFS:
			quests = "9qjj420q"
		else:
			quests = "8103m6j1"
		
		return "/api/v1/leaderboards/m1mxlq36/level/{level}/{difficulty}?var-p85pde3l={version}&var-wl30p1vl={quests}".format({
			"level": level,
			"difficulty": difficulty,
			"version": version,
			"quests": quests
		})
	
	var difficulty := ""
	match get_category_difficulty(category):
		Difficulty.CASUAL:
			difficulty = "5led8pz1"
		Difficulty.CASUAL_RANDOM:
			difficulty = "p123zykl"
		Difficulty.NORMAL:
			difficulty = "81p8nmkl"
		Difficulty.HARD:
			difficulty = "xqk78yyl"
	
	var quests := ""
	if category & HDFS:
		quests = "4qy3y73l"
	elif category & FRESH_FILE:
		quests = "21dry63q"
	else:
		quests = "5q8504rq"
	
	var version := ""
	if category & DOWNPATCHED:
		version = "10v6vvwl"
	else:
		version = "qj7277eq"
	
	return "/api/v1/leaderboards/m1mxlq36/category/wk6nyzx2?var-e8mr9ywl={difficulty}&var-2lgro3en={quests}&var-p85pde3l={version}".format({
		"difficulty": difficulty,
		"quests": quests,
		"version": version,
	})


static func get_category_difficulty(category: Category) -> Difficulty:
	for difficulty in Difficulty.values():
		if category & 0x70 == difficulty:
			return difficulty
	
	return Difficulty.CASUAL


static func get_category_level(category: Category) -> IL:
	if not category & IL.ENABLED:
		return IL.DISABLED
	
	for level in IL.values():
		if level in [IL.DISABLED, IL.ENABLED]:
			continue
		if category & 0xf == level:
			return level
	
	push_warning("Category %d (%s) was detected as an IL, but no IL matches the category's level." % [category, String.num_int64(category, 2)])
	return IL.DISABLED
