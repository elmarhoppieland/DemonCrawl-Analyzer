extends TextureRect
class_name ItemIcon

# ==============================================================================
const SCENE := preload("res://Resources/Scenes/ItemIcon.tscn")
const ITEM_LOAD_ATLAS := preload("res://Resources/Scenes/ItemLoadIcon.tres")
# ==============================================================================
@export var minimum_description_panel_width := 150.0
# ==============================================================================
var load_atlas := ITEM_LOAD_ATLAS.duplicate()

var item_data: ItemDataSource

var mouse_is_inside := false
# ==============================================================================
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var description_panel: PanelContainer = %DescriptionPanel
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
# ==============================================================================

func _ready() -> void:
	description_panel.hide()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left_click"):
		if mouse_is_inside and item_data:
			OS.shell_open(item_data.get_url())


func load_item(item_name: String, icon_size: Vector2i = Vector2i(16, 16)) -> void:
	description_label.text = ""
	description_panel.size = Vector2(minimum_description_panel_width, 0)
	item_data = null
	
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	
	if item_name.is_empty():
		texture = null
		return
	
	texture = load_atlas
	animation_player.play("load")
	
	title_label.text = item_name
	
	if DemonCrawlWiki.is_item_in_cache(item_name):
		item_data = DemonCrawlWiki.get_item_data_from_cache(item_name)
		
		description_label.text = item_data.description
		
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		if item_data.icon:
			animation_player.stop()
			texture = item_data.icon.duplicate()
			texture.set_size_override(icon_size)
			return
		
		DemonCrawlWiki.request_item_icon(item_data.icon_source, func(icon: ImageTexture):
			animation_player.stop()
			
			texture = icon.duplicate()
			texture.set_size_override(icon_size)
			item_data.icon = icon
		)
		return
	
	DemonCrawlWiki.request_item_data(item_name, func(data: ItemDataSource):
		animation_player.stop()
		
		item_data = data
		
		description_label.text = item_data.description
		
		texture = data.icon.duplicate()
		texture.set_size_override(icon_size)
		
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	)


func _on_mouse_entered() -> void:
	mouse_is_inside = true
	
	if item_data:
		description_panel.show()
		
		await get_tree().process_frame
		
		description_panel.position.y = -description_panel.size.y
		description_panel.position.x = size.x / 2 - description_panel.size.x / 2
		
		description_panel.global_position = description_panel.global_position.clamp(Vector2.ZERO, Vector2(get_window().size) - description_panel.size)


func _on_mouse_exited() -> void:
	description_panel.hide()
	
	mouse_is_inside = false
