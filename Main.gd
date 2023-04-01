extends Control

# ==============================================================================
var default_log_dir := OS.get_data_dir().get_base_dir().path_join("Local/demoncrawl/logs")
# ==============================================================================
@onready var _error_label: Label = %ErrorLabel
# ==============================================================================

func _ready() -> void:
	get_window().files_dropped.connect(func(files: PackedStringArray):
		if files.size() == 1:
			var path := files[0]
			if not is_log_path_valid(path):
				parse_error("Please drop a valid log.txt file.")
				return
			
			parse_log_file(path)
		else:
			parse_error("Please drop a single file.")
	)
	
	$Panel/VBoxContainer/Button2.pressed.connect(SceneHandler.switch_scene.bind(preload("res://Statistics/Statistics.tscn")))


func select_file() -> void:
	$Panel/FileDialog.size = get_window().size * 2/3
	$Panel/FileDialog.popup_centered()
	$Panel/FileDialog.current_dir = default_log_dir


## Parses the log file at [code]log_path[/code] and shows its contents in the [Tree].
func parse_log_file(log_path: String) -> void:
	if not is_log_path_valid(log_path):
		parse_error("Please drop a valid log.txt file.")
		return
	
	$Panel/VBoxContainer.hide()
	
	var tree: Tree = $Panel/Tree
	tree.show()
	$Panel/MarginContainer.show()
	
	tree.clear()
	
	var log_reader := LogFileReader.read(log_path)
	
	var line := log_reader.get_line()
	if line != "DemonCrawl started":
		tree.hide()
		$Panel/VBoxContainer.show()
		
		parse_error("The log file is damaged.")
		return
	
	var root := tree.create_item()
	root.set_text(0, log_path.get_file())
	
	var profile_name := ""
	var profile_item: TreeItem
	
	var quest_name := ""
	var quest_item: TreeItem
	var quest_start_timestamp := ""
	
	var mastery := ""
	var mastery_item: TreeItem
	
	var inventory := PackedStringArray()
	
	var stage := ""
	var stage_item: TreeItem
	var stage_enter_item: TreeItem
	var stage_exit_item: TreeItem
	
	while line != "":
		line = log_reader.get_line()
		
		if line.begins_with("Profile loaded: "):
			profile_name = line.trim_prefix("Profile loaded: ")
		elif line.begins_with("Quest started: "):
			if not profile_item or profile_item.get_text(0) != profile_name:
				profile_item = root.create_child()
				profile_item.set_text(0, profile_name)
			
			if quest_item and quest_start_timestamp != "":
				quest_item.create_child(1).set_text(0, "Duration: %s minutes" % roundi(TimeHelper.get_passed_seconds(quest_start_timestamp, log_reader.get_timestamp()) / 60.0))
			
			quest_name = line.trim_prefix("Quest started: ")
			quest_item = profile_item.create_child()
			quest_item.set_text(0, "%s (%s)" % [quest_name, log_reader.get_timestamp()])
			
			quest_item.collapsed = true
			
			inventory = []
			quest_start_timestamp = log_reader.get_timestamp()
		elif line.begins_with("Mastery selected: "):
			mastery = line.trim_prefix("Mastery selected: ")
			mastery_item = quest_item.create_child()
			mastery_item.set_text(0, "Mastery: %s" % mastery)
		elif line.begins_with("Begin stage "):
			stage = line.trim_prefix("Begin stage ")
			
			if not quest_item:
				var returned := add_reloaded_quest(root, profile_name)
				
				profile_item = returned[0]
				quest_item = returned[1]
			
			stage_item = quest_item.create_child()
			stage_item.set_text(0, stage)
			
			stage_item.collapsed = true
			
			stage_enter_item = stage_item.create_child()
			stage_enter_item.set_text(0, "Enter")
			
			stage_enter_item.collapsed = true
			
			add_inventory(inventory, stage_enter_item)
		elif line.begins_with("Leaving stage "):
			if not quest_item:
				var returned := add_reloaded_quest(root, profile_name)
				profile_item = returned[0]
				quest_item = returned[1]
				
				stage_item = quest_item.create_child()
				stage = line.trim_prefix("Leaving stage ")
				stage_item.set_text(0, stage)
			
			stage_exit_item = stage_item.create_child()
			stage_exit_item.set_text(0, "Exit")
			
			stage_exit_item.collapsed = true
			
			add_inventory(inventory, stage_exit_item)
			
			stage_item = null
		elif line.match("* was added to inventory slot #*"):
			var split := line.split(" ", false)
			
			var item_name := ""
			for word in split:
				if word == "was":
					break
					
				if item_name != "":
					item_name += " "
				
				item_name += word
				
			inventory.append(item_name)
		elif line.match("* was removed from inventory slot #*"):
			var index := line.split(" ", false)[-1].trim_prefix("#").to_int() - 1
			
			while index >= inventory.size():
				inventory.insert(0, "")
			
			inventory.remove_at(index)
		elif line.begins_with("Player stats: "):
			var player_stats_item := stage_enter_item.create_child()
			player_stats_item.set_text(0, line)
		elif line == "DemonCrawl closed" or line == "Alert: Submitting score to Leaderboard...":
			if quest_item:
				if quest_start_timestamp != "":
					quest_item.create_child(1).set_text(0, "Duration: %s minutes" % roundi(TimeHelper.get_passed_seconds(quest_start_timestamp, log_reader.get_timestamp()) / 60.0))
				
				quest_item = null
		elif line.match("Completed stage * in * seconds"):
			if stage_item:
				stage_item.create_child(0).set_text(0, "Time spent: %s seconds" % line.split(" ")[-2])
		elif line.match("* was killed!"):
			if not quest_item:
				var returned := add_reloaded_quest(root, profile_name)
				profile_item = returned[0]
				quest_item = returned[1]
				
				stage_item = quest_item.create_child()
				stage = line.trim_prefix("Leaving stage ")
				stage_item.set_text(0, stage)
			
			stage_exit_item = stage_item.create_child()
			stage_exit_item.set_text(0, "Death")
			
			stage_exit_item.collapsed = true
			
			add_inventory(inventory, stage_exit_item)
			
			stage_item = null
			
			if quest_start_timestamp != "":
				quest_item.create_child(1).set_text(0, "Duration: %s minutes" % roundi(TimeHelper.get_passed_seconds(quest_start_timestamp, log_reader.get_timestamp()) / 60.0))
			
			quest_item = null


