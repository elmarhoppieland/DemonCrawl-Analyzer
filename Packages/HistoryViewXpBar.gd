extends Package

# ==============================================================================
var profiles := {}
# ==============================================================================

func _init() -> void:
	used_line_types.append_array([LogFile.Line.CLOUD_PROGRESS_CHECK, LogFile.Line.PROFILE_LOADED])


func load_history_view(_selected_profile: String) -> void:
	profiles.clear()
	
	var profile := ""
	for event in get_history():
		match event.type:
			LogFile.Line.PROFILE_LOADED:
				profile = event.params[0]
			LogFile.Line.CLOUD_PROGRESS_CHECK:
				var max_xp := 2071230
				profiles[profile] = {
					"xp": event.params[1],
					"max_xp": max_xp
				}


func get_profile_max_xp(selected_profile: String) -> int:
	return profiles[selected_profile].max_xp


func get_profile_xp(selected_profile: String) -> int:
	return profiles[selected_profile].xp
