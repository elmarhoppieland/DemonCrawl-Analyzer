extends RefCounted
class_name Calendar

## Helper class for dates.

# ==============================================================================
const _MONTH_NAME: PackedStringArray = [
	"Jan", "Feb", "Mar", "Apr",
	"May", "Jun", "Jul", "Aug",
	"Sep", "Oct", "Nov", "Dec"
]
const _WEEKDAY_NAME: PackedStringArray = [
	"Sunday", "Monday", "Tuesday", "Wednesday",
	"Thursday", "Friday", "Saturday"
]
# ==============================================================================

## Returns the current [Date] from the user's system.
static func get_date() -> Date:
	return Date.new()


## Returns the number of days in [code]month[/code] of [code]year[/code].
static func get_days_in_month(month: Time.Month, year: int) -> int:
	var number_of_days := 0
	if month == Time.MONTH_APRIL or month == Time.MONTH_JUNE or month == Time.MONTH_SEPTEMBER or month == Time.MONTH_NOVEMBER:
		number_of_days = 30
	elif month == Time.MONTH_FEBRUARY:
		var is_leap_year := (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)
		if is_leap_year:
			number_of_days = 29
		else:
			number_of_days = 28
	else:
		number_of_days = 31
	
	return number_of_days


## Returns the weekday associated with the specified [code]day[/code],
## [code]month[/code] and [code]year[/code].
static func get_weekday(day: int, month: Time.Month, year: int) -> Time.Weekday:
	var t := [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
	if month < 3:
		year -= 1
	return (year + year/4 - year/100 + year/400 + t[month - 1] + day) % 7


## Returns the name of the weekday associated with the specified [code]day[/code],
## [code]month[/code] and [code]year[/code].
static func get_weekday_name(day: int, month: int, year: int) -> String:
	var day_num := get_weekday(day, month, year)
	return _WEEKDAY_NAME[day_num]


## Returns the name of the month associated with the specified [code]month[/code].
static func get_month_name(month: Time.Month) -> String:
	return _MONTH_NAME[month - 1]


## Returns the current hour from the user's system.
static func hour() -> int:
	return Time.get_datetime_dict_from_system().hour


## Returns the current minute from the user's system.
static func minute() -> int:
	return Time.get_datetime_dict_from_system().minute


## Returns the current second from the user's system.
static func second() -> int:
	return Time.get_datetime_dict_from_system().second


## Returns the current day from the user's system.
static func day() -> int:
	return Time.get_datetime_dict_from_system().day


## Returns the current weekday from the user's system.
static func weekday() -> int:
	return Time.get_datetime_dict_from_system().weekday


## Returns the current month from the user's system.
static func month() -> int:
	return Time.get_datetime_dict_from_system().month


## Returns the current year from the user's sytem.
static func year() -> int:
	return Time.get_datetime_dict_from_system().year


## Returns the current daylight savings time ([code]dst[/code]) from the user's system.
## [br][br]Equivalent to [method dst].
static func daylight_savings_time() -> int:
	return dst()


## Returns the current daylight savings time ([code]dst[/code]) from the user's system.
## [br][br]Equivalent to [method daylight_savings_time].
static func dst() -> int:
	return Time.get_datetime_dict_from_system().dst
