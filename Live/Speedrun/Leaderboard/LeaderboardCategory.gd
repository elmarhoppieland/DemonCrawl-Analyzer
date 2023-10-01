@tool
extends VBoxContainer
class_name LeaderboardCategory

# ==============================================================================
@export var category := Leaderboards.Category.CASUAL_NO_HDFS_1_88 :
	set(value):
		category = value
		
		if title_label:
			var key: String = Leaderboards.Category.find_key(value)
			title_label.text = key.capitalize().replace("1 88", "(1.88+)").replace("1 87", "(1.87)").replace("Hdfs", "HDFS").replace("Respites", "Respite's")
@export var difficulty := Leaderboards.Difficulty.CASUAL :
	set(value):
		difficulty = value
		category = difficulty | single_quest | category_flags as Leaderboards.Category
@export var single_quest := Leaderboards.IL.DISABLED :
	set(value):
		if value != Leaderboards.IL.ENABLED:
			single_quest = value
			category = difficulty | single_quest | category_flags as Leaderboards.Category
@export_flags("HDFS:128", "Fresh File:256", "Downpatched:512") var category_flags := 0 :
	set(value):
		if not (value & Leaderboards.HDFS and value & Leaderboards.FRESH_FILE):
			category_flags = value
			category = difficulty | single_quest | category_flags as Leaderboards.Category
# ==============================================================================
@onready var title_label: Label = %TitleLabel
@onready var leaderboard_label: RichTextLabel = %LeaderboardLabel
# ==============================================================================

func _ready() -> void:
	title_label.text = Leaderboards.get_category_name(category)
	
	if Engine.is_editor_hint():
		return
	
	var leaderboard := await Leaderboards.get_leaderboard(category)
	
	if leaderboard.is_empty():
		return
	
	leaderboard_label.text = "[center]"
	
	leaderboard_label.visible_characters = 0
	var filled_lines := 0
	var max_lines: int = leaderboard[-1].place
	
	for run in leaderboard:
		leaderboard_label.text += "%d. [url=%s][color={%d-color}]{%d-name}[/color][/url]\n" % [
			run.place,
			run.run.weblink,
			run.place,
			run.place
		]
		
		add_run(run)
	
	leaderboard_label.text = leaderboard_label.text.strip_edges()
	
	while filled_lines < max_lines:
		while "{" in leaderboard_label.text.get_slice("\n", filled_lines):
			await get_tree().process_frame
		
		leaderboard_label.visible_characters += leaderboard_label.text.get_slice("\n", filled_lines).length()
		filled_lines += 1


func add_run(run: Dictionary) -> void:
	var player: Dictionary = run.run.players[0]
	var player_data := await Leaderboards.get_user(player.id, player.uri)
	
	var color := ""
	if player_data.data["name-style"].style == "gradient":
		color = player_data.data["name-style"]["color-from"].light
	
	leaderboard_label.text = leaderboard_label.text.format({
		"%d-color" % run.place: color,
		"%d-name" % run.place: await Leaderboards.get_user_name(player.id, player.uri)
	})


func _on_leaderboard_label_meta_clicked(meta: String) -> void:
	OS.shell_open(meta)
