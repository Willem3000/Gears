extends Control

var active = false
var active_window: Control:
	set(value):
		reset_pages()
		active_window = value
		active_window.turn_on()


func _ready():
	active_window = $MainPage
	SignalManager.toggle_pause_menu.connect(toggle)


func toggle():
	if active:
		turn_off()
	else:
		turn_on()


func turn_on():
	active = true
	visible = true
	active_window = $MainPage
	SignalManager.lock_input.emit()


func turn_off():
	active = false
	visible = false
	SignalManager.unlock_input.emit()


func reset_pages():
	$MainPage.turn_off()
	$SavePage.turn_off()
	$LoadPage.turn_off()


func _on_continue_button_pressed():
	turn_off()


func _on_save_button_pressed():
	active_window = $SavePage


func _on_load_button_pressed():
	active_window = $LoadPage


func _on_back_button_pressed():
	active_window = $MainPage


func _on_quit_button_pressed():
	get_tree().quit()
