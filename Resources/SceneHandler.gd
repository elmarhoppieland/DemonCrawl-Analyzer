extends Node

## A singleton for switching between scenes.

# ==============================================================================
## The current scene.
@onready var current_scene := $"/root".get_child(-1)
# ==============================================================================

## Switch to a new scene.
func switch_scene(new_scene: PackedScene, meta_values: Dictionary = {}) -> void:
	current_scene.queue_free()
	
	current_scene = new_scene.instantiate()
	
	for meta in meta_values:
		current_scene.set_meta(meta, meta_values[meta])
	
	$"/root".add_child(current_scene)
