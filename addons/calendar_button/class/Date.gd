extends RefCounted
class_name Date

## Class for storing dates.
##
## Can hold a date's [member day], [member month] and [member year]. These properties
## are passed in when constructing, usually via the [method GDScript.new] method.
## If these are not provided when construcing, uses the date from the user's
## system instead.
##
## [br][br]To convert the date into a [String], the [method date] method can be used.
## It supports both [code]DD-MM-YY[/code] and [code]DD-MM-YYYY[/code] formatting.
## When converting into [String] via another method, such as the [method @GlobalScope.str]
## method, uses [code]DD-MM-YY[/code] formatting.
##
## [br][br]This class also provides methods to switch to the previous or next month,
## handling year changes automatically, via the [method change_to_prev_month] and
## [method change_to_next_month] methods. Use the [method change_to_prev_year] and
## [method change_to_next_year] methods to switch between years, or set the [member year]
## property directly.

# ==============================================================================
## The date's day.
var day := 0
## The date's month. See the [enum Time.Month] constants.
var month := Time.MONTH_JANUARY
## The date's year.
var year := 0
# ==============================================================================

func _init(_day: int = Time.get_datetime_dict_from_system().day,
		_month: int = Time.get_datetime_dict_from_system().month,
		_year: int = Time.get_datetime_dict_from_system().year):
	
	day = _day
	month = _month
	year = _year
	

## Returns the current date in the specified format.
## [br][br] Supported date formats:
## [br][code]DD[/code]: Two digit day
## [br][code]MM[/code]: Two digit month
## [br][code]YY[/code]: Two digit year
## [br][code]YYYY[/code]: Four digit year
func date(date_format: String = "DD-MM-YY") -> String:
	if "DD".is_subsequence_of(date_format):
		date_format = date_format.replace("DD", str(day).pad_zeros(2))
	if "MM".is_subsequence_of(date_format):
		date_format = date_format.replace("MM", str(month).pad_zeros(2))
	if "YYYY".is_subsequence_of(date_format):
		date_format = date_format.replace("YYYY", str(year))
	elif "YY".is_subsequence_of(date_format):
		date_format = date_format.replace("YY", str(year).substr(2,3))
	return date_format


## Switches to the previous [member month], underflowing to the previous [member year] if required.
func change_to_prev_month():
	var selected_month := month
	selected_month -= 1
	if selected_month < 1:
		month = Time.MONTH_DECEMBER
		year -= 1
	else:
		month = selected_month


## Switches to the next [member month], overflowing to the next [member year] if required.
func change_to_next_month():
	var selected_month = month
	selected_month += 1
	if selected_month > 12:
		month = Time.MONTH_JANUARY
		year += 1
	else:
		month = selected_month


## Switches to the previous [member year].
func change_to_prev_year():
	year -= 1


## Switches to the next [member year].
func change_to_next_year():
	year += 1


func _to_string() -> String:
	return date()
