extends Thread
class_name AutoThread

# ==============================================================================
var ref: Node
var tree: SceneTree
# ==============================================================================
signal finished(value: Variant)
# ==============================================================================

func _init(ref_node: Node) -> void:
	ref = ref_node
	if ref:
		tree = ref.get_tree()
		ref.tree_exiting.connect(func(): finish())


func start_execution(callable: Callable, priority: Priority = PRIORITY_NORMAL, return_value: bool = false) -> Error:
	tree.process_frame.connect(_start.bind(return_value)) # wait 1 frame before calling _start()
	return start(callable, priority)


func finish(return_value: bool = false) -> Variant:
	var value: Variant = wait_to_finish()
	if return_value:
		finished.emit(value)
	else:
		finished.emit()
	return value


func _start(return_value: bool = false) -> void:
	if not tree:
		return
	while is_alive():
		await tree.process_frame
	if is_started():
		finish(return_value)
