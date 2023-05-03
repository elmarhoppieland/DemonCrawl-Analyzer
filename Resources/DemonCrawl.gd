extends RefCounted
class_name DemonCrawl

# ==============================================================================
const LOG_FILE_NAME := "log%d.txt"
const STAGE_MODS: PackedStringArray = [
	"Abstact", "Aching", "Active", "Apocalyptic", "Astral", "Barbed", "Bleeding",
	"Blinding", "Brooding", "Burning", "Celestial", "Chummy", "Communist", "Convulsing",
	"Crooked", "Cryptic", "Dangerous", "Dark", "Devouring", "Dirty", "Disturbing",
	"Diverse", "Double", "Dramatic", "Dry", "Dumb", "Educational", "Electric",
	"Elemental", "Evolving", "Explosive", "Fake", "Feeble", "Fickle", "Flawless",
	"Forgotten", "Forsaken", "Frothy", "Frozen", "Galvanized", "Glacial", "Grim",
	"Haunted", "Hidden", "Horizontal", "Illusory", "Immutable", "Judging", "Large",
	"Lawless", "Liberated", "Lofty", "Mauling", "Melting", "Misty", "Native", "Nightmare",
	"Nomadic", "Null", "Ominous", "Overwhelming", "Pagan", "Predatory", "Psychotic",
	"Rancid", "Righteous", "Rising", "Scrappy", "Sealed", "Seismic", "Serrated",
	"Shiny", "Silenced", "Slippery", "Stable", "Stronghold", "Surrounded", "Team",
	"Temporal", "Timeless", "Toxic", "Trusty", "Tunnel", "Unchained", "Uncharted",
	"Valhallan", "Vengeful", "Vertical", "Vigilant", "Viral", "Wicked", "Windy",
	"Withering"
]
# ==============================================================================

static func get_logs_dir() -> String:
	var dir := ProjectSettings.get_setting_with_override("custom/demoncrawl/logs_directory") as String
	return dir.replace("%localappdata%", OS.get_data_dir().get_base_dir().path_join("Local"))


static func get_log_path(index: int) -> String:
	return get_logs_dir().path_join(LOG_FILE_NAME % index)


static func get_logs_count() -> int:
	return DirAccess.get_files_at(DemonCrawl.get_logs_dir()).size() - 1 # substract 1 to exclude the _repairs.txt file


static func open_log_file(index: int, flags: FileAccess.ModeFlags = FileAccess.READ) -> FileAccess:
	if index < 1:
		index += get_logs_count()
	
	var path := get_logs_dir().path_join(LOG_FILE_NAME % index)
	
	return FileAccess.open(path, flags)
