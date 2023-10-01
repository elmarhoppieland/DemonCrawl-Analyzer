extends MarginContainer
class_name LiveStage

# ==============================================================================
var stage: Stage :
	set(value):
		stage = value
		if value and texture_rect:
			initialize_values()
# ==============================================================================
@onready var texture_rect: TextureRect = %TextureRect
@onready var name_label: Label = %NameLabel
@onready var points_label: Label = %PointsLabel
@onready var chests_label: Label = %ChestsLabel
@onready var lives_label: Label = %LivesLabel
@onready var coins_gained_label: Label = %CoinsGainedLabel
@onready var coins_spent_label: Label = %CoinsSpentLabel
@onready var artifacts_label: Label = %ArtifactsLabel
@onready var border: ColorRect = %Border
@onready var scroll_container: ScrollContainer = %ScrollContainer
# ==============================================================================

func _ready() -> void:
	if stage:
		initialize_values()
	
	scroll_container.mouse_entered.connect(border.show)
	scroll_container.mouse_exited.connect(border.hide)


func initialize_values() -> void:
	texture_rect.texture = stage.get_bg_texture()
	
	name_label.text = stage.name
	
	points_label.text %= stage.points_gained
	chests_label.text %= stage.chests_opened
	lives_label.text %= stage.lives_restored
	coins_gained_label.text %= stage.coins_gained
	coins_spent_label.text %= stage.coins_spent
	artifacts_label.text %= stage.artifacts_collected
