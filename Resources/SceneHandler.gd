extends Node

# ==============================================================================
@onready var current_scene := $"/root/Main"
# ==============================================================================

func switch_scene(new_scene: PackedScene) -> void:
	current_scene.queue_free()
	
	current_scene = new_scene.instantiate()
	
	$"/root".add_child(current_scene)
