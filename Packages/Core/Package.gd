extends RefCounted
class_name Package

# ==============================================================================
const HISTORY_VIEW := 0
# ==============================================================================
var used_line_types: Array[LogFile.Line] = []
# ==============================================================================

func history_load_line_keep(line: HistoryFile.LineData) -> bool:
	return line.type in used_line_types


func get_history() -> Array[HistoryFile.LineData]:
	return HistoryLoader.get_history_multifiltered(used_line_types)


func use(line: LogFile.Line) -> void:
	used_line_types.append(line)


func get_node(node: int) -> Node:
	match node:
		HISTORY_VIEW:
			return Analyzer.get_node("/root/HistoryView")
	
	return null
