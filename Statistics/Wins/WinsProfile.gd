extends Control
class_name WinsProfile

## A tab for the [Wins] scene.

# ==============================================================================
## The [Tree] containing the masteries the player uses.
@onready var tree: Tree = %Tree
# ==============================================================================

## Populates the [member tree] with masteries used in [code]profile[/code].
func populate_tree(profile: Profile) -> void:
	populate_global_tree([profile])


## Populates the [member tree] with masteries used in any [Profile] in [code]profiles[/code].
func populate_global_tree(profiles: Array[Profile]) -> void:
	var root := tree.create_item()
	
	var masteries: PackedStringArray = []
	var win_counts := {}
	var loss_counts := {}
	
	var total_wins := 0
	var total_losses := 0
	
	for profile in profiles:
		for quest in profile.quests:
			if not quest.mastery in masteries:
				masteries.append(quest.mastery)
				win_counts[quest.mastery] = 0
				loss_counts[quest.mastery] = 0
			if quest.victory:
				win_counts[quest.mastery] += 1
				total_wins += 1
			else:
				loss_counts[quest.mastery] += 1
				total_losses += 1
	
	for mastery in masteries:
		var mastery_item := root.create_child()
		mastery_item.set_text(0, "No Mastery" if mastery.is_empty() else mastery)
		mastery_item.set_text(1, "Wins: %d" % win_counts[mastery])
		mastery_item.set_text(2, "Losses: %d" % loss_counts[mastery])
		mastery_item.set_text(3, "%d" % roundi(win_counts[mastery] / float(win_counts[mastery] + loss_counts[mastery]) * 100) + "%")
		mastery_item.set_icon(0, Mastery.get_icon(mastery))
	
	var total_item := root.create_child()
	total_item.set_text(0, "Total")
	total_item.set_text(1, "Wins: %d" % total_wins)
	total_item.set_text(2, "Losses: %d" % total_losses)
	total_item.set_text(3, "%d" % roundi(total_wins / float(total_wins + total_losses) * 100) + "%")
