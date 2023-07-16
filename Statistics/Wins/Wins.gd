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
@onready var graph: WinsGraph = %Graph
# ==============================================================================

func _ready() -> void:
	load_thread.start(_create_tabs)
	
	ProfileLoader.profiles_updated.connect(func(_new_profiles):
		print("Recieved.")
		_create_tabs(Statistics.get_filters())
	)


func _process(_delta: float) -> void:
	if load_thread.is_started() and not load_thread.is_alive():
		load_thread.wait_to_finish()


func _create_tabs(filters: Dictionary = {}) -> void:
	var profiles := ProfileLoader.get_used_profiles()
	
	for child in $TabContainer.get_children():
		if not child in [_global, graph]:
			child.queue_free()
			profile_tabs.erase(child.name)
	
	for profile in profiles:
		var profile_tab: WinsProfile
		if profile.name in profile_tabs:
			profile_tab = profile_tabs[profile.name]
		else:
			profile_tab = _WINS_PROFILE_SCENE.instantiate()
			profile_tabs[profile.name] = profile_tab
			$TabContainer.add_child.call_deferred(profile_tab)
		
		profile_tab.name = profile.name
		
		profile_tab.populate_tree.call_deferred(profile, filters)
	
	_global.populate_global_tree(profiles, filters)


func _on_filters_saved(filters: Dictionary) -> void:
	load_thread.start(_create_tabs.bind(filters))
	
	graph._on_filters_saved(filters)


static func get_tab() -> Wins:
	return Analyzer.get_tab(Analyzer.Tab.WINS)


func _exit_tree() -> void:
	if load_thread.is_started():
		load_thread.wait_to_finish()
