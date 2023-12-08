extends RefCounted
class_name Packages

# ==============================================================================
const CORE_PACKAGE_DIR := "res://Packages"
const USER_PACKAGE_DIR := "user://Packages"
# ==============================================================================
static var packages: Array[PackageData] = []
# ==============================================================================

static func initialize() -> void:
	load_core_packages()
	
	load_user_packages()
	
#	for package_dir in PackedStringArray([CORE_PACKAGE_DIR, USER_PACKAGE_DIR]):
#		var dir := DirAccess.open(package_dir)
#		if not dir:
#			push_error("Could not open directory '%s': %s" % [package_dir, error_string(DirAccess.get_open_error())])
#			return
#
#		dir.include_hidden = true
#		dir.include_navigational = false
#
#		dir.list_dir_begin()
#
#		while true:
#			var file := dir.get_next()
#			if file.is_empty():
#				break
#
#			var path := package_dir.path_join(file)
#			if path == CORE_PACKAGE_DIR.path_join("Core"):
#				continue
#
#			load_package(path)


static func load_core_packages() -> void:
	var dir := DirAccess.open(CORE_PACKAGE_DIR)
	if not dir:
		push_error("Could not open directory '%s': %s" % [CORE_PACKAGE_DIR, error_string(DirAccess.get_open_error())])
		return
	
	dir.include_hidden = true
	dir.include_navigational = false
	
	dir.list_dir_begin()
	
	while true:
		var file := dir.get_next()
		if file.is_empty():
			break
		
		var path := CORE_PACKAGE_DIR.path_join(file)
		if path == CORE_PACKAGE_DIR.path_join("Core"):
			continue
		
		load_core_package(path)


static func load_core_package(path: String) -> void:
	var package_data := PackageData.new()
	
	if path.get_extension().is_empty():
		# the package is a directory
		var script: GDScript = load(path.path_join("script.gd"))
		package_data.singleton = script.new()
		return
	
	# the package is a single script
	var script: GDScript = load(path)
	
	package_data.singleton = script.new()
	
	packages.append(package_data)


static func load_user_packages() -> void:
	var dir := DirAccess.open(USER_PACKAGE_DIR)
	if not dir:
		push_error("Could not open directory '%s': %s" % [USER_PACKAGE_DIR, error_string(DirAccess.get_open_error())])
		return
	
	dir.include_hidden = true
	dir.include_navigational = false
	
	dir.list_dir_begin()
	
	while true:
		var file := dir.get_next()
		if file.is_empty():
			break
		
		var path := USER_PACKAGE_DIR.path_join(file)
		if path == USER_PACKAGE_DIR.path_join("Core"):
			continue
		
		load_user_package(path)


static func load_user_package(path: String) -> void:
	var package_data := PackageData.new()
	
	if path.get_extension().is_empty():
		# the package is a directory
		var script_path := path.path_join("script.gd")
		var source_code := FileAccess.get_file_as_string(script_path)
		if source_code.is_empty():
			push_error("There was an error when attempting to open '%s': %s" % [script_path, error_string(FileAccess.get_open_error())])
			return

		var script := GDScript.new()
		script.source_code = source_code
		script.reload()

		var singleton = script.new()

		if not singleton is Package:
			push_error("The script at '%s' does not extend class Package." % script_path)
			return

		package_data.singleton = singleton
		return
	
	# the package is a single script
	var source_code := FileAccess.get_file_as_string(path)
	if source_code.is_empty():
		push_error("There was an error when attempting to open '%s': %s" % [path, error_string(FileAccess.get_open_error())])
		return

	var script := GDScript.new()
	script.source_code = source_code
	script.reload()

	var singleton = script.new()

	if not singleton is Package:
		push_error("The script at '%s' does not extend class Package." % path)
		return

	package_data.singleton = singleton
	
	packages.append(package_data)


static func call_method(method: StringName, args: Array = []) -> Array:
	var returns := []
	
	for package in packages:
		if not package.singleton.has_method(method):
			continue
		var r = package.singleton.callv(method, args)
		returns.append(r)
	
	return returns


## Calls the given [code]method[/code] on all [Package]s, and returns the first value returned by
## a [Package]. If no value is ever returned, returns a default value that matches the
## [code]return_type[/code], or [code]default[/code] if it is not [code]null[/code].
static func get_single_return_value(method: StringName, return_type: Variant.Type, args: Array = [], default: Variant = null) -> Variant:
	var r := call_method(method, args)
	
	for value in r:
		if not typeof(value) == return_type:
			continue
		return value
	
	if default != null:
		return default
	
	match return_type:
		TYPE_INT:
			return -1
		TYPE_FLOAT:
			return 0.0
		TYPE_STRING:
			return ""
	
	return null


# ==============================================================================

class PackageData extends RefCounted:
	var singleton: Package
