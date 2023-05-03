@tool
extends Control
class_name Graph

# ==============================================================================
@export var margin := 10 :
	set(value):
		margin = value
		queue_redraw()
@export var data: Array[float] = [] :
	set(value):
		data = value
		queue_redraw()
@export_group("Line", "line_")
@export var line_color := Color.WHITE :
	set(value):
		line_color = value
		queue_redraw()
@export var line_width := 2.0 :
	set(value):
		line_width = value
		queue_redraw()
@export_group("Limits")
@export var minimum_override := INF :
	set(value):
		minimum_override = value
		queue_redraw()
@export var maximum_override := INF :
	set(value):
		maximum_override = value
		queue_redraw()
# ==============================================================================

func _draw():
	# code written by ChatGPT (with some modifications)
	
	# set up graph properties
	var graph_width := size.x
	var graph_height := size.y
	var graph_rect := Rect2(margin, margin, graph_width - margin * 2, graph_height - margin * 2)
	
	# draw win percentage graph
	if data.size() > 1:
		var min_y := minimum_override if minimum_override < INF else float_array_get_min(data)
		var max_y := maximum_override if maximum_override < INF else float_array_get_max(data)
		var y_range := max_y - min_y
		var x_step := graph_rect.size.x / (data.size() - 1)
		for i in range(1, data.size()):
			var prev_point := graph_rect.position + Vector2(x_step * (i - 1), graph_rect.size.y * (1 - (data[i - 1] - min_y) / y_range))
			var cur_point := graph_rect.position + Vector2(x_step * i, graph_rect.size.y * (1 - (data[i] - min_y) / y_range))
			draw_line(prev_point, cur_point, line_color, line_width)


func float_array_get_max(array: PackedFloat32Array) -> float:
	var value := array[0]
	for i in range(1, array.size()):
		if array[i] > value:
			value = array[i]
	
	return value


func float_array_get_min(array: PackedFloat32Array) -> float:
	var value := array[0]
	for i in range(1, array.size()):
		if array[i] < value:
			value = array[i]
	
	return value


func vector2_array_get_x_values(array: PackedVector2Array) -> PackedFloat32Array:
	var new_array: PackedFloat32Array = []
	for vector2 in array:
		new_array.append(vector2.x)
	return new_array
