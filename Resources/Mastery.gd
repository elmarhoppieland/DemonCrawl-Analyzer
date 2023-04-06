extends RefCounted
class_name Mastery

# ==============================================================================
const _ICON_POS := {
	"Auramancer": Vector2i(0, 0),
	"Banker": Vector2i(1, 0),
	"Barbarian": Vector2i(2, 0),
	"Bookworm": Vector2i(3, 0),
	"Bubbler": Vector2i(4, 0),
	"Commander": Vector2i(0, 1),
	"Demolitionist": Vector2i(1, 1),
	"Detective": Vector2i(2, 1),
	"Exorcist": Vector2i(3, 1),
	"Firefly": Vector2i(4, 1),
	"Ghost": Vector2i(0, 2),
	"Guardian": Vector2i(1, 2),
	"Human": Vector2i(2, 2),
	"Hunter": Vector2i(3, 2),
	"Hypnotist": Vector2i(4, 2),
	"Immortal": Vector2i(0, 3),
	"Knight": Vector2i(1, 3),
	"Lumberjack": Vector2i(2, 3),
	"Marksman": Vector2i(3, 3),
	"Mutant": Vector2i(4, 3),
	"Ninja": Vector2i(0, 4),
	"Novice": Vector2i(1, 4),
	"Poisoner": Vector2i(2, 4),
	"Prophet": Vector2i(3, 4),
	"Protagonist": Vector2i(4, 4),
	"Scholar": Vector2i(0, 5),
	"Scout": Vector2i(1, 5),
	"Snowflake": Vector2i(2, 5),
	"Spark": Vector2i(3, 5),
	"Spy": Vector2i(4, 5),
	"Survivor": Vector2i(0, 6),
	"Undertaker": Vector2i(1, 6),
	"Warlock": Vector2i(2, 6),
	"Witch": Vector2i(3, 6),
	"Wizard": Vector2i(4, 6),
}
const _ICON_SPREADSHEET := preload("res://Sprites/Masteries.png")
# ==============================================================================

static func get_icon(mastery_name: String) -> AtlasTexture:
	if not mastery_name.capitalize() in _ICON_POS:
		return null
	
	var atlas := AtlasTexture.new()
	
	atlas.atlas = _ICON_SPREADSHEET
	
	atlas.region.position = _ICON_POS[mastery_name.capitalize()] * 16.0
	atlas.region.size = Vector2(16, 16)
	
	return atlas
