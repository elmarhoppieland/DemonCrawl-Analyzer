extends Control
class_name Wins

## A scene that shows the player's wins per mastery per profile.

# ==============================================================================
const _WINS_PROFILE_SCENE := preload("res://Statistics/Wins/WinsProfile.tscn")
# ==============================================================================
@onready var _global: WinsProfile = %Global
# ==============================================================================

func _ready() -> void:
	_create_tabs()


func _create_tabs() -> void:
	var profiles: Array[Profile] = owner.get_profiles()
	
	for profile in profiles:
		if not profile.quests.is_empty():
			var profile_tab: WinsProfile = _WINS_PROFILE_SCENE.instantiate()
			$TabContainer.add_child(profile_tab)
			
			profile_tab.name = profile.name
			
			profile_tab.populate_tree(profile)
	
	_global.populate_global_tree(profiles)
