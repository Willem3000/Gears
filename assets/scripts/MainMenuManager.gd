extends Node2D

var loading = false

var active_window: Control:
	set(value):
		reset_pages()
		active_window = value
		active_window.turn_on()

func _ready():
	SignalManager.loading_screen_activated.connect(_on_loading_screen_activated)
	active_window = $CanvasLayer/MainPage

func reset_pages():
	$CanvasLayer/MainPage.turn_off()
	$CanvasLayer/LoadPage.turn_off()

func start_new_game():
	loading = true
	SignalManager.activate_loading_screen.emit()

func _on_new_game_button_pressed():
	start_new_game()


func _on_load_game_button_pressed():
	active_window = $CanvasLayer/LoadPage


func _on_back_button_pressed():
	active_window = $CanvasLayer/MainPage


func _on_quit_game_button_pressed():
	get_tree().quit()

func _on_loading_screen_activated():
	if loading:
		LoadManager.new_game()
