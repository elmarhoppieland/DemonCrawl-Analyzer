extends Package

# ==============================================================================
var quests: Array[Dictionary] = []
# ==============================================================================

func _init() -> void:
	use(LogFile.Line.PROFILE_LOADED)
	use(LogFile.Line.QUEST_START)
	use(LogFile.Line.QUEST_STAGE_BEGIN)


func load_history_view(selected_profile: String) -> void:
	quests.clear()
	
	var profile := ""
	for line in get_history():
		if line.type == LogFile.Line.PROFILE_LOADED:
			profile = line.params[0]
			continue
		if profile != selected_profile:
			continue
		match line.type:
			LogFile.Line.QUEST_START:
				var type_int := Quest.get_type_int(line.params[0])
				var quest := {
					"start_unix_time": line.unix_time,
					"type": type_int,
					"difficulty": line.params[1] + 1,
					"background_stage_name": "$%d" % int((type_int - int(type_int == Quest.Type.HERO_TRIALS)) / 4.0)
				}
				quests.append(quest)
			LogFile.Line.QUEST_STAGE_BEGIN:
				quests[-1].background_stage_name = line.params[0].split(" ")[-1]


func get_recent_quests_list(_selected_profile: String) -> Array[Dictionary]:
	return quests
