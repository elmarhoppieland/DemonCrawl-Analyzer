extends RefCounted
class_name Mastery

# ==============================================================================
const _MASTERY_NAMES: PackedStringArray = [
	"Auramancer", "Banker", "Barbarian", "Bookworm", "Bubbler", "Commander",
	"Demolitionist", "Detective", "Exorcist", "Firefly", "Ghost", "Guardian",
	"Human", "Hunter", "Hypnotist", "Immortal", "Knight", "Lumberjack", "Marksman",
	"Mutant", "Ninja", "Novice", "Poisoner", "Prophet", "Protagonist", "Scholar",
	"Scout", "Snowflake", "Spark", "Spy", "Survivor", "Undertaker", "Warlock",
	"Witch", "Wizard", "No Mastery"
]
const _ICON_SPREADSHEET := preload("res://Sprites/Masteries.png")
const _ICON_SPREADSHEET_SIZE := Vector2i(6, 6)
const _ICON_SIZE := Vector2i(16, 16)
# ==============================================================================

static func get_icon(mastery_name: String) -> AtlasTexture:
	if mastery_name.is_empty():
		mastery_name = "No Mastery"
	
	if not mastery_name.capitalize() in _MASTERY_NAMES:
		return null
	
	var atlas := AtlasTexture.new()
	
	atlas.atlas = _ICON_SPREADSHEET
	
	atlas.region.position = _get_icon_topleft(mastery_name) as Vector2
	atlas.region.size = _ICON_SIZE
	
	return atlas


static func _get_icon_topleft(mastery_name: String) -> Vector2i:
	if mastery_name.is_empty():
		mastery_name = "No Mastery"
	
	if not mastery_name.capitalize() in _MASTERY_NAMES:
		return Vector2i(-1, -1)
	
	var mastery_index := _MASTERY_NAMES.find(mastery_name)
	
	var position := Vector2i.ZERO
	position.x = mastery_index % _ICON_SPREADSHEET_SIZE.x
	position.y = floori(mastery_index / float(_ICON_SPREADSHEET_SIZE.x))
	
	return position * _ICON_SIZE
