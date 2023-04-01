extends Control
class_name WinsProfile

## A tab for the [Wins] scene.

# ==============================================================================
@onready var tree: Tree = %Tree
# ==============================================================================

func populate_tree(profile: Profile) -> void:
	populate_global_tree([profile])


func populate_global_tree(profiles: Array[Profile]) -> void:
	var root := tree.create_item()
	
	var masteries: PackedStringArray = []
	var win_counts := {}
	var loss_counts := {}
	for profile in profiles:
		for quest in profile.quests:
			if not quest.mastery in masteries:
				masteries.append(quest.mastery)
				win_counts[quest.mastery] = 0
				loss_counts[quest.mastery] = 0
			if quest.victory:
				win_counts[quest.mastery] += 1
			else:
				loss_counts[quest.mastery] += 1
	
	for mastery in masteries:
		var mastery_item := root.create_child()
		mastery_item.set_text(0, "No Mastery" if mastery.is_empty() else mastery)
		mastery_item.set_text(1, "Wins: %d" % win_counts[mastery])
		mastery_item.set_text(2, "Losses: %d" % loss_counts[mastery])
		mastery_item.set_text(3, "%d" % roundi(win_counts[mastery] / float(win_counts[mastery] + loss_counts[mastery]) * 100) + "%")
