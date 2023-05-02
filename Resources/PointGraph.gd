@tool
extends Control
class_name PointGraph

# ==============================================================================
@export var margin := 10.0 :
	set(value):
		margin = value
		queue_redraw()
@export var data: Array[Vector2] = [] :
	set(value):
		data = value
		data.sort_custom(func sort_x(a: Vector2, b: Vector2): return a.x < b.x)
		queue_redraw()
@export var line_color := Color.WHITE :
	set(value):
		line_color = value
		queue_redraw()
@export var line_width := 2 :
	set(value):
		line_width = value
		queue_redraw()
@export_group("Overrides")
@export var x_min_override := INF :
	set(value):
		x_min_override = value
		queue_redraw()
@export var x_max_override := INF :
	set(value):
		x_max_override = value
		queue_redraw()
@export var y_min_override := INF :
	set(value):
		y_min_override = value
		queue_redraw()
@export var y_max_override := INF :
	set(value):
		y_max_override = value
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
		var min_x := x_min_override if x_min_override < INF else float_array_get_min(get_x_values())
		var max_x := x_max_override if x_max_override < INF else float_array_get_max(get_x_values())
		var min_y := y_min_override if y_min_override < INF else float_array_get_min(get_y_values())
		var max_y := y_max_override if y_max_override < INF else float_array_get_max(get_y_values())
#		var x_range := max_x - min_x
#		var y_range := max_y - min_y
#		var x_step := graph_rect.size.x / (data.size() - 1)
		for i in range(1, data.size()):
			var prev_point := get_local_point_position(i - 1, graph_rect, Vector2(min_x, min_y), Vector2(max_x, max_y))
			var cur_point := get_local_point_position(i, graph_rect, Vector2(min_x, min_y), Vector2(max_x, max_y))
#			var prev_point := graph_rect.position + Vector2(x_step * (i - 1), graph_rect.size.y * (1 - (data[i - 1] - min_y) / y_range))
#			var cur_point := graph_rect.position + Vector2(x_step * i, graph_rect.size.y * (1 - (data[i] - min_y) / y_range))
			draw_line(prev_point, cur_point, line_color, line_width)


func get_local_point_position(index: int, graph_rect: Rect2, min_coords: Vector2, max_coords: Vector2) -> Vector2:
	var range_coords := max_coords - min_coords
	var normalized_coords := (data[index] - min_coords) / range_coords
	var y_inverted_normalized_coords := Vector2(normalized_coords.x, 1 - normalized_coords.y)
	return graph_rect.position + graph_rect.size * (y_inverted_normalized_coords)


func get_x_values() -> PackedFloat32Array:
	var x_values: PackedFloat32Array = []
	for value in data:
		x_values.append(value.x)
	return x_values


func get_y_values() -> PackedFloat32Array:
	var y_values: PackedFloat32Array = []
	for value in data:
		y_values.append(value.y)
	return y_values


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
