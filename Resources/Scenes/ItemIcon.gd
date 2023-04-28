extends TextureRect
class_name ItemIcon

# ==============================================================================
const SCENE := preload("res://Resources/Scenes/ItemIcon.tscn")
const ITEM_LOAD_ATLAS := preload("res://Resources/Scenes/ItemLoadIcon.tres")
# ==============================================================================
var load_atlas := ITEM_LOAD_ATLAS.duplicate()

var item_data := {}
# ==============================================================================
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var description_panel: PanelContainer = %DescriptionPanel
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var description_v_box_container: VBoxContainer = %VBoxContainer
# ==============================================================================

func _ready() -> void:
	description_panel.hide()


func load_item(item_name: String, icon_size: Vector2i = Vector2i(16, 16)) -> void:
	description_panel.position.x = -74 + icon_size.x
	item_data = {}
	
	if not DemonCrawlWiki.is_item_in_cache(item_name):
		texture = load_atlas
		animation_player.play("load")
	
	DemonCrawlWiki.request_item_data(item_name, func(data: Dictionary):
		animation_player.stop()
		
		item_data = data
		
		data.icon.set_size_override(icon_size)
		texture = data.icon
		
		title_label.text = item_name
		description_label.text = data.description
	)


func _on_mouse_entered() -> void:
	if not item_data.is_empty():
		description_panel.show()
		await get_tree().process_frame
		description_panel.position.y = -description_v_box_container.size.y
		description_panel.position.x = size.x / 2 - description_v_box_container.size.x / 2
		
		description_panel.global_position = description_panel.global_position.clamp(Vector2.ZERO, Vector2(get_window().size) - description_panel.size)


func _on_mouse_exited() -> void:
	description_panel.hide()
