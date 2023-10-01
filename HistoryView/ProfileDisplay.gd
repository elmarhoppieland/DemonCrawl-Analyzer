@tool
extends MarginContainer
class_name ProfileDisplay

# ==============================================================================
const FONT_SIZE_FACTOR := 0.5
# ==============================================================================
@export var profile_name := "" :
	set(value):
		profile_name = value
		if name_label:
			name_label.text = value
@export var background_color := Color.WHITE :
	set(value):
		background_color = value
		if background_color_rect:
			background_color_rect.color = value
@export var height := 16 :
	set(value):
		height = value
		if icon_rect:
			icon_rect.custom_minimum_size.y = value
		if name_label:
			name_label.label_settings.font_size = int(value * FONT_SIZE_FACTOR)
# ==============================================================================
@onready var background_color_rect: ColorRect = %BackgroundColorRect
@onready var icon_rect: TextureRect = %IconRect
@onready var name_label: Label = %NameLabel
# ==============================================================================

func _ready() -> void:
	background_color_rect.color = background_color
	icon_rect.custom_minimum_size.y = height
	name_label.text = profile_name
	name_label.label_settings.font_size = int(height * FONT_SIZE_FACTOR)
