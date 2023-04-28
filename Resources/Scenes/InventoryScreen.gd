extends Control
class_name InventoryScreen

# ==============================================================================
@export var icon_size := Vector2i(16, 16)
# ==============================================================================
var default_global_margins := {}
var default_separation := {}
var default_size := Vector2(93, 194)
# ==============================================================================
@onready var grid_container: GridContainer = %GridContainer
@onready var margin_container: MarginContainer = %MarginContainer
# ==============================================================================

func _ready() -> void:
	for margin in ["martin_top", "margin_left", "margin_bottom", "margin_right"]:
		default_global_margins[margin] = margin_container.get_theme_constant(margin)
	
	default_separation.h_separation = grid_container.get_theme_constant("h_separation")
	default_separation.v_separation = grid_container.get_theme_constant("v_separation")


func show_inventory(inventory: Inventory) -> void:
	if not inventory:
		push_error("Attempted to show a null inventory. Aborting...")
		return
	
	for index in inventory.items.size():
		var item_name := inventory.items[index]
		if item_name.is_empty():
			break
		
		var item_icon = grid_container.get_child(index) as ItemIcon
		
		item_icon.load_item(item_name, icon_size)
