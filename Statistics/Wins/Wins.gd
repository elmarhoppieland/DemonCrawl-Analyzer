extends Control
class_name Wins

## A scene that shows the player's wins per mastery per profile.

# ==============================================================================
const _WINS_PROFILE_SCENE := preload("res://Statistics/Wins/WinsProfile.tscn")
# ==============================================================================
var profile_tabs := {}

var load_thread := Thread.new()
# ==============================================================================
@onready var _global: WinsProfile = %Global
@onready var _graph: WinsGraph = %Graph
@onready var main: Statistics = owner
# ==============================================================================

func _ready() -> void:
	load_thread.start(_create_tabs)


func _process(_delta: float) -> void:
	if load_thread.is_started() and not load_thread.is_alive():
		load_thread.wait_to_finish()


func _create_tabs(filters: Dictionary = {}) -> void:
	var profiles: Array[Profile] = ProfileLoader.get_used_profiles()
	
	for profile in profiles:
		if not profile.quests.is_empty():
			var profile_tab: WinsProfile
			if profile.name in profile_tabs:
				profile_tab = profile_tabs[profile.name]
			else:
				profile_tab = _WINS_PROFILE_SCENE.instantiate()
				profile_tabs[profile.name] = profile_tab
				$TabContainer.add_child(profile_tab)
			
			profile_tab.name = profile.name
			
			profile_tab.populate_tree(profile, filters)
	
	_global.populate_global_tree(profiles, filters)


func _on_filters_saved(filters: Dictionary) -> void:
	load_thread.start(_create_tabs.bind(filters))
	_graph._on_filters_saved(filters)


func _exit_tree() -> void:
	if load_thread.is_started():
		load_thread.wait_to_finish()
