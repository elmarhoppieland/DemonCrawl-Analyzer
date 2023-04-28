extends TextureRect
class_name ItemIcon

# ==============================================================================
const SCENE := preload("res://Resources/Scenes/ItemIcon.tscn")
const ITEM_LOAD_ATLAS := preload("res://Resources/Scenes/ItemLoadIcon.tres")
# ==============================================================================
var load_atlas := ITEM_LOAD_ATLAS.duplicate()
# ==============================================================================
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func load_item(item_name: String, icon_size: Vector2i = Vector2i(16, 16)) -> void:
	if not DemonCrawlWiki.is_item_in_cache(item_name):
		texture = load_atlas
		animation_player.play("load")
	
	DemonCrawlWiki.request_item_data(item_name, func(data: Dictionary):
		animation_player.stop()
		
		data.icon.set_size_override(icon_size)
		texture = data.icon
	)


func _on_hidden() -> void:
	texture = null
