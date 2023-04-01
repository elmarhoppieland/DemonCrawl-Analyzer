extends Node

# ==============================================================================
## The number of seconds in a full day (24 hours).
const FULL_DAY_SECONDS := 86400
## The amount of days in each month.
const MONTH_DAYS: PackedInt32Array = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
# ==============================================================================

func get_passed_seconds(start_timestamp: String, end_timestamp: String) -> int:
	var day_dif := get_passed_days(get_date(start_timestamp), get_date(end_timestamp))
	
	if day_dif < 0:
		return -1
	
	return to_seconds(get_time(end_timestamp)) - to_seconds(get_time(start_timestamp)) + FULL_DAY_SECONDS * day_dif


func get_passed_days(start_date: String, end_date: String) -> int:
	if start_date == end_date:
		return 0
	
	var start_year := start_date.get_slice("-", 0).to_int()
	var start_month := start_date.get_slice("-", 1).to_int()
	var start_day := start_date.get_slice("-", 2).to_int()
	
	var end_year := end_date.get_slice("-", 0).to_int()
	var end_month := end_date.get_slice("-", 1).to_int()
	var end_day := end_date.get_slice("-", 2).to_int()
	
	if start_year == end_year:
		var day_dif := end_day - start_day
		if start_month == end_month:
			return day_dif
		
		for month in range(start_month, end_month):
			day_dif += MONTH_DAYS[month] + int(month == Time.MONTH_FEBRUARY - 1 and start_year % 4 == 0)
		
		return day_dif
	
	return -1


func to_seconds(time: String) -> int:
	var hours := time.split(":")[0]
	var minutes := time.split(":")[1]
	var seconds := time.split(":")[2]
	
	return hours.to_int() * 3600 + minutes.to_int() * 60 + seconds.to_int()


func get_date(timestamp: String) -> String:
	return timestamp.split("@")[0].trim_prefix("[").trim_suffix(" ")


func get_time(timestamp: String) -> String:
	return timestamp.split("@")[1].trim_prefix(" ").trim_suffix("]")
