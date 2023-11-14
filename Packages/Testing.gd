extends Package

# ==============================================================================

func get_recent_quests_list(_selected_profile: String) -> Array[Dictionary]:
	return [{
		"start_unix_time": 0,
		"type": Quest.Type.ANOTHER_WAY,
		"difficulty": Quest.Difficulty.NORMAL,
		"background_stage_name": "Birthday"
	}]
