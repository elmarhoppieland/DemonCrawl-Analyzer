# HistoryLoader

## Methods

### void history_load_batch(batch: HistoryFile.Batch)
Is called when loading a batch from the player's HistoryFile. A batch is a set of lines that occured
in the same second.
The method's argument 'batch' is mutable. This means changing anything in the batch (such as the order
of lines) will affect in what order the lines are processed. Note that this also changes in what order
the lines are process in other packages.


### void history_load_line(line: HistoryFile.LineData)
Is called when loading a line from the player's HistoryFile.
The method's argument 'line' is mutable. This means changing anything in the line will affect in what
order the lines are processed. Note that this also changes in what order the lines are process in other
packages.


### bool history_load_line_keep(line: HistoryFile.LineData)
Is called when loading a line from the player's HistoryFile, after calling history_load_line().
Should return whether this line should be kept in memory. If at least 1 package return true for a line,
the line is kept in memory.


# HistoryView

## Methods

### void load_history_view(selected_profile: String)
Is called when the HistoryView is loaded.

### void build_recent_quests_list(selected_profile: String)
Is called when building the player's recent quests list.

### Array[Dictionary] get_recent_quests_list(selected_profile: String)
Returns an Array of Dictionaries containing data about quests that should appear in the HistoryView.
Each Dictionary can contain the following keys (case-sensitive):
- int start_unix_time (required): The Unix timestamp of the quest.
- int type (required): The type of the quest. Use Quest.Type.* to specify the type. Possible values:
	Quest.Type.GLORY_DAYS, Quest.Type.RESPITES_END, Quest.Type.ANOTHER_WAY, Quest.Type.AROUND_THE_BEND,
	Quest.Type.SHADOWMAN Quest.Type.ENDLESS_MULTIVERSE, Quest.Type.HERO_TRIALS, Quest.Type.BEYOND
- int difficulty (required): The difficulty of the quest. Use Quest.Difficulty.* to specify the difficulty.
	Possible values: Quest.Difficulty.CASUAL, Quest.Difficulty.NORMAL, Quest.Difficulty.HARD,
	Quest.Difficulty.BEYOND
- String background_stage_name (required): The name of the stage to be used for the background image
	of the quest.
- bool exclude (optional): If true, the quest with the specified 'start_unix_time' will be excluded from
	the HistoryView.
Note: The list of possible keys will be expanded in the future.

### void build_profile_miniview(selected_profile: String)
Is called when building the selected profile's miniview.

### Texture2D get_profile_icon(selected_profile: String)
Is called when obtaining the selected profile's icon in the miniview. Should return the icon to be used.

### int get_profile_max_xp(selected_profile: String)
Should return the amount of xp needed to level up.

### int get_profile_xp(selected_profile: String)
Should return the current xp value of the selected profile.
