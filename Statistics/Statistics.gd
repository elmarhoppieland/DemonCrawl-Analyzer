extends TabContainer

# ==============================================================================
enum LogError {
	UNKNOWN = -1, ## Unknown error.
	OK, ## No error.
	EOF_REACHED, ## End of file reached.
	PLAYER_DIED, ## Player died.
	QUEST_COMPLETE ## Quest complete.
}
# ==============================================================================
var default_log_dir := OS.get_data_dir().get_base_dir().path_join("Local/demoncrawl/logs")

var profiles := {}

var previous_read_quest: Quest = null

var current_profile: Profile
# ==============================================================================

func _enter_tree() -> void:
	current_tab = 0
	
	read_logs_dir()


func read_logs_dir() -> void:
	for index in range(1, 101):
#		var error := read_log("log%s.txt" % index, previous_read_quest)
		var error := read_log2("log%s.txt" % index)
		if error != LogError.EOF_REACHED:
			return


func read_log2(log_name: String) -> LogError:
	var log_reader := LogFileReader.read(default_log_dir.path_join(log_name))
	
	log_reader.next_line()
	
	while not log_reader.get_current_line().is_empty():
		parse_line(log_reader)
		
		log_reader.next_line()
	
	return LogError.EOF_REACHED


func parse_line(log_reader: LogFileReader) -> void:
	var data := log_reader.handle_current_line(LogFileReader.Line.ALL, current_profile)
	if data is Profile:
		if data.name in profiles:
			current_profile = profiles[data.name]
		else:
			profiles[data.name] = data
			current_profile = data


func read_log(log_name: String, quest: Quest = null) -> LogError:
	var log_reader := LogFileReader.read(default_log_dir.path_join(log_name))
	
	var profile := log_reader.get_next_profile()
	while true:
		var line := log_reader.look_for(
			LogFileReader.Line.PROFILE_LOAD |
			LogFileReader.Line.QUEST_CREATE |
			LogFileReader.Line.STAGE_BEGIN |
			LogFileReader.Line.STAGE_LEAVE |
			LogFileReader.Line.ITEM_LOSE |
			LogFileReader.Line.ITEM_GAIN |
			LogFileReader.Line.PLAYER_DEATH
		)
		
		if line.is_empty():
			return LogError.EOF_REACHED
		
		if line.begins_with("Profile loaded: "):
			profile = log_reader.get_next_profile()
			if profile:
				if profile.name in profiles:
					profiles[profile.name].quests.append_array(profile.quests)
					profile = profiles[profile.name]
				else:
					profiles[profile.name] = profile
			
			continue
		
		if line.begins_with("Quest started: "):
			read_quest(log_reader, profile)
			continue
		
		if line.match("* was added to inventory slot #*"):
			var lines := log_reader.get_current_timestamp_lines()
			for i in lines:
				if LogFileReader.get_line_type(i) == LogFileReader.Line.QUEST_CREATE:
					var read_position := log_reader.file.get_position()
					# ! -- ERROR IGNORE -- !
#					log_reader.look_for([i], LogFileReader.Line.QUEST_CREATE)
					log_reader.file.seek(read_position)
		
		if line.begins_with("Begin stage ")\
		or line.begins_with("Leaving stage ")\
		or line.match("* was removed from inventory slot #*")\
		or line.match("* was added to inventory slot #*")\
		or line.match("* was killed!"):
			# the quest was reloaded
			read_quest(log_reader, profile, quest)
			continue
	
	return LogError.UNKNOWN


func read_quest(log_reader: LogFileReader, profile: Profile, quest: Quest = null) -> LogError:
	if not quest:
		quest = log_reader.get_next_quest(profile)
		if not quest:
			return LogError.EOF_REACHED
		
#		profile.quests.append(quest)
		
		# ! -- ERROR IGNORE -- !
#		var line := log_reader.look_for(["Mastery selected: *"])
		var line := ""
		quest.mastery = line.trim_prefix("Mastery selected: ").get_slice(" ", 0).capitalize()
		@warning_ignore("int_as_enum_without_cast")
		quest.mastery_tier = line[-1].to_int()
	
	previous_read_quest = quest
	
	var inventory := quest.inventory
	
	if not quest.stages.is_empty() and not quest.stages[-1].exit:
		var error := handle_stage_exit(log_reader, quest.stages[-1], inventory, profile)
		if error:
			return error
	
	while true:
		var stage := log_reader.get_next_stage(inventory, profile)
		if stage:
			quest.stages.append(stage)
			
			var error := handle_stage_exit(log_reader, stage, inventory, profile)
			if error:
				return error
			
			continue
		
		var error := get_error(log_reader.get_current_line())
		if error > 0:
			return error
		
		return LogError.UNKNOWN
	
	return LogError.UNKNOWN


func handle_stage_exit(log_reader: LogFileReader, stage: Stage, inventory: Inventory, profile: Profile = null) -> LogError:
	var stage_exit := log_reader.get_next_stage_exit(profile)
	if stage_exit:
		stage.exit = stage_exit
		return LogError.OK
	
	var error := get_error(log_reader.get_current_line())
	if error > 0:
		if error == LogError.PLAYER_DIED:
			stage.death = StageExit.new()
			stage.death.inventory = inventory.duplicate()
		
		return error
	
	return LogError.UNKNOWN


func get_profile(profile_name: String) -> Profile:
	var profile = profiles[profile_name]
	if profile is Profile:
		return profile
	
	return null


func get_profiles() -> Array[Profile]:
	var profile_array: Array[Profile] = []
	
	for profile in profiles.values():
		if profile is Profile:
			profile_array.append(profile)
	
	return profile_array


func get_error(line: String) -> LogError:
	if line.is_empty():
		return LogError.EOF_REACHED
	if line.match("* was killed!"):
		return LogError.PLAYER_DIED
	if line == "Alert: Submitting score to Leaderboard...":
		return LogError.QUEST_COMPLETE
	
	return LogError.OK
