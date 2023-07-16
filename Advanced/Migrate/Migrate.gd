extends PopupPanel
class_name MigratePopup

# ==============================================================================
const PROFILE_NAME_EXISTS := "That profile name already exists."
# ==============================================================================
var profile_names := PackedStringArray()
# ==============================================================================
@onready var option_button: OptionButton = %OptionButton
@onready var line_edit: LineEdit = %LineEdit
@onready var error_label: Label = %ErrorLabel
# ==============================================================================

func _ready() -> void:
	hide()
	
	var thread := AutoThread.new(self)
	thread.start(func():
		var save_files := DirAccess.get_files_at(DemonCrawl.get_save_files_dir())
		for save_file_name in save_files:
			var profile_name := save_file_name.get_file().get_basename()
			if profile_name.is_empty():
				continue
			
			profile_names.append(profile_name)
			option_button.add_item(profile_name)
	)


func _on_about_to_popup() -> void:
	error_label.hide()
	
	size = Vector2i.ZERO
	
	var thread := AutoThread.new(self)
	var profile_names_changed := false
	thread.start_execution(func():
		var save_files := DirAccess.get_files_at(DemonCrawl.get_save_files_dir())
		for save_file_name in save_files:
			var profile_name := save_file_name.get_file().get_basename()
			if profile_name.is_empty():
				continue
			
			if profile_name in profile_names:
				continue
			
			profile_names.append(profile_name)
			profile_names_changed = true
	)
	
	await thread.finished
	
	if profile_names_changed:
		profile_names.sort()
		
		option_button.clear()
		option_button.add_item("Select a profile")
		for profile_name in profile_names:
			option_button.add_item(profile_name)
		
		popup_centered()


func _on_button_pressed() -> void:
	var old_name := option_button.get_item_text(option_button.get_selected_id())
	var new_name := line_edit.text
	
	if new_name in profile_names:
		error_label.text = PROFILE_NAME_EXISTS
		error_label.show()
		return
	
	var thread := AutoThread.new(self)
	thread.start_execution(ProfileLoader.rename_profile.bind(old_name, new_name))
	profile_names[profile_names.find(old_name)] = new_name
	option_button.set_item_text(option_button.get_selected_id(), new_name)


func _on_option_button_item_selected(index: int) -> void:
	line_edit.text = option_button.get_item_text(index)
