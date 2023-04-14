extends ConfigFile
class_name SettingsFile

# ==============================================================================

func save_settings() -> void:
	save(Analyzer.SETTINGS_FILE)


func set_setting(section: String, key: String, value: Variant) -> SettingsFile:
	set_value(section, key, value)
	
	return self


static func set_setting_static(section: String, key: String, value: Variant) -> void:
	Analyzer.get_settings().set_setting(section, key, value).save_settings()
