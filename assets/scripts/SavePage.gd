extends Control

const SAVE = 0
const DELETE = 1

var save_name = ""
var save_name_focused = false

func _input(event):
	if save_name_focused && Input.is_key_pressed(KEY_ENTER):
		$SaveName.release_focus()
		_on_save_button_pressed()

func turn_on():
	set_save_status("")
	visible = true
	$SaveFiles.refresh_save_list()

func turn_off():
	visible = false

func save_game(save_name = ""):
	var save_dir = DirAccess.open("user://save")
	
	if validate_save_name(save_name):
		var overwriting = false
		if str(save_name + ".save") in save_dir.get_files():
			overwriting = true
		
		SaveManager.save_game(save_name)
		$SaveFiles.refresh_save_list()
		
		if overwriting:
			set_save_status("Overwrote save succesfully.")
		else:
			set_save_status("Saved succesfully.")


func delete_save(save_name = ""):
	var save_dir = DirAccess.open("user://save")
	
	if validate_save_name(save_name):
		var file_exists = false
		if str(save_name + ".save") in save_dir.get_files():
			file_exists = true
		
		if file_exists:
			SaveManager.delete_save(save_name)
			$SaveFiles.refresh_save_list()

			set_save_status(str('Deleted save "', save_name,'" succesfully.'))
		else:
			set_save_status("Delete save failed.")


func validate_save_name(save_name):
	if save_name == "":
		set_save_status("Name cannot be empty.")
		return false
		
	const valid_chars = " abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%&()_+-=[],"
	for char in save_name:
		if char not in valid_chars:
			set_save_status(str("Failed. ", char, " is not a valid character."))
			return false
	
	return true


func set_save_status(msg):
	$SaveStatus.text = msg


func _on_save_button_pressed():
	save_name = $SaveName.text
	if save_name != "":
		var confirm_message = 'Save game as "%s"?' % save_name
		$ConfirmAction.turn_on(confirm_message, SAVE)


func _on_quick_save_button_pressed():
	var date = Time.get_datetime_string_from_system().replace(":", "")
	save_name = "Quicksave-" + date
	var confirm_message = 'Quicksave game as "%s"?' % save_name
	$ConfirmAction.turn_on(confirm_message, SAVE)


func _on_save_files_item_selected(index):
	save_name = $SaveFiles.get_item_text(index)
	$SaveName.text = save_name


func _on_delete_save_button_pressed():
	var confirm_message = 'Delete save "%s"?' % save_name
	$ConfirmAction.turn_on(confirm_message, DELETE)


func _on_confirm_action_confirm(type):
	match type:
		SAVE:
			save_game(save_name)
		DELETE:
			delete_save(save_name)


func _on_save_name_text_changed():
	$SaveName.text = $SaveName.text.strip_escapes()
	if len($SaveName.text) > 30:
		$SaveName.text = $SaveName.text.substr(0, 30)
	$SaveName.set_caret_column(len($SaveName.text))
	save_name = $SaveName.text


func _on_save_name_focus_entered() -> void:
	save_name_focused = true


func _on_save_name_focus_exited() -> void:
	save_name_focused = false
