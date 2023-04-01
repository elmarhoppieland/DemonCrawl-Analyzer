extends Control

# ==============================================================================
const WINS_PROFILE_SCENE := preload("res://Statistics/Wins/WinsProfile.tscn")
# ==============================================================================
@onready var global: Control = %Global
# ==============================================================================

func _ready() -> void:
	create_tabs()


func create_tabs() -> void:
	var profiles: Array[Profile] = owner.get_profiles()
	
	for profile in profiles:
		if not profile.quests.is_empty():
			var profile_tab := WINS_PROFILE_SCENE.instantiate()
			$TabContainer.add_child(profile_tab)
			
			profile_tab.name = profile.name
			
			profile_tab.populate_tree(profile)
	
	global.populate_global_tree(profiles)
