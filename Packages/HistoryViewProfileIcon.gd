extends Package

# ==============================================================================
var mastery := ""
var tier := -1
# ==============================================================================

func _init() -> void:
	use(LogFile.Line.PROFILE_LOADED)
	use(LogFile.Line.QUEST_MASTERY_SELECTED)


func load_history_view(selected_profile: String) -> void:
	var profile := ""
	for event in get_history():
		match event.type:
			LogFile.Line.PROFILE_LOADED:
				profile = event.params[0]
			LogFile.Line.QUEST_MASTERY_SELECTED:
				if profile == selected_profile:
					mastery = event.params[0]
					tier = event.params[1]


func get_profile_icon(_selected_profile: String) -> Texture2D:
	return Mastery.get_icon(mastery)
