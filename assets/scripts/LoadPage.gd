extends Control

@export var main_menu_load = false
var selected_save = ""
var loading = false


func _ready():
	SignalManager.loading_screen_activated.connect(_on_loading_screen_activated)


func turn_on():
	visible = true
	$SaveFiles.refresh_save_list()
	$ConfirmAction.turn_off()


func turn_off():
	visible = false


func start_loading():
	SignalManager.activate_loading_screen.emit()
	loading = true


func _on_load_button_pressed():
	if selected_save != "":
		var confirm_message = ""
		if main_menu_load:
			confirm_message = 'Load save "%s"?' % selected_save
		else:
			confirm_message = 'Load save "%s"? \nAll unsaved progress will be lost.' % selected_save
		$ConfirmAction.turn_on(confirm_message)


func _on_save_files_item_selected(index):
	selected_save = $SaveFiles.get_item_text(index)


func _on_loading_screen_activated():
	if loading and selected_save != "":
		LoadManager.load_game(selected_save)


func _on_confirm_action_confirm(type):
	if selected_save != "":
		start_loading()