## Adds the player's [code]inventory[/code] as [TreeItem]s as children of [code]parent_item[/code].
func add_inventory(inventory: PackedStringArray, parent_item: TreeItem) -> void:
	var inventory_item := parent_item.create_child()
	if inventory:
		inventory_item.set_text(0, "Inventory")
	else:
		inventory_item.set_text(0, "Inventory is empty")
	
	inventory_item.collapsed = true
	
	if "" in inventory:
		inventory_item.create_child().set_text(0, "-- Some items may be missing --")
	
	for item_name in inventory:
		if item_name == "":
			continue
		
		var item := inventory_item.create_child()
		item.set_text(0, item_name)


## Adds a reloaded quest as a child of [code]root[/code].
func add_reloaded_quest(root: TreeItem, profile_name: String) -> Array[TreeItem]:
	var items: Array[TreeItem] = [null, null]
	
	items[0] = root.create_child()
	items[0].set_text(0, profile_name)
	
	items[1] = items[0].create_child()
	items[1].set_text(0, "Reloaded quest (limited or incomplete information)")
	
	return items


## Parses an error and displays it to the user.
func parse_error(error_text: String) -> void:
	_error_label.text = error_text
	
	$Panel/Tree.clear()
	$Panel/Tree.hide()
	$Panel/MarginContainer.hide()
	
	$Panel/VBoxContainer.show()


## Removes any errors that are displayed.
func remove_error() -> void:
	_error_label.text = ""


## Returns whether [code]path[/code] leads to a log file.
func is_log_path_valid(path: String) -> bool:
	if not path.is_absolute_path():
		return false
	
	if not path.get_file().match("log*.txt"):
		return false
	
	return true
