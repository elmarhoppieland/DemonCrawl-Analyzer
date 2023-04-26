extends Control
class_name History

# ==============================================================================
var item_data := {}
var load_thread := Thread.new()
# ==============================================================================
@onready var main: Statistics = owner
@onready var tree: Tree = $Tree
# ==============================================================================

func _ready() -> void:
	load_thread.start(populate_tree)


func _process(_delta: float) -> void:
	if load_thread.is_started() and not load_thread.is_alive():
		load_thread.wait_to_finish()


func populate_tree(filters: Dictionary = {}) -> void:
	tree.clear()
	
	var root := tree.create_item()
	
	var profiles: Array[Profile] = ProfileLoader.get_used_profiles()
	for profile in profiles:
		if profile.quests.is_empty():
			continue
		
		var profile_item := root.create_child()
		profile_item.set_text(0, profile.name)
		profile_item.collapsed = true
		profile_item.set_tooltip_text(0, " ")
		
		for quest in profile.quests:
			if not quest.matches_filters(filters):
				continue
			
			add_quest(quest, profile_item)


func add_quest(quest: Quest, parent_item: TreeItem) -> void:
	var quest_item := parent_item.create_child(0)
	quest_item.set_text(0, quest.name)
	quest_item.set_tooltip_text(0, " ")
	quest_item.set_text(1, quest.creation_timestamp + "  ")
	quest_item.set_tooltip_text(1, " ")
	quest_item.collapsed = true
	
	var victory_item := quest_item.create_child()
	victory_item.set_text(0, "Victory: %s" % ("Yes" if quest.victory else "No"))
	victory_item.set_tooltip_text(0, " ")
	
	add_mastery(quest.mastery, quest.mastery_tier, quest_item)
	
	if OS.is_debug_build():
		var type_int_item := quest_item.create_child()
		type_int_item.set_text(0, "Type Int: %s" % quest.type)
		type_int_item.set_tooltip_text(0, " ")
	
	for stage in quest.stages:
		add_stage(stage, quest_item)


func add_mastery(mastery: String, tier: int, parent_item: TreeItem) -> void:
	var mastery_item := parent_item.create_child()
	mastery_item.set_text(0, "Mastery: %s tier %s" % [mastery, tier])


func add_stage(stage: Stage, parent_item: TreeItem) -> void:
	var stage_item := parent_item.create_child()
	stage_item.set_text(0, stage.full_name)
	stage_item.set_tooltip_text(0, " ")
	stage_item.collapsed = true
	
	var stage_enter_item := stage_item.create_child()
	stage_enter_item.set_text(0, "Enter")
	stage_enter_item.set_tooltip_text(0, " ")
	stage_enter_item.collapsed = true
	
	var stats_item := stage_enter_item.create_child()
	stats_item.set_text(0, str(stage.enter.stats))
	stats_item.set_tooltip_text(0, " ")
	
	add_inventory(stage.enter.inventory, stage_enter_item)
	
	if stage.exit:
		var stage_exit_item := stage_item.create_child()
		stage_exit_item.set_text(0, "Exit")
		stage_exit_item.set_tooltip_text(0, " ")
		stage_exit_item.collapsed = true
		
		add_inventory(stage.exit.inventory, stage_exit_item)
	if stage.death:
		var stage_death_item := stage_item.create_child()
		stage_death_item.set_text(0, "Death")
		stage_death_item.set_tooltip_text(0, " ")
		stage_death_item.collapsed = true
		
		add_inventory(stage.death.inventory, stage_death_item)
	if not stage.time_spent.is_empty():
		var time_spent_item := stage_item.create_child(0)
		time_spent_item.set_text(0, "Time spent: %s" % stage.time_spent)
		time_spent_item.set_tooltip_text(0, " ")


func add_inventory(inventory: Inventory, parent_item: TreeItem) -> void:
	var inventory_item := parent_item.create_child()
	inventory_item.set_text(0, "Inventory")
	inventory_item.set_tooltip_text(0, " ")
	inventory_item.set_meta("inventory", inventory)
	inventory_item.collapsed = true
	
	for i in inventory.items.size():
		var item := inventory.items[i]
		if not item.is_empty():
			var item_item := inventory_item.create_child()
			item_item.set_text(0, "%s. %s" % [i + 1, item])
			item_item.set_tooltip_text(0, " ")
			
#			DemonCrawlWiki.request_item_data(item, func(data: Dictionary): item_item.set_icon(0, data.icon))


func _on_filters_saved(filters: Dictionary) -> void:
	load_thread.start(populate_tree.bind(filters))


func _on_tree_item_collapsed(item: TreeItem) -> void:
	if not item.collapsed and item.get_text(0) == "Inventory":
		var inventory: Inventory = item.get_meta("inventory")
		for index in item.get_child_count():
			var item_item := item.get_child(index)
			if item_item.get_icon(0):
				continue
			
			var item_name := inventory.items[index]
			
			if item_name in item_data:
				item_item.set_icon(0, item_data[item_name].icon)
				continue
			
			DemonCrawlWiki.request_item_data(item_name, func(data: Dictionary):
				data.icon.set_size_override(Vector2i(16, 16))
				item_item.set_icon(0, data.icon)
				item_data[item_name] = data
			)


func _exit_tree() -> void:
	if load_thread.is_started():
		load_thread.wait_to_finish()
