extends TextureRect
class_name HelpPopup

# ==============================================================================
@export_multiline var text := ""
# ==============================================================================
@onready var panel_container: PanelContainer = %PanelContainer
@onready var help_label: Label = %HelpLabel
# ==============================================================================

func _ready() -> void:
	panel_container.hide()


func _on_mouse_entered() -> void:
	panel_container.show()
	
	panel_container.position.y += size.y
	
	panel_container.position.x -= panel_container.size.x / 2.0
	panel_container.position.x += size.x / 2
	
	panel_container.global_position = panel_container.global_position.clamp(Vector2i.ZERO, Vector2(get_window().size) - panel_container.size)
	
	help_label.text = text


func _on_mouse_exited() -> void:
	panel_container.hide()
