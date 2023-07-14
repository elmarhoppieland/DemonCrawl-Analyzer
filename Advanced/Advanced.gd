extends Control
class_name Advanced

# ==============================================================================
const MIGRATE_SCENE := preload("res://Advanced/Migrate/Migrate.tscn")
# ==============================================================================
@onready var migrate_popup: PopupPanel = %Migrate
# ==============================================================================

func _on_migrate_profile_button_pressed() -> void:
	migrate_popup.popup_centered()


static func get_tab() -> Advanced:
	return Analyzer.get_tab(Analyzer.Tab.ADVANCED)
