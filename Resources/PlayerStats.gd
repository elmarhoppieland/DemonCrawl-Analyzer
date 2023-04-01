extends HistoryData
class_name PlayerStats

## Stores the player's stats.

# ==============================================================================
## The number of lives.
var lives := 0
## The player's max lives.
var max_lives := 0
## The number of revives.
var revives := 0
## The player's defense value. Can be negative.
var defense := 0
## The player's coin count.
var coins := 0
# ==============================================================================

## Sets the stats from a [String]. The string is formatted as
## [code]?/? lives, ? revives, ? defense, ? coins[/code]. If the player does not
## have any revives, they do not need to be specified in the string.
static func from_string(stats_string: String) -> PlayerStats:
	var stats := PlayerStats.new()
	
	var stats_array := stats_string.split(", ")
	
	if stats_array.size() == 3:
		stats_array.insert(1, "0 revives")
	
	stats.lives = stats_string.get_slice("/", 0).to_int()
	stats.max_lives = stats_string.get_slice(" ", 0).get_slice("/", 1).to_int()
	
	stats.revives = stats_array[1].to_int()
	
	stats.defense = stats_array[2].to_int()
	
	stats.coins = stats_array[3].to_int()
	
	return stats


func _to_string() -> String:
	if revives:
		return "%s/%s lives, %s revives, %s defense, %s coins" % [lives, max_lives, revives, defense, coins]
	
	return "%s/%s lives, %s defense, %s coins" % [lives, max_lives, defense, coins]
