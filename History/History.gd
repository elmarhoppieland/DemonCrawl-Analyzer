extends Control

# ==============================================================================

func _ready() -> void:
	populate_tree()


func populate_tree() -> void:
	var tree: Tree = $Tree
	
	tree.clear()
	
	var root := tree.create_item()
	
	var profiles: Array[Profile] = owner.get_profiles()
	for profile in profiles:
		if profile.quests.is_empty():
			continue
		
		var profile_item := root.create_child()
		profile_item.set_text(0, profile.name)
		profile_item.collapsed = true
		
		for quest in profile.quests:
			var quest_item := profile_item.create_child(0)
			quest_item.set_text(0, quest.name)
			quest_item.set_text(1, quest.creation_timestamp + "  ")
			quest_item.collapsed = true
			
			quest_item.create_child().set_text(0, "Victory: %s" % ("Yes" if quest.victory else "No"))
			
			add_mastery(quest.mastery, quest.mastery_tier, quest_item)
			
			for stage in quest.stages:
				add_stage(stage, quest_item)


func add_mastery(mastery: String, tier: int, parent_item: TreeItem) -> void:
	var mastery_item := parent_item.create_child()
	mastery_item.set_text(0, "Mastery: %s tier %s" % [mastery, tier])


func add_stage(stage: Stage, parent_item: TreeItem) -> void:
	var stage_item := parent_item.create_child()
	stage_item.set_text(0, stage.full_name)
	stage_item.collapsed = true
	
	var stage_enter_item := stage_item.create_child()
	stage_enter_item.set_text(0, "Enter")
	stage_enter_item.collapsed = true
	
	stage_enter_item.create_child().set_text(0, str(stage.enter.stats))
	
	add_inventory(stage.enter.inventory, stage_enter_item)
	
	if stage.exit:
		var stage_exit_item := stage_item.create_child()
		stage_exit_item.set_text(0, "Exit")
		stage_exit_item.collapsed = true
		
		add_inventory(stage.exit.inventory, stage_exit_item)
	if stage.death:
		var stage_death_item := stage_item.create_child()
		stage_death_item.set_text(0, "Death")
		stage_death_item.collapsed = true
		
		add_inventory(stage.death.inventory, stage_death_item)
	if not stage.time_spent.is_empty():
		stage_item.create_child(0).set_text(0, "Time spent: %s" % stage.time_spent)


func add_inventory(inventory: Inventory, parent_item: TreeItem) -> void:
	var inventory_item := parent_item.create_child()
	inventory_item.set_text(0, "Inventory")
	inventory_item.collapsed = true
	
	for i in inventory.items.size():
		var item := inventory.items[i]
		if not item.is_empty():
			inventory_item.create_child().set_text(0, "%s. %s" % [i + 1, item])
