extends RefCounted
class_name HistoryFile

# ==============================================================================
var file: FileAccess
# ==============================================================================

static func open(path: String, flags: FileAccess.ModeFlags = FileAccess.READ) -> HistoryFile:
	var history_file := HistoryFile.new()
	
	history_file.file = FileAccess.open(path, flags)
	
	return history_file


func get_batch() -> Batch:
	var batch := Batch.new()
	
	while true:
		var position := file.get_position()
		var line_data := get_line()
		if not line_data:
			break
		if line_data.type != LogFile.Line.EOF:
			if batch.unix_time > 0 and line_data.unix_time != batch.unix_time:
				file.seek(position)
				break
		
		if batch.unix_time < 0:
			batch.unix_time = line_data.unix_time
		
		batch.lines.append(line_data)
	
	# re-ordering of lines goes here
	
	return batch


func get_line() -> LineData:
	var line_data := LineData.new()
	var buffer := get_line_buffer()
	
	if buffer.is_empty():
		return null
	
	var offset := 0
	var type := buffer.decode_u16(offset) as LogFile.Line
	offset += 2
	
	line_data.type = type
	
	if type == LogFile.Line.EOF:
#		start_unix_time = -1
		
		return LineData.new(LogFile.Line.EOF)
	
	line_data.unix_time = buffer.decode_u32(offset)
	offset += 4
	
	if not type in LogFile.LINE_FILTERS or not type in LogFile.LINE_PARAM_TYPES:
		return line_data
	
	var param_types: Array = LogFile.LINE_PARAM_TYPES[type]
	
	var params := []
	
	for param_type in param_types:
		match param_type:
			TYPE_NIL:
				continue
			TYPE_STRING:
				var size := buffer.decode_u16(offset)
				offset += 2
				
				var string := buffer.slice(offset, offset + size).get_string_from_utf8()
				params.append(string)
				offset += size
			TYPE_INT:
				var first_byte := buffer.decode_u8(offset)
				offset += 1
				
				var integer := 0
				if first_byte > 0:
					integer = buffer.decode_s64(offset)
					offset += 8
				else:
					integer = buffer.decode_u32(offset)
					offset += 4
				
				params.append(integer)
	
	line_data.params = params
	
	return line_data


func get_line_buffer() -> PackedByteArray:
	if file.eof_reached():
		return []
	
	var position := file.get_position()
	
	var size := 2
	
	var type := file.get_16() as LogFile.Line
	
	if type == LogFile.Line.EOF:
		file.seek(position)
		return file.get_buffer(2)
	
#	var unix_time := file.get_32()
	size += 4
	
	file.seek(position + size)
	
	if not type in LogFile.LINE_FILTERS or not type in LogFile.LINE_PARAM_TYPES:
		file.seek(position)
		return file.get_buffer(size)
	
	var param_types: Array = LogFile.LINE_PARAM_TYPES[type]
	
	for param_type in param_types:
		match param_type:
			TYPE_NIL:
				continue
			TYPE_STRING:
				size += 2 + file.get_16()
			TYPE_INT:
				size += 1
				if file.get_8() > 0:
					size += 8
				else:
					size += 4
		
		file.seek(position + size)
	
	file.seek(position)
	
	return file.get_buffer(size)


func get_position() -> int:
	return file.get_position()


func get_length() -> int:
	return file.get_length()


func eof_reached() -> bool:
	return file.eof_reached()


class LineData extends RefCounted:
	var type := LogFile.Line.UNKNOWN
	var params := []
	var unix_time := -1
	
	
	func _init(_type: LogFile.Line = LogFile.Line.UNKNOWN, _params: Array = [], _unix_time: int = -1) -> void:
		type = _type
		unix_time = _unix_time
	
	
	func has_params() -> bool:
		return not params.is_empty()


class Batch extends RefCounted:
	var lines: Array[LineData] = []
	var unix_time := -1
	
	
	func is_empty() -> bool:
		return lines.is_empty()
