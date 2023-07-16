extends Thread
class_name AutoThread

# ==============================================================================
var ref: Node
var tree: SceneTree

var execution_blocker := ExecutionBlocker.new()
# ==============================================================================
signal finished(value: Variant)
# ==============================================================================

func _init(ref_node: Node) -> void:
	ref = ref_node
	if ref:
		tree = ref.get_tree()
		ref.tree_exiting.connect(func(): finish())


func start_execution(callable: Callable, priority: Priority = PRIORITY_NORMAL, return_value: bool = false) -> Error:
	_start(return_value)
	
	await execution_blocker.wait()
	
	return start(callable, priority)


func finish(return_value: bool = false) -> Variant:
	var value: Variant = wait_to_finish()
	
	if return_value:
		finished.emit(value)
	else:
		finished.emit()
	
	execution_blocker.lower()
	
	return value


func _start(return_value: bool = false) -> void:
	await tree.process_frame
	
	if not tree:
		return
	while is_alive():
		await tree.process_frame
	if is_started():
		finish(return_value)


class ExecutionBlocker extends RefCounted:
	# ==========================================================================
	var can_request := true
	# ==========================================================================
	signal lowered()
	# ==========================================================================
	
	func block() -> void:
		can_request = false
	
	
	func lower() -> void:
		can_request = true
		lowered.emit()
	
	
	func wait() -> void:
		while not can_request:
			await lowered
		
		block()
